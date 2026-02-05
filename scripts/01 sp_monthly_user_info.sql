
CREATE PROC [db_sem].[sp_monthly_user_info] @start_dt [date], @end_dt [date] AS

/*
############################################################################################
Name				: db_sem.sp_monthly_user_info
Created date		: 2026-02-03
Author				: Yi Tian Lai (yitian.lai@sg.ey.com)
Company				: EY AnD SG
Purpose				: Stored procedure to generate monthly user info
Run frequency		: Monthly
Usage				: EXEC db_sem.sp_monthly_user_info '2026-01-01', '2026-01-31'
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
		SELECT COUNT(1) FROM db_sem.t_monthly_user_info
		WHERE CONVERT(DATE, [reporting_date]) >= @start_dt AND CONVERT(DATE, [reporting_date]) <= @end_dt
	)

	PRINT('Deleting from semantic table for start_dt: ' + @start_dt_text + ' to end_dt: ' + @end_dt_text)
	DELETE FROM db_sem.t_monthly_user_info
	WHERE CONVERT(DATE, [reporting_date]) >= @start_dt AND CONVERT(DATE, [reporting_date]) <= @end_dt

	-- Generate and insert transactional data
	INSERT INTO db_sem.t_monthly_user_info
	SELECT 
		CAST (sat.[created_at] AS DATE) AS [reporting_date],
		hub.[user_id],
		sat.[name],
		sat.[email],
		sat.[language],
		sat.[country]
	FROM [dv_rw].[t_hub_user_info] hub 
	INNER JOIN (
		SELECT * FROM (
			SELECT *, ROW_NUMBER() OVER (PARTITION BY [hub_user_id_key], [name], [email], [language], [country], [created_at] ORDER BY [sat_load_dttm]) AS RN
			FROM [dv_rw].[t_sat_user_info]
		) a 
		WHERE (RN = 1) AND (CAST([created_at] AS DATE) >= @start_dt AND CAST([created_at] AS DATE) <= @end_dt)
		--WHERE (RN = 1) AND (CAST([created_at] AS DATE) >= '2026-01-01' AND CAST([created_at] AS DATE) <= '2026-01-31')
	) sat
	ON hub.[hub_user_id_key] = sat.[hub_user_id_key]

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

