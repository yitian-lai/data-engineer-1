
-- [1] Landing Table ---------------------------------------------------------------------------------------------------------
CREATE SCHEMA [db_lnd];

-- [1.1] User Table
CREATE TABLE [db_lnd].[t_manual_user_info] (
    [user_id]       NVARCHAR(MAX)   NULL,  -- PK
    [name]          NVARCHAR(MAX)   NULL,
    [email]         NVARCHAR(MAX)   NULL,
    [language]      NVARCHAR(MAX)   NULL,
    [country]       NVARCHAR(MAX)   NULL,
    [created_at]    NVARCHAR(MAX)   NOT NULL,
    [effective_dt]  NVARCHAR(MAX)   NOT NULL DEFAULT SYSDATETIME()
)

INSERT INTO [db_lnd].[t_manual_user_info] ([user_id], [name], [email], [language], [country], [created_at]) VALUES 
('U001', 'John Koh', 'johnkoh@gmail.com', 'EN', 'POLAND', '2026-01-01 09:10'),
('U002', 'Paul Tan', 'paultan@gmail.com', 'EN', 'SINGAPORE', '2026-01-01 10:44'),
('U003', 'Timothy Tan', 'timtan@gmail.com', 'EN', 'SERBIA', '2026-01-01 10:59')

-- [1.2] Session-Level Conversation Table (conversation between a user and the chatbot)
CREATE TABLE [db_lnd].[t_manual_session] (
    [session_id]            NVARCHAR(MAX)   NULL,  -- PK
    [user_id]               NVARCHAR(MAX)   NULL,  -- FK
    [website]               NVARCHAR(MAX)   NULL,
    [page]                  NVARCHAR(MAX)   NULL,
    [channel]               NVARCHAR(MAX)   NULL,
    [ip_address]            NVARCHAR(MAX)   NULL,
    [intent]                NVARCHAR(MAX)   NULL,
    [status]                NVARCHAR(MAX)   NULL, 
    [session_start_dttm]    NVARCHAR(MAX)   NULL,  
    [session_end_dttm]      NVARCHAR(MAX)   NULL,  
    [prev_session_end_dttm] NVARCHAR(MAX)   NULL,          
    [created_at]            NVARCHAR(MAX)   NOT NULL,
    [effective_dt]          NVARCHAR(MAX)   NOT NULL DEFAULT SYSDATETIME()
)

INSERT INTO [db_lnd].[t_manual_session] ([session_id],[user_id], [website], [page], [channel], [ip_address], [intent], [status], [session_start_dttm], [session_end_dttm], [prev_session_end_dttm], [created_at]) VALUES
('S001', 'U001', 'www.shop1.sg', '/checkout', 'web', '10.255.5.19', 'payment', 'escalated', '2026-01-01 11:05', '2026-01-01 11:07', NULL, '2026-01-01 11:08'),
('S002', 'U001', 'www.shop1.sg', '/orders', 'web', '10.255.5.19','tracking', 'completed', '2026-01-02 12:14', '2026-01-02 12:15', '2026-01-01 11:07', '2026-01-02 12:17'),
('S003', 'U001', 'www.shop1.sg', '/faq', 'web', '10.255.5.19','password_reset', 'completed', '2026-01-02 19:06', '2026-01-02 19:09', '2026-01-02 12:15', '2026-01-02 19:11'),
('S004', 'U002', 'www.shop2.sg', '/support', 'web', '118.201.33.7', 'refund', 'escalated', '2026-01-03 12:30', '2026-01-03 12:31', NULL, '2026-01-03 12:34'),
('S005', 'U002', 'www.shop2.sg', '/support', 'web', '118.201.33.7', 'payment_issue', 'completed', '2026-01-03 15:04', '2026-01-03 15:07', '2026-01-03 12:34', '2026-01-03 15:08'),
('S006', 'U003', 'www.shop1.sg', '/orders', 'web', '203.116.12.45', 'tracking', 'completed', '2026-01-03 19:25', '2026-01-03 19:26', NULL, '2026-01-03 19:27'),
('S007', 'U003', 'www.shop1.sg', '/faq', 'web', '203.116.12.45', 'account_issue', 'escalated', '2026-01-04 00:06', '2026-01-04 00:07', '2026-01-03 19:26', '2026-01-04 00:08')

