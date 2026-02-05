
CREATE PROC [db_sem].[sp_daily_message] @start_dt [date], @end_dt [date] AS

/*
############################################################################################
Name				: db_sem.sp_daily_message
Created date		: 2026-02-03
Author				: Yi Tian Lai (yitian.lai@sg.ey.com)
Company				: EY AnD SG
Purpose				: Stored procedure to generate daily message
Run frequency		: Daily
Usage				: EXEC db_sem.sp_daily_message '2026-01-01', '2026-01-01'
Parameters (if any)	: 1) @start_dt = Start date || 2) @end_dt = End date
Filter (if any)		:

--------------------------------------------------------------------------------------------
Revision History
--------------------------------------------------------------------------------------------
Ver		Author			Date			Description of change
--------------------------------------------------------------------------------------------
1.0		Yi Tian Lai		2026-02-03		Initial Code
--------------------------------------------------------------------------------------------
############################################################################################
*/

BEGIN

BEGIN TRY 
	
	DECLARE @start_dt_text VARCHAR(50) = CONVERT(VARCHAR(50), @start_dt)
	RAISERROR('Start Date: %s', 0, 1, @start_dt_text) WITH NOWAIT;
	DECLARE @end_dt_text VARCHAR(50) = CONVERT(VARCHAR(50), @end_dt)
	RAISERROR('End Date: %s', 0, 1, @end_dt_text) WITH NOWAIT;

	DECLARE @row_cnt INT = (
		SELECT COUNT(1) FROM db_sem.t_daily_message
		WHERE CONVERT(DATE, [reporting_date]) >= @start_dt AND CONVERT(DATE, [reporting_date]) <= @end_dt
	)

	PRINT('Deleting from semantic table for start_dt: ' + @start_dt_text + ' to end_dt: ' + @end_dt_text)
	DELETE FROM db_sem.t_daily_message
	WHERE CONVERT(DATE, [reporting_date]) >= @start_dt AND CONVERT(DATE, [reporting_date]) <= @end_dt

	-- [1] Temp table for message combine
	IF OBJECT_ID('tempdb..#t_tmp_msg_com') IS NOT NULL
	BEGIN DROP TABLE #t_tmp_msg_com END
	SELECT * 
	INTO #t_tmp_msg_com
	FROM (
		SELECT * FROM [dv_rw].[t_sat_dialogflow_message]
		UNION
		SELECT * FROM [dv_rw].[t_sat_rasa_message]
	) com
	

	-- [2] Generate and insert transactional data
	INSERT INTO db_sem.t_daily_message
	SELECT 
		CAST (sat.[sent_dttm] AS DATE) AS [reporting_date],
		hub.[message_id],
		sat.[session_id],
		session_info.[user_id],
		session_info.[website],
		session_info.[page],
		session_info.[ip_address],
		sat.[sender],
		sat.[content_type],
		sat.[nlp_intent],
		sat.[content],
		CAST (sat.[sent_dttm] AS DATE) AS [sent_dt],
		CAST (sat.[sent_dttm] AS TIME) AS [sent_time]

	FROM [dv_rw].[t_hub_message] hub 
	INNER JOIN (
		SELECT * FROM (
			SELECT *, ROW_NUMBER() OVER (PARTITION BY [hub_message_id_key], [session_id], [sender], [content_type], [nlp_intent], [content], [sent_dttm] ORDER BY [sat_load_dttm]) AS RN
			FROM #t_tmp_msg_com
		) a 
		WHERE (RN = 1) AND (CAST([sent_dttm] AS DATE) = @end_dt)
		--WHERE (RN = 1) AND ([sent_dttm] >= '2026-01-01' AND [sent_dttm] <= '2026-01-31')
	) sat
	ON hub.[hub_message_id_key] = sat.[hub_message_id_key]
	--ORDER BY [user_id]

	LEFT JOIN (
		SELECT 
			hub.[session_id],
			sat.[user_id],
			sat.[website],
			sat.[page],
			sat.[ip_address]
		FROM [dv_rw].[t_hub_session] hub 
		INNER JOIN (
			SELECT * FROM (
				SELECT *, ROW_NUMBER() OVER (PARTITION BY [hub_session_id_key], [user_id], [website], [page], [ip_address] ORDER BY [sat_load_dttm]) AS RN
				FROM [dv_rw].[t_sat_session]
			) a WHERE (RN = 1) 
		) sat
		ON hub.[hub_session_id_key] = sat.[hub_session_id_key]
	) session_info
	ON sat.[session_id] = session_info.[session_id]
	ORDER BY [message_id]

END TRY

BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000);
	DECLARE @ErrorSeverity INT;
	DECLARE @ErrorState INT;

	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

		RAISERROR (
			@ErrorMessage,
			@ErrorSeverity,
			@ErrorState
		);

END CATCH

END;

