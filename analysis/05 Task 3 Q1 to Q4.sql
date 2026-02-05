-- [1] TASK 3 -------------------------------------------------------------------------------------------------
-- [1.1] TASK 3.1
SELECT *,
	[avg_duration_min] * 60 AS [avg_duration_second]
FROM (
	SELECT 
		[user_id], 
		[website],
		[ip_address], 
		COUNT([page]) AS [num_session],
		SUM([duration_min]) AS [sum_duration_min],
		AVG([duration_min]) AS [avg_duration_min]
	FROM [db_sem].[vw_daily_session]
	GROUP BY [ip_address], [user_id], [ip_address], [website]
) a

/*
Observation: 
- Based on the existing data, the average session duration is consistently observed to be between 1 to 2 minutes. 
- This indicates that user interactions with the chatbot are generally short and task-focused.
- Therefore, session durations that is exceeding 15 minutes are unable to provide at this stage. 
- In typical chatbot use cases, conversations are designed to resolve user intents quickly (e.g. enquiries, simple troubleshooting, or transactional support). 
- As a result, chatbot conversations rarely require continuous engagement beyond a short time window, and prolonged sessions do not necessarily reflect sustained interaction.
*/

-- [1.1] TASK 3.2
SELECT * FROM [db_sem].[vw_daily_session];

/*
Observation: 
- Based on the existing data, the calculated idle time is approximately between 150 minutes to 1507 minutes, equivalent to around 2.5 hours to 25 hours. 
- Idle time of 0 is excluded as these represent the user's first interaction with the chatbot.
- Each user exhibits at least one non-zero idle time, meaning that user return to the chatbot after an initial interaction 
*/

-- [1.3] TASK 3.3
SELECT 
	[website],
	COUNT ([session_id]) AS [tol_session],
	SUM (CASE WHEN [short_conversation] = 1 THEN 1 ELSE 0 END) AS [short_session],
	CAST (100.0 *  SUM (CASE WHEN [short_conversation] = 1 THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,2)) AS [short_conversation_pct]
FROM (
	SELECT 
		[session_id],
		[ip_address],
		[website],
		[page],
		[session_start_dt],
		[session_start_time],
		[number_conversation],
		[duration_min],
		CASE WHEN [duration_min] <= 1 THEN 1 ELSE NULL END AS [short_conversation]
	FROM [db_sem].[vw_daily_session]
)a
GROUP BY [website]

/* 
Observation:
- Can consider to create this as a view for dashboard usage
*/

-- [1.4] TASK 3.4
SELECT  
	DATEPART(HOUR, [session_start_sg_dttm]) AS [peak_time],
	COUNT(*) AS [cnt]
FROM (
	SELECT *,
		DATETIME2FROMPARTS (
			YEAR([session_start_dt]),
			MONTH([session_start_dt]),
			DAY([session_start_dt]),
			DATEPART(HOUR, [session_start_time]),
			DATEPART(MINUTE, [session_start_time]),
			DATEPART(SECOND, [session_start_time]),
			0,0
		) AT TIME ZONE 'UTC' AT TIME ZONE 'Singapore Standard Time' AS [session_start_sg_dttm]
	FROM [db_sem].[vw_daily_session]
) a
GROUP BY DATEPART(HOUR, [session_start_sg_dttm])
ORDER BY [cnt] DESC

/* 
Observation:
- Based on the existing data, 3 AM and 8 PM is the peak timing
*/