-- [1.3] Message-Level Table 
-- [1.3.1] from SS NLP API Dialogflow
CREATE TABLE [db_lnd].[t_nlpapi_dialogflow_message] (
    [message_id]            NVARCHAR(MAX)   NULL,  -- PK
    [session_id]            NVARCHAR(MAX)   NULL,  -- FK
    [sender]                NVARCHAR(MAX)   NULL,  
    [content_type]          NVARCHAR(MAX)   NULL,
    [nlp_intent]            NVARCHAR(MAX)   NULL,
    [content]               NVARCHAR(MAX)   NULL,
    [sent_dttm]             NVARCHAR(MAX)   NOT NULL,
    [effective_dt]          NVARCHAR(MAX)   NOT NULL DEFAULT SYSDATETIME()
)

INSERT INTO [db_lnd].[t_nlpapi_dialogflow_message] ([message_id], [session_id], [sender], [content_type], [nlp_intent],[content], [sent_dttm]) VALUES
('M00001-P1', 'S001', 'bot', 'text', 'greeting', 'Hi John Koh, what can I help you?', '2026-01-01 11:05'), 
('M00001-P2', 'S001', 'user', 'text', 'payment', 'I cant complete payment', '2026-01-01 11:05'), 
('M00001-P3', 'S001', 'bot', 'text', 'payment', 'Sorry to hear that. Which payment method are you using?', '2026-01-01 11:05'), 
('M00001-P4', 'S001', 'user', 'text', 'payment', 'Credit card', '2026-01-01 11:05'), 
('M00001-P5', 'S001', 'bot', 'text', 'payment', 'Which credit card are you using?', '2026-01-01 11:06'), 
('M00001-P6', 'S001', 'user', 'text', 'payment', 'Citi bank', '2026-01-01 11:06'), 
('M00001-P7', 'S001', 'bot', 'text', 'payment', 'Please try another card. Do you want me to escalate to a human agent?', '2026-01-01 11:06'), 
('M00001-P8', 'S001', 'user', 'text', 'payment', 'Yes, escalate', '2026-01-01 11:07'), 
('M00001-P9', 'S001', 'bot', 'text', 'escalation', 'Please wait a moment.', '2026-01-01 11:07'),

('M00002-P1', 'S002', 'bot', 'text', 'greeting', 'Hi John Koh, what can I help you?', '2026-01-02 12:14'),
('M00002-P2', 'S002', 'user', 'text', 'tracking', 'I wanna track my orders', '2026-01-02 12:14'),
('M00002-P3', 'S002', 'bot', 'text', 'tracking', 'Let me check. Please wait a moment.', '2026-01-02 12:14'),
('M00002-P4', 'S002', 'bot', 'text', 'tracking', 'Your order #122 is out for delivery today and your order #123 is pending seller to ship out.', '2026-01-02 12:15'),

('M00003-P1', 'S003', 'bot', 'text', 'greeting', 'Hi John Koh, what can I help you?', '2026-01-02 19:06'),
('M00003-P2', 'S003', 'user', 'text', 'password_reset', 'I forgot my password. How to reset?', '2026-01-02 19:07'),
('M00003-P3', 'S003', 'bot', 'text', 'password_reset', 'Sure I can help you. Please confirm your registered email is johnkoh@gmail.com.', '2026-01-02 19:07'),
('M00003-P4', 'S003', 'user', 'text', 'password_reset', 'Yes', '2026-01-02 19:07'),
('M00003-P5', 'S003', 'bot', 'text', 'password_reset', 'Please wait a moment.', '2026-01-02 19:07'),
('M00003-P6', 'S003', 'bot', 'text', 'password_reset', 'We have sent a password reset link to your email. Please check your inbox and reset it within 24 hours.', '2026-01-02 19:08'),

