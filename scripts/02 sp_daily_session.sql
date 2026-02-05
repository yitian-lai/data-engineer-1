
CREATE PROC [db_sem].[sp_daily_session] @start_dt [date], @end_dt [date] AS

/*
############################################################################################
Name				: db_sem.sp_daily_session
Created date		: 2026-02-03
Author				: Yi Tian Lai (yitian.lai@sg.ey.com)
Company				: EY AnD SG
Purpose				: Stored procedure to generate daily session
Run frequency		: Daily
Usage				: EXEC db_sem.sp_daily_session '2026-01-01', '2026-01-01'
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
		SELECT COUNT(1) FROM db_sem.t_daily_session
		WHERE CONVERT(DATE, [reporting_date]) >= @start_dt AND CONVERT(DATE, [reporting_date]) <= @end_dt
	)

	PRINT('Deleting from semantic table for start_dt: ' + @start_dt_text + ' to end_dt: ' + @end_dt_text)
	DELETE FROM db_sem.t_daily_session
	WHERE CONVERT(DATE, [reporting_date]) >= @start_dt AND CONVERT(DATE, [reporting_date]) <= @end_dt

	-- [1] Temp table for dialogflow MSG
	IF OBJECT_ID('tempdb..#t_tmp_msg_dialogflow') IS NOT NULL
	BEGIN DROP TABLE #t_tmp_msg_dialogflow END
	SELECT 
		sat.[session_id],
		COUNT(hub.[message_id]) AS [num_convo]

	INTO #t_tmp_msg_dialogflow
	FROM [dv_rw].[t_hub_message] hub
	INNER JOIN (
		SELECT * FROM (
			SELECT *, ROW_NUMBER() OVER (PARTITION BY [hub_message_id_key], [session_id], [sender], [content_type], [nlp_intent], [content], [sent_dttm] ORDER BY [sat_load_dttm]) AS RN
			FROM [dv_rw].[t_sat_dialogflow_message]
		) a WHERE (RN = 1)
	) sat
	ON hub.[hub_message_id_key] = sat.[hub_message_id_key]
	GROUP BY sat.[session_id]

	-- [2] Temp table for Rasa MSG
	IF OBJECT_ID('tempdb..#t_tmp_msg_rasa') IS NOT NULL
	BEGIN DROP TABLE #t_tmp_msg_rasa END
	SELECT 
		sat.[session_id],
		COUNT(hub.[message_id]) AS [num_convo]

	INTO #t_tmp_msg_rasa
	FROM [dv_rw].[t_hub_message] hub
	INNER JOIN (
		SELECT * FROM (
			SELECT *, ROW_NUMBER() OVER (PARTITION BY [hub_message_id_key], [session_id], [sender], [content_type], [nlp_intent], [content], [sent_dttm] ORDER BY [sat_load_dttm]) AS RN
			FROM [dv_rw].[t_sat_rasa_message]
		) a WHERE (RN = 1)
	) sat
	ON hub.[hub_message_id_key] = sat.[hub_message_id_key]
	GROUP BY sat.[session_id]


	-- [3] Generate and insert transactional data
	INSERT INTO db_sem.t_daily_session
	SELECT 
		CAST (sat.[created_at] AS DATE) AS [reporting_date],
		hub.[session_id],
		sat.[user_id],
		sat.[website],
		sat.[page],
		sat.[channel],
		sat.[ip_address],
		sat.[intent],
		sat.[status],
		CAST (sat.[session_start_dttm] AS DATE) AS [session_start_dt],
		CAST (sat.[session_start_dttm] AS TIME) AS [session_start_time],
		CAST (sat.[session_end_dttm] AS DATE)	AS [session_end_dt],
		CAST (sat.[session_end_dttm] AS TIME)	AS [session_end_time],
		DATEDIFF(MINUTE, CAST (sat.[session_start_dttm] AS TIME), CAST (sat.[session_end_dttm] AS TIME)) AS [duration_min],
		DATEDIFF(SECOND, CAST (sat.[session_start_dttm] AS TIME), CAST (sat.[session_end_dttm] AS TIME)) AS [duration_sec],
		CAST (sat.[prev_session_end_dttm] AS DATE) AS [prev_session_end_dt],
		CAST (sat.[prev_session_end_dttm] AS TIME) AS [prev_session_end_time],

		CASE WHEN sat.[prev_session_end_dttm] IS NULL THEN 0
			 WHEN sat.[session_start_dttm] <= sat.[prev_session_end_dttm] THEN 0
			 ELSE DATEDIFF(MINUTE, sat.[prev_session_end_dttm], sat.[session_start_dttm]) 
		END AS [idle_time_min],

		CASE WHEN sat.[prev_session_end_dttm] IS NULL THEN 0
			 WHEN sat.[session_start_dttm] <= sat.[prev_session_end_dttm] THEN 0
			 ELSE DATEDIFF(HOUR, sat.[prev_session_end_dttm], sat.[session_start_dttm]) 
		END AS [idle_time_hour],
		msg.num_convo AS [number_conversation]

	FROM [dv_rw].[t_hub_session] hub 
	INNER JOIN (
		SELECT * FROM (
			SELECT *, ROW_NUMBER() OVER (PARTITION BY [hub_session_id_key], [user_id], [website], [page], [channel], [ip_address], [intent], [status], [session_start_dttm], [session_end_dttm], [prev_session_end_dttm], [created_at] ORDER BY [sat_load_dttm]) AS RN
			FROM [dv_rw].[t_sat_session]
		) a 
		WHERE (RN = 1) AND (CAST ([created_at] AS DATE) = @end_dt)
		--WHERE (RN = 1) AND (CAST ([created_at] AS DATE) = '2026-01-01')
	) sat
	ON hub.[hub_session_id_key] = sat.[hub_session_id_key]
	--ORDER BY [user_id]

	LEFT JOIN (
		SELECT 
			[session_id],
			[num_convo]
		FROM #t_tmp_msg_dialogflow 
		UNION 
		SELECT 
			[session_id],
			[num_convo]
		FROM #t_tmp_msg_rasa 
	) msg
	ON hub.[session_id] = msg.[session_id]
        

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

