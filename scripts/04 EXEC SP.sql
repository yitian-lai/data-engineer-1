-- [1] Insert data into semantic table -------------------------------------------------------------------------------------------------
-- [1.1] 
EXEC [db_sem].[sp_monthly_user_info] '2026-01-01', '2026-01-31';
SELECT * FROM [db_sem].[t_monthly_user_info];

-- [1.2]
EXEC [db_sem].[sp_daily_session] '2026-01-01', '2026-01-01';
EXEC [db_sem].[sp_daily_session] '2026-01-02', '2026-01-02';
EXEC [db_sem].[sp_daily_session] '2026-01-03', '2026-01-03';
EXEC [db_sem].[sp_daily_session] '2026-01-04', '2026-01-04';
SELECT * FROM [db_sem].[t_daily_session];

-- [1.2]
EXEC [db_sem].[sp_daily_message] '2026-01-01', '2026-01-01';
EXEC [db_sem].[sp_daily_message] '2026-01-02', '2026-01-02';
EXEC [db_sem].[sp_daily_message] '2026-01-03', '2026-01-03';
EXEC [db_sem].[sp_daily_message] '2026-01-04', '2026-01-04';
SELECT * FROM [db_sem].[t_daily_message];