('M00004-P1', 'S006', 'bot', 'text', 'greeting', 'Hi Timothy Tan, what can I help you?', '2026-01-03 19:25'),
('M00004-P2', 'S006', 'user', 'text', 'tracking', 'Help me to track my order #771', '2026-01-03 19:25'),
('M00004-P3', 'S006', 'bot', 'text', 'tracking', 'Let me check. Please wait a moment.', '2026-01-03 19:25'),
('M00004-P4', 'S006', 'bot', 'text', 'tracking', 'Your order #1771 has arrived at the crossborder logistics facility.', '2026-01-03 19:25'),
('M00004-P5', 'S006', 'user', 'text', 'tracking', 'ok', '2026-01-03 19:26'),
('M00004-P6', 'S006', 'bot', 'text', 'tracking', 'Great! Have a nice day!', '2026-01-03 19:26'),

('M00005-P1', 'S007', 'bot', 'text', 'greeting', 'Hi Timothy Tan, what can I help you?', '2026-01-04 00:06'),
('M00005-P2', 'S007', 'user', 'text', 'account_issue', 'I can''t login to my account', '2026-01-04 00:06'),
('M00005-P3', 'S007', 'bot', 'text', 'account_issue', 'Sorry to hear that. Are you seeing any error message?', '2026-01-04 00:06'),
('M00005-P5', 'S007', 'user', 'text', 'account_issue', 'It said my acc is locked', '2026-01-04 00:06'),
('M00005-P6', 'S007', 'bot', 'text', 'account_issue', 'This usually happens after mutiple failed attempts. Would you like me to unlock it for you?', '2026-01-04 00:06'),
('M00005-P7', 'S007', 'user', 'text', 'account_issue', 'Yes, pls', '2026-01-04 00:07'),
('M00005-P8', 'S007', 'bot', 'text', 'account_issue', 'For security reasons, I will need a human agent to assit. Escalating now.', '2026-01-04 00:07'),
('M00005-P9', 'S007', 'bot', 'text', 'escalation', 'Please wait a moment.', '2026-01-04 00:07');

-- [1.3.2] from SS NLP API Rasa
CREATE TABLE [db_lnd].[t_nlpapi_rasa_message] (
    [message_id]            NVARCHAR(MAX)   NULL,  -- PK
    [session_id]            NVARCHAR(MAX)   NULL,  -- FK
    [sender]                NVARCHAR(MAX)   NULL,  
    [content_type]          NVARCHAR(MAX)   NULL,
    [nlp_intent]            NVARCHAR(MAX)   NULL,
    [content]               NVARCHAR(MAX)   NULL,
    [sent_dttm]             NVARCHAR(MAX)   NOT NULL,
    [effective_dt]          NVARCHAR(MAX)   NOT NULL DEFAULT SYSDATETIME()
)

INSERT INTO [db_lnd].[t_nlpapi_rasa_message] ([message_id], [session_id], [sender], [content_type], [nlp_intent],[content], [sent_dttm]) VALUES
('MM001-L001', 'S004', 'bot', 'text', 'refund', 'Hello Paul Tan, Welcome to Shop 2! How can I assist you on your refund process?', '2026-01-03 12:30'), 
('MM001-L002', 'S004', 'user', 'text', 'refund', 'I want to refund my last order', '2026-01-03 12:30'), 
('MM001-L003', 'S004', 'bot', 'text', 'refund', 'I can help with that. May I know your order number?', '2026-01-03 12:30'), 
('MM001-L004', 'S004', 'user', 'text', 'refund', 'Order number is #LSS8930', '2026-01-03 12:31'), 
('MM001-L005', 'S004', 'bot', 'text', 'refund', 'Your order was delivered 10 days ago. May I know the reason for the refund?', '2026-01-03 12:31'), 
('MM001-L006', 'S004', 'user', 'text', 'refund', 'Item is defective', '2026-01-03 12:31'), 
('MM001-L007', 'S004', 'bot', 'text', 'escalation', 'Can you take a photo for me? I will escalate this to a support agent for further assistance.', '2026-01-03 12:31'), 

('MM002-L001', 'S005', 'bot', 'text', 'greeting', 'Hello Paul Tan, Welcome to Shop 2! How can I assist you?', '2026-01-03 15:04'), 
('MM002-L002', 'S005', 'user', 'text', 'payment_issue', 'My payment keeps failing', '2026-01-03 15:04'), 
('MM002-L003', 'S005', 'bot', 'text', 'payment_issue', 'Sorry about that. Are you using credit card or PayNow?', '2026-01-03 15:04'), 
('MM002-L004', 'S005', 'user', 'text', 'payment_issue', 'Credit card', '2026-01-03 15:04'), 
('MM002-L005', 'S005', 'bot', 'text', 'payment_issue', 'Please check if your card has sufficient balance and that OTP is enabled', '2026-01-03 15:04'), 
('MM002-L006', 'S005', 'user', 'text', 'payment_issue', 'I didn''t receive any OTP', '2026-01-03 15:04'), 
('MM002-L007', 'S005', 'bot', 'text', 'payment_issue', 'That usually measn your bank blocked the transaction. Please try another card or PayNow.', '2026-01-03 15:04'), 
('MM002-L008', 'S005', 'user', 'text', 'payment_issue', 'ok, PayNow worked. Thanks', '2026-01-03 15:07'), 
('MM002-L009', 'S005', 'bot', 'text', 'payment_issue', 'Great! Your payment is successful. Is there anything else I can help with?', '2026-01-03 15:07');


-- [2] Structure Table ---------------------------------------------------------------------------------------------------------
CREATE SCHEMA [db_struc];

-- [2.1] User Table
CREATE TABLE [db_struc].[t_stc_manual_user_info] (
    [user_id]       NVARCHAR(10)   NOT NULL, -- PK
    [name]          NVARCHAR(100)  NOT NULL,
    [email]         VARCHAR(500)   NULL,
    [language]      VARCHAR(10)    NULL,
    [country]       VARCHAR(50)    NULL,
    [created_at]    DATETIME2(0)   NOT NULL,
    [effective_dt]  DATETIME2      NOT NULL
)

INSERT INTO [db_struc].[t_stc_manual_user_info] 
SELECT 
    CONVERT(NVARCHAR(10), [user_id]) AS [name],
    CONVERT(NVARCHAR(100), [name]) AS [user_id],
    CONVERT(VARCHAR(500), [email]) AS [email],
    CONVERT(VARCHAR(10), [language]) AS [language],
    CONVERT(VARCHAR(50), [country]) AS [country],
    CONVERT(DATETIME2(0), [created_at], 120) AS [created_at],
    SYSDATETIME() AS [effective_dt]
FROM [db_lnd].[t_manual_user_info];

-- [2.2] Session-Level Conversation Table
CREATE TABLE [db_struc].[t_stc_manual_session] (
    [session_id]            NVARCHAR(10)    NOT NULL,
    [user_id]               NVARCHAR(10)    NOT NULL,
    [website]               VARCHAR(500)    NOT NULL,
    [page]                  VARCHAR(50)     NOT NULL,
    [channel]               VARCHAR(100)    NULL,
    [ip_address]            VARCHAR(15)     NOT NULL,
    [intent]                VARCHAR(200)    NULL,
    [status]                VARCHAR(60)     NOT NULL, 
    [session_start_dttm]    DATETIME2(0)    NULL, 
    [session_end_dttm]      DATETIME2(0)    NULL,
    [prev_session_end_dttm] DATETIME2(0)    NULL,
    [created_at]            DATETIME2(0)    NOT NULL,
    [effective_dt]          DATETIME2       NOT NULL
)

INSERT INTO [db_struc].[t_stc_manual_session] 
SELECT 
    CONVERT(NVARCHAR(10), [session_id]) AS [session_id],
    CONVERT(NVARCHAR(10), [user_id]) AS [user_id],
    CONVERT(VARCHAR(500), [website]) AS [website],
    CONVERT(VARCHAR(50), [page]) AS [page],
    CONVERT(VARCHAR(100), [channel]) AS [channel],
    CONVERT(VARCHAR(15), [ip_address]) AS [ip_address],
    CONVERT(VARCHAR(200), [intent]) AS [intent],
    CONVERT(VARCHAR(60), [status]) AS [status],
    CONVERT(DATETIME2(0), [session_start_dttm], 120) AS [session_start_dttm],
    CONVERT(DATETIME2(0), [session_end_dttm], 120) AS [session_end_dttm],
    CONVERT(DATETIME2(0), [prev_session_end_dttm], 120) AS [prev_session_end_dttm],
    CONVERT(DATETIME2(0), [created_at], 120) AS [created_at],
    SYSDATETIME() AS [effective_dt]
FROM [db_lnd].[t_manual_session];

-- [2.3] Message-Level Table 
-- [2.3.1] from SS NLP API Dialogflow
CREATE TABLE [db_struc].[t_stc_nlpapi_dialogflow_message] (
    [message_id]            NVARCHAR(50)    NOT NULL, 
    [session_id]            NVARCHAR(10)    NOT NULL,  
    [sender]                VARCHAR(10)     NOT NULL,  
    [content_type]          VARCHAR(30)     NULL,
    [nlp_intent]            VARCHAR(200)    NULL,
    [content]               VARCHAR(MAX)    NULL,
    [sent_dttm]             DATETIME2(0)    NOT NULL,
    [effective_dt]          DATETIME2       NOT NULL
)

INSERT INTO [db_struc].[t_stc_nlpapi_dialogflow_message] 
SELECT 
    CONVERT(NVARCHAR(50), [message_id]) AS [message_id],
    CONVERT(NVARCHAR(10), [session_id]) AS [session_id],
    CONVERT(VARCHAR(10), [sender]) AS [sender],
    CONVERT(VARCHAR(30), [content_type]) AS [content_type],
    CONVERT(VARCHAR(200), [nlp_intent]) AS [nlp_intent],
    CONVERT(VARCHAR(MAX), [content]) AS [content],
    CONVERT(DATETIME2(0), [sent_dttm], 120) AS [sent_dttm],
    SYSDATETIME() AS [effective_dt]
FROM [db_lnd].[t_nlpapi_dialogflow_message];

-- [2.3.2] from SS NLP API Rasa
CREATE TABLE [db_struc].[t_stc_nlpapi_rasa_message] (
    [message_id]            NVARCHAR(50)    NOT NULL, 
    [session_id]            NVARCHAR(10)    NOT NULL,  
    [sender]                VARCHAR(10)     NOT NULL,  
    [content_type]          VARCHAR(30)     NULL,
    [nlp_intent]            VARCHAR(200)    NULL,
    [content]               VARCHAR(MAX)    NULL,
    [sent_dttm]             DATETIME2(0)    NOT NULL,
    [effective_dt]          DATETIME2       NOT NULL
)
 
INSERT INTO [db_struc].[t_stc_nlpapi_rasa_message] 
SELECT 
    CONVERT(NVARCHAR(50), [message_id]) AS [message_id],
    CONVERT(NVARCHAR(10), [session_id]) AS [session_id],
    CONVERT(VARCHAR(10), [sender]) AS [sender],
    CONVERT(VARCHAR(30), [content_type]) AS [content_type],
    CONVERT(VARCHAR(200), [nlp_intent]) AS [nlp_intent],
    CONVERT(VARCHAR(MAX), [content]) AS [content],
    CONVERT(DATETIME2(0), [sent_dttm], 120) AS [sent_dttm],
    SYSDATETIME() AS [effective_dt] 
FROM [db_lnd].[t_nlpapi_rasa_message];


-- [3] Data Vault Table -------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE SCHEMA [dv_rw];

-- [3.1] HUB: User Table 
CREATE TABLE [dv_rw].[t_hub_user_info] (
    [hub_user_id_key]   NVARCHAR(64)    NOT NULL,
    [hub_load_dttm]     DATETIME2       NOT NULL,
    [hub_src]           VARCHAR(400)    NOT NULL,
    [user_id]           NVARCHAR(10)    NOT NULL
) 

-- [3.2] SATELLITE: User Table 
CREATE TABLE [dv_rw].[t_sat_user_info] (
    [hub_user_id_key]   NVARCHAR(64)    NOT NULL,
    [sat_load_dttm]     DATETIME2       NOT NULL,
    [sat_src]           VARCHAR(400)    NOT NULL,
    [name]              NVARCHAR(100)   NOT NULL,
    [email]             VARCHAR(500)    NULL,
    [language]          VARCHAR(10)     NULL,
    [country]           VARCHAR(50)     NULL,
    [created_at]        DATETIME        NOT NULL
) 

