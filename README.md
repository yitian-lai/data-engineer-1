## data-engineer-1

### Conversational Chatbot ETL Blueprint (SQL Server)
#### Overview
This repository presents a conceptual ETL blueprint for processing conversational chatbot data collected from multiple websites. The focus is strictly on database-layer data transformation, implemented using SQL Server Management Studio (SSMS).

Pipeline steps related to:
- source system extraction
- ingestion into landing folders/zones
- orchestration tools (ADF, Airflow, etc.)
are intentionally excluded.
A small mocked dataset is used to demonstrate the data model, transformation logic, and success metric calculation.

### Architecture Summary
The data flow follows a layered architecture:

Source Systems
   ↓
Landing Folder / Zone
   ↓
Landing Tables 
   ↓
Structured Tables 
   ↓
Data Vault 
   ↓
Semantic Tables
   ↓
Reporting / Analysis

### Data Modeling Approach
This blueprint adopts Data Vault 2.0 as the core modeling approach:
- Hubs represent core business entities (e.g. User, Session).
- Satellites store descriptive attributes and historical changes.
- Link tables are conceptually supported but not physically implemented due to the simplicity of the current dataset. *The model is designed to be extensible, allowing link tables to be introduced in future phases when relationship complexity increases.

### SQL Script Execution Guide
All SQL scripts are numbered and **must be executed sequentially**.

- 00 xx.sql: Creates databases and schemas and oads mocked sample data
- 01 xx.sql to 03 xx.sql: Creates stored procedues (SP), which involves business logic
- 04 xx.sql: Executes stored procedures
- 05 xx.sql: Contains SQL queries answering Task 3

### Limitations
- Multi-device or shared accounts: Users accessing from multiple devices could distort the actual idle time.
- Late-arriving data: If session events are delayed, idle time may appear negative or unusually long.
- Simplified dataset: With the current mock dataset, idle times are illustrative; production datasets may reveal edge cases not covered here.

##### It is important to note that a well-designed ETL process typically includes control and audit tables to track data processing and ensure traceability. While these are not covered in this blueprint, developers should consider implementing them in a production environment.

