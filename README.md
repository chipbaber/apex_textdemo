# Oracle APEX Text Demonstration
This script will outline the steps required to leverage Oracle Text inside and Autonmous Database. Oracle APEX will be reference and leveraged for the creation of a front end application to upload and interact with the core code.

## Create a new workspace in Oracle APEX
- In this example a workspace with the name **searchdemo** was created. As a part of this creation a database user named search demo was also created.

- Login to your new APEX workshop and create a new user. In this example the workspace user is named **cbaber**.

- Login to your workspace as your new user.

## Add grants for Oracle Text to the schema.

- Navigate to SQL Web Developer and open a session as admin.

- Grant the following to **searchdemo**
failed CTXSYS.CTX_QUERY

```
grant ctxapp to searchdemo;
GRANT EXECUTE ON CTXSYS.CTX_CLS TO searchdemo;
GRANT EXECUTE ON CTXSYS.CTX_DDL TO searchdemo;
GRANT EXECUTE ON CTXSYS.CTX_DOC TO searchdemo;
GRANT EXECUTE ON CTXSYS.CTX_OUTPUT TO searchdemo;
GRANT EXECUTE ON CTXSYS.CTX_QUERY TO searchdemo;
GRANT EXECUTE ON CTXSYS.CTX_REPORT TO searchdemo;
GRANT EXECUTE ON CTXSYS.CTX_THES TO searchdemo;
GRANT EXECUTE ON CTXSYS.CTX_ULEXER TO searchdemo;
```

## Create your table to store the resume.

- this was done with APEX wizard code below

```
CREATE table "RESUME" (
    "DOC_ID"       NUMBER NOT NULL,
    "TITLE"        VARCHAR2(500),
    "SUBMITTED_BY" VARCHAR2(300),
    "RESUME"       BLOB,
    "MIMETYPE"     VARCHAR2(50),
    "CREATED_DATE" DATE,
    "FILENAME"     VARCHAR2(200),
    constraint  "RESUME_PK" primary key ("DOC_ID")
)
/

CREATE sequence "RESUME_SEQ"
/

CREATE trigger "BI_RESUME"  
  before insert on "RESUME"              
  for each row
begin  
  if :NEW."DOC_ID" is null then
    select "RESUME_SEQ".nextval into :NEW."DOC_ID" from sys.dual;
  end if;
end;
/   
```

## Create a form to upload a document to the table.
- In APEX create a form to upload a resume to the table. If you need more specifics watch [https://youtu.be/f8hYQtAJ-WY](https://youtu.be/f8hYQtAJ-WY)

- Upload 1 document.

## Build index's on the table for Oracle Text.

- Go to SQL Workshop, SQL commands set to pl/sql and execute the following to create a index. The CTXSYS.AUTO_FILTER must be used for structured docs like PDF and MSword.

```
CREATE INDEX searchMyDocs ON resume(resume) INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS
('DATASTORE CTXSYS.DEFAULT_DATASTORE FILTER CTXSYS.AUTO_FILTER FORMAT COLUMN MIMETYPE');
```

## Basic queries of the indexed documentation.

- Core query inside the document to see if contains a keyword. In this first example we are looking for all candidates who have the word java inside there resume.

```
SELECT SCORE(1), doc_id, title, submitted_by  FROM resume WHERE CONTAINS(resume, 'Java', 1) > 0;
```