-- [3.3] HUB: Session Table
CREATE TABLE [dv_rw].[t_hub_session] (
    [hub_session_id_key]    NVARCHAR(64)    NOT NULL,
    [hub_load_dttm]         DATETIME2       NOT NULL,
    [hub_src]               VARCHAR(400)    NOT NULL,
    [session_id]            NVARCHAR(10)    NOT NULL
) 

-- [3.4] SATELLITE: Session Table
CREATE TABLE [dv_rw].[t_sat_session] (
    [hub_session_id_key]    NVARCHAR(64)    NOT NULL,
    [sat_load_dttm]         DATETIME2       NOT NULL,
    [sat_src]               VARCHAR(400)    NOT NULL,
    [user_id]               NVARCHAR(10)    NOT NULL,
    [website]               VARCHAR(500)    NOT NULL,
    [page]                  VARCHAR(50)     NOT NULL,
    [channel]               VARCHAR(100)    NULL,
    [ip_address]            VARCHAR(15)     NOT NULL,
    [intent]                VARCHAR(200)    NULL,
    [status]                VARCHAR(60)     NOT NULL, 
    [session_start_dttm]    DATETIME        NULL, 
    [session_end_dttm]      DATETIME        NULL,
    [prev_session_end_dttm] DATETIME        NULL,
    [created_at]            DATETIME        NOT NULL
) 

-- [3.5] HUB: Message Table
CREATE TABLE [dv_rw].[t_hub_message] (
    [hub_message_id_key]   NVARCHAR(64)     NOT NULL,
    [hub_load_dttm]        DATETIME2        NOT NULL,
    [hub_src]              VARCHAR(400)     NOT NULL,
    [message_id]           VARCHAR(50)      NULL  
) 

-- [3.6] SATELLITE: Message Table
CREATE TABLE [dv_rw].[t_sat_dialogflow_message] (
    [hub_message_id_key]    NVARCHAR(64)    NOT NULL,
    [sat_load_dttm]         DATETIME2       NOT NULL,
    [sat_src]               VARCHAR(400)    NOT NULL,
    [session_id]            VARCHAR(10)     NULL, 
    [sender]                VARCHAR(10)     NULL,  
    [content_type]          VARCHAR(30)     NULL,
    [nlp_intent]            VARCHAR(200)    NULL,
    [content]               VARCHAR(MAX)    NULL,
    [sent_dttm]             DATETIME        NOT NULL
    
) 

CREATE TABLE [dv_rw].[t_sat_rasa_message] (
    [hub_message_id_key]    NVARCHAR(64)    NOT NULL,
    [sat_load_dttm]         DATETIME2       NOT NULL,
    [sat_src]               VARCHAR(400)    NOT NULL,
    [session_id]            VARCHAR(10)     NULL, 
    [sender]                VARCHAR(10)     NULL,  
    [content_type]          VARCHAR(30)     NULL,
    [nlp_intent]            VARCHAR(200)    NULL,
    [content]               VARCHAR(MAX)    NULL,
    [sent_dttm]             DATETIME        NOT NULL
    
) 


-- [4] Structure Table > Data Vault Table --------------------------------------------------------------------------------------------------------------------------------
-- [4.1] HUB: User Table 
INSERT INTO [dv_rw].[t_hub_user_info] 
SELECT 
    CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', UPPER(LTRIM(RTRIM(CONVERT(VARCHAR(50),[user_id]))))), 2) AS [hub_user_id_key],
    CONVERT(DATETIME2, SYSDATETIME()) AS [hub_load_dttm],
    CONVERT(VARCHAR(400), 'MANUAL.user_info') AS [hub_src],
    CONVERT(NVARCHAR(10), [user_id]) AS [user_id]
FROM [db_struc].[t_stc_manual_user_info];

-- [4.2] SATELLITE: User Table 
INSERT INTO [dv_rw].[t_sat_user_info] 
SELECT 
    CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', UPPER(LTRIM(RTRIM(CONVERT(VARCHAR(50),[user_id]))))), 2) AS [hub_user_id_key],
    CONVERT(DATETIME2, SYSDATETIME()) AS [sat_load_dttm],
    CONVERT(VARCHAR(400), 'MANUAL.user_info') AS [sat_src],
    CONVERT(VARCHAR(100), [name]) AS [name],
    CONVERT(VARCHAR(500), [email]) AS [email],
    CONVERT(VARCHAR(10), [language]) AS [language],
    CONVERT(VARCHAR(50), [country]) AS [country],
    CONVERT(DATETIME2(0), [created_at], 120) AS [created_at]
