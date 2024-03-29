# Oracle APEX Text Demonstration
This script will outline the steps required to leverage Oracle Text inside and Autonomous Database. Oracle APEX will be reference and leveraged for the creation of a front end application to upload and interact with the core code.

## Video References
To save time it may be beneficial to watch the following video's related to this content.
- [How to enable full text search on a docx or pdf](https://youtu.be/hDnb3KFXY8Q)
- [How to extract text from inside a PDF](https://youtu.be/AfudCHhAHK4)
- [How to print a CLOB in a Modal Dialog](https://youtu.be/pSw_jFyt5zw)
- [3 ways to deploy a package in 3 min.](https://youtu.be/U6v6XjJ68X0)
- [How to Create a REST API to Upload a BLOB into an APEX Schema](https://youtu.be/rnqGQrhvhLA)


## Create a new workspace in Oracle APEX
- In this example a workspace with the name **searchdemo** was created. As a part of this creation a database user named search demo was also created.

- Login to your new APEX workshop and create a new user. In this example the workspace user is named **cbaber**.

- Login to your workspace as your new user.

## Add grants for Oracle Text to the schema.

- Navigate to SQL Web Developer and open a session as admin.

- Grant the following to **searchdemo**

```
grant ctxapp to searchdemo;
```

- Query to check and see if the priv is granted. This must be executed from SQL workshop that is part of ATP as admin.

```
SELECT * FROM DBA_ROLE_PRIVS WHERE GRANTEE = 'searchdemo';
```

## Create your table to store the resume.

- this was done with APEX wizard code below

```
CREATE table "RESUME" (
    "DOC_ID"       NUMBER NOT NULL,
    "TITLE"        VARCHAR2(500),
    "SUBMITTED_BY" VARCHAR2(300),
    "RESUME"       BLOB,
    "MIMETYPE"     VARCHAR2(250),
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
- Syntax to sync index every minute
```
CREATE INDEX searchMyDocs ON resume(resume) INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS
('DATASTORE CTXSYS.DEFAULT_DATASTORE FILTER CTXSYS.AUTO_FILTER FORMAT COLUMN MIMETYPE sync (every "freq=secondly;interval=60")')
```

## Basic queries of the indexed documentation.

- Core query inside the document to see if contains a keyword. In this first example we are looking for all candidates who have the word java inside there resume. The greater than zero means a score is detected, the information is in the document.

```
SELECT SCORE(1), doc_id, title, submitted_by  FROM resume WHERE CONTAINS(resume, 'Java', 1) > 0;
```

- Find all the documents that have the word java with a score >11 and contain the word nascar.
```
SELECT SCORE(1), doc_id, title, submitted_by  FROM resume WHERE CONTAINS(resume, '(java > 10) and nascar', 1) > 0;
```

- Proximity search look for the word **Eloqua** near word **code**  (Requires Chip resume)

```
SELECT SCORE(1), doc_id, title, submitted_by  FROM resume WHERE CONTAINS(resume, 'Eloqua ; code', 1) > 0;
```

- Second example of proximity search with near operator. Looking for development near creativity within 5 words

```
SELECT SCORE(1), doc_id, title, submitted_by  FROM resume
WHERE CONTAINS(resume, 'near((development, creativity), 5)', 1) > 0;
```

- Fuzzy Search on term.
```
SELECT SCORE(1), doc_id, title, submitted_by  FROM resume WHERE CONTAINS(resume, '?jav', 1) > 0;
```

- Sounds like word - Soundex search
```
SELECT SCORE(1), doc_id, title, submitted_by  FROM resume WHERE CONTAINS(resume, '!ava', 1) > 0;
```


- Stem search on a term. In this example we are looking for the documents that stem of the word work example would return words like workflow,

```
SELECT SCORE(1), doc_id, title, submitted_by  FROM resume WHERE CONTAINS(resume, '$work', 1) > 0;
```

- Accumulation Search - Best to read this to understand [Accum docs](https://docs.oracle.com/cd/E11882_01/text.112/e24436/cqoper.htm#i997062)

```
SELECT SCORE(1), doc_id, title, submitted_by  FROM resume WHERE CONTAINS(resume, 'java ACCUM present', 1) > 0;
```
```
SELECT SCORE(1), doc_id, title, submitted_by  FROM resume WHERE CONTAINS(resume, 'java ACCUM present*3', 1) > 0;
```


- Add More Docs in the apex app. To sync the index execute in this case with 5M of memory

```
begin
CTX_DDL.SYNC_INDEX('searchMyDocs', '5M');
end;
```

## Construct Thematic Search Constructs

- Build themes on docs. To do this you first need to create a table to hold your themes.

```
create table themes (query_id number, theme varchar2(2000), weight number);
```

- Create all the themes on the docs in the table. Run this in pl/sql mode in SQL Workshop. This procedure will loop through the resume table and create themes for all the docs currently in the table.

```
begin
	for x in (select doc_id from resume) loop
    ctx_doc.themes ('searchMyDocs', x.doc_id, 'themes', x.doc_id, full_themes => false);
end loop;
end;
```

- Query the themes. Show all themes with a weight over 25 per resume.
```
select r.title, r.filename, t.theme, t.weight from resume r, themes t
where r.doc_id = t.query_id and weight > 25
order by doc_id asc;
```

- If you need to add more documents you need to rebuild the themes. Make sure to truncate the table before rebuilding.
```
declare
pragma autonomous_transaction;
killThemes	varchar2(100) := 'truncate table themes';

begin
execute immediate killThemes;
	for x in (select doc_id from resume) loop
    ctx_doc.themes ('searchMyDocs', x.doc_id, 'themes', x.doc_id, full_themes => false);
end loop;
end;
```

## Construct Gists Search Constructs

- Create the gists table

```
create table gists (query_id  number, pov  varchar2(80), gist  CLOB);
```

- Build out gists index.
```
begin
	for x in (select doc_id from resume) loop
    ctx_doc.gist('searchMyDocs', x.doc_id, 'gists',x.doc_id,'P', pov =>'GENERIC');
end loop;
end;
```

- Query a gist for a document.
```
select * from gists;
```

- Rebuild the gists index
```
declare
pragma autonomous_transaction;
killGists	varchar2(100) := 'truncate table gists';

begin
execute immediate killGists;
	for x in (select doc_id from resume) loop
    ctx_doc.gist('searchMyDocs', x.doc_id, 'gists',x.doc_id,'P', pov =>'GENERIC');
end loop;
end;
```

## Create a filtered doc

- Create a Table for markup.

```
create table filtered_docs(QUERY_ID  	number,    DOCUMENT  	clob);
```

- Build out filtered docs index's.
```
begin
	for x in (select doc_id from resume) loop
    	ctx_doc.filter ('searchMyDocs', x.doc_id, 'filtered_docs', x.doc_id, plaintext => true);
end loop;
end;                      
```

- Query the filtered doc. Showing the title and the filtered text.

```
select r.title, f.document as "Plain Text Resume" from resume r, filtered_docs f
where r.doc_id = f.query_id
```

## Create Full Themes Indexing

- Create the table for full themes. A full theme has both the theme and any relations to other themes.

```
create table full_themes( QUERY_ID	number, THEME		varchar2(2000),  WEIGHT		NUMBER);
```

- Create indexs for full themes.

```
begin
	for x in (select doc_id from resume) loop
    	ctx_doc.themes ('searchMyDocs', x.doc_id, 'full_themes', x.doc_id, full_themes => true);
end loop;
end;  
```

- Query the full themes. Truth is you need a bit of a tool to visualize thematic connections. So this one works but is tough to convey to users.

```
select r.title, r.filename, t.theme, t.weight from resume r, full_themes t
where r.doc_id = t.query_id
order by doc_id asc;
```

## Scripted Rebuilds

- If you need to rebuild themes, gists ... after loading more documents execute the code in resumeAdmin.sql with the procedures you require. Then call the procedures. Example below.

```
begin
CTX_DDL.SYNC_INDEX('searchMyDocs', '5M');
resumeAdmin.Batch_Create_Themes();
resumeAdmin.Batch_Create_Full_Themes();
resumeAdmin.Batch_Create_Gists();
resumeAdmin.Batch_Create_Filtered_Docs();
end;
```
