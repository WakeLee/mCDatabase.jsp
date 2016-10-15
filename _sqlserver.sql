IF OBJECT_ID('[dbo].[mctable]', 'U') IS NOT NULL 
DROP TABLE [dbo].[mctable]

CREATE TABLE [dbo].[mctable] 
(
[ID] int NOT NULL IDENTITY(1,1) ,

[m_tinyint] tinyint NULL ,
[m_smallint] smallint NULL ,
[m_int] int NULL ,
[m_bigint] bigint NULL ,

[m_double] nchar(255) NULL ,

[m_char5] nchar(5) NULL ,
[m_varchar5] nvarchar(5) NULL ,
[m_text] nvarchar(MAX) NULL ,

[m_datetime] datetime2(7) NULL 
)