FROM [db_struc].[t_stc_manual_user_info];

-- [4.3] HUB: Session Table
INSERT INTO [dv_rw].[t_hub_session] 
SELECT
    CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', UPPER(LTRIM(RTRIM(CONVERT(VARCHAR(50),[session_id]))))), 2) AS [hub_session_id_key],
    CONVERT(DATETIME2, SYSDATETIME()) AS [hub_load_dttm],
    CONVERT(VARCHAR(400), 'MANUAL.session') AS [hub_src],
    CONVERT(NVARCHAR(10), [session_id]) AS [session_id]
FROM [db_struc].[t_stc_manual_session];

-- [4.4] SATELLITE: Session Table
INSERT INTO [dv_rw].[t_sat_session] 
SELECT 
    CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', UPPER(LTRIM(RTRIM(CONVERT(VARCHAR(50),[session_id]))))), 2) AS [hub_session_id_key],
    CONVERT(DATETIME2, SYSDATETIME()) AS [sat_load_dttm],
    CONVERT(VARCHAR(400), 'MANUAL.session') AS [sat_src],
    CONVERT(NVARCHAR(10), [user_id]) AS [user_id],
    CONVERT(VARCHAR(500), [website]) AS [website],
    CONVERT(VARCHAR(50), [page]) AS [page],
    CONVERT(VARCHAR(100), [channel]) AS [channel],
    CONVERT(VARCHAR(15), [ip_address]) AS [ip_address],
    CONVERT(VARCHAR(200), [intent]) AS [intent],
    CONVERT(VARCHAR(60), [status]) AS [status],
    CONVERT(DATETIME2(0), [session_start_dttm], 120) AS [session_start_dttm],
    CONVERT(DATETIME2(0), [session_end_dttm], 120) AS [session_end_dttm],
    CONVERT(DATETIME2(0), [prev_session_end_dttm], 120) AS [prev_session_end_dttm],
    CONVERT(DATETIME2(0), [created_at], 120) AS [created_at]
FROM [db_struc].[t_stc_manual_session];

-- [4.5] HUB: Message Table
INSERT INTO [dv_rw].[t_hub_message] 
SELECT 
    CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', UPPER(LTRIM(RTRIM(CONVERT(VARCHAR(50),[message_id]))))), 2) AS [hub_message_id_key],
    CONVERT(DATETIME2, SYSDATETIME()) AS [hub_load_dttm],
    CONVERT(VARCHAR(400), 'NLP_API_DIALOGFLOW.message') AS [hub_src],
    CONVERT(NVARCHAR(50), [message_id]) AS [message_id] 
FROM [db_struc].[t_stc_nlpapi_dialogflow_message];

INSERT INTO [dv_rw].[t_hub_message] 
SELECT 
    CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', UPPER(LTRIM(RTRIM(CONVERT(VARCHAR(50),[message_id]))))), 2) AS [hub_message_id_key],
    CONVERT(DATETIME2, SYSDATETIME()) AS [hub_load_dttm],
    CONVERT(VARCHAR(400), 'NLP_API_RASA.message') AS [hub_src],
    CONVERT(NVARCHAR(50), [message_id]) AS [message_id] 
FROM [db_struc].[t_stc_nlpapi_rasa_message];

-- [4.6] SATELLITE: Message Table
INSERT INTO [dv_rw].[t_sat_dialogflow_message] 
SELECT
    CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', UPPER(LTRIM(RTRIM(CONVERT(VARCHAR(50),[message_id]))))), 2) AS [hub_message_id_key],
    CONVERT(DATETIME2, SYSDATETIME()) AS [sat_load_dttm],
    CONVERT(VARCHAR(400), 'NLP_API_RASA.message') AS [sat_src],
    CONVERT(VARCHAR(10), [session_id]) AS [session_id],
    CONVERT(VARCHAR(10), [sender]) AS [sender],
    CONVERT(VARCHAR(30), [content_type]) AS [content_type],
    CONVERT(VARCHAR(200), [nlp_intent]) AS [nlp_intent],
    CONVERT(VARCHAR(MAX), [content]) AS [content],
    CONVERT(DATETIME2(0), [sent_dttm], 120) AS [sent_dttm]
FROM [db_struc].[t_stc_nlpapi_dialogflow_message] 

INSERT INTO [dv_rw].[t_sat_rasa_message] 
SELECT
    CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', UPPER(LTRIM(RTRIM(CONVERT(VARCHAR(50),[message_id]))))), 2) AS [hub_message_id_key],
    CONVERT(DATETIME2, SYSDATETIME()) AS [sat_load_dttm],
    CONVERT(VARCHAR(400), 'NLP_API_RASA.message') AS [sat_src],
    CONVERT(VARCHAR(10), [session_id]) AS [session_id],
    CONVERT(VARCHAR(10), [sender]) AS [sender],
    CONVERT(VARCHAR(30), [content_type]) AS [content_type],
    CONVERT(VARCHAR(200), [nlp_intent]) AS [nlp_intent],
    CONVERT(VARCHAR(MAX), [content]) AS [content],
    CONVERT(DATETIME2(0), [sent_dttm], 120) AS [sent_dttm]
FROM [db_struc].[t_stc_nlpapi_rasa_message] 


-- [5] Semantic Table -------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE SCHEMA [db_sem];

-- [5.1] Monthly User
CREATE TABLE [db_sem].[t_monthly_user_info] (
    [reporting_date]  DATE           NOT NULL,
    [user_id]       NVARCHAR(10)   NOT NULL, 
    [name]          NVARCHAR(100)  NOT NULL,
    [email]         VARCHAR(500)   NULL,
    [language]      VARCHAR(10)    NULL,
    [country]       VARCHAR(50)    NULL
)

-- [5.2] Daily session
CREATE TABLE [db_sem].[t_daily_session] (
    [reporting_date]            DATE           NOT NULL,
    [session_id]                NVARCHAR(10)   NOT NULL, 
    [user_id]                   NVARCHAR(10)   NOT NULL, 
    [website]                   VARCHAR(500)    NOT NULL,
    [page]                      VARCHAR(50)     NOT NULL,
    [channel]                   VARCHAR(100)    NULL,
    [ip_address]                VARCHAR(15)     NOT NULL,
    [intent]                    VARCHAR(200)    NULL,
    [status]                    VARCHAR(60)     NOT NULL, 
    [session_start_dt]          DATE            NULL,
    [session_start_time]        TIME            NULL,
    [session_end_dt]            DATE            NULL,
    [session_end_time]          TIME            NULL,
    [duration_min]              INT             NULL,          
    [duration_sec]              INT             NULL,   
    [prev_session_end_dt]       DATE            NULL,
    [prev_session_end_time]     TIME            NULL,
    [idle_time_min]             INT             NULL,
    [idle_time_hour]            INT             NULL,
    [number_conversation]       INT             NULL
)

-- [5.3] Daily message
CREATE TABLE [db_sem].[t_daily_message] (
    [reporting_date]    DATE           NOT NULL,
    [message_id]        NVARCHAR(50)   NOT NULL,  
    [session_id]        NVARCHAR(10)   NOT NULL,
    [user_id]           NVARCHAR(10)   NOT NULL,
    [website]           VARCHAR(500)    NOT NULL,
    [page]              VARCHAR(50)     NOT NULL,
    [ip_address]        VARCHAR(15)     NOT NULL,
    [sender]            VARCHAR(10)     NULL,  
    [content_type]      VARCHAR(30)     NULL,
    [nlp_intent]        VARCHAR(200)    NULL,
    [content]           VARCHAR(MAX)    NULL,
    [sent_dt]           DATE            NOT NULL,
    [sent_time]         TIME            NOT NULL
)

-- [6] View -------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE VIEW [db_sem].[vw_monthly_user_info] AS
SELECT * FROM [db_sem].[t_monthly_user_info];

CREATE VIEW [db_sem].[vw_daily_session] AS
SELECT * FROM [db_sem].[t_daily_session];

CREATE VIEW [db_sem].[vw_daily_message] AS
SELECT * FROM [db_sem].[t_daily_message];


