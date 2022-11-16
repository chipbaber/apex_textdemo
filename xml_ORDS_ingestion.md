## XML Ingestion through ORDS REST API

In this example we will showcase how Oracle ATP can consume XML files through ORDS and store natively inside the database insde the XML data type. We will also show some basic queries on the information.

- Login to APEX and navigate to SQL Workshop. Execute the following SQL to create the stage_xml table.



```
CREATE TABLE  "STAGE_XML"
   (	"XML_COL" "SYS"."XMLTYPE" ,
	"PROCESSED" CHAR(1) COLLATE "USING_NLS_COMP" NOT NULL ENABLE,
	"ID" NUMBER NOT NULL ENABLE
   )  DEFAULT COLLATION "USING_NLS_COMP"
/

CREATE OR REPLACE EDITIONABLE TRIGGER  "xml_stage_pk"
  before insert on "STAGE_XML"               
  for each row  
begin   
  if :NEW."ID" is null then
    select "STAGE_XML_SEQ".nextval into :NEW."ID" from sys.dual;
  end if;
end;

/
ALTER TRIGGER  "xml_stage_pk" ENABLE
/
```




- Add mime types for the XML Ingestion

![](assets/xml_trigger-400f78ba.png)

```
application/xml,text/xml
```


- Add the following PL/SQL code to ingest the XML as a binary file and convert to CLOB for insertion into the table as the XML type.

```
declare
t1 timestamp := systimestamp;
t2 timestamp;
v_content BLOB; -- Uploading to ORDS as a BLOB in binary
blob_length INTEGER;
v_xml clob;
pos INTEGER := 1;
buf INTEGER := 32767; -- max buffer size per CLOB pull in APEX
v_temp VARCHAR2(32767);
v_rowid VARCHAR2(100);


BEGIN
-- put raw blob into variable
v_content := :BODY;
blob_length := DBMS_LOB.GETLENGTH(v_content);
--if empty xml file pushed into REST throw error
IF v_content IS NULL
  THEN
      RAISE NO_DATA_FOUND;
  ELSE
--create a temp clob
DBMS_LOB.CREATETEMPORARY(v_xml, TRUE);

/*Loop through the blob to form the CLOB*/
WHILE pos < blob_length
LOOP
--if the lenght of the file is shorter than the length of the buffer then swap in buffer length.
if (blob_length < buf) THEN
buf := blob_length;
end if;
-- convert blob raw to varchar and build a CLOB temp variable.
v_temp := UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(v_content, buf, pos));
DBMS_LOB.WRITEAPPEND(v_xml, LENGTH(v_temp), v_temp);
-- move the buffer offset
pos := pos + buf;
END LOOP;

/*Insert into ADB*/
insert into stage_xml (XML_COL, PROCESSED) values (xmltype.createxml(v_xml), 'N') RETURNING ROWID INTO v_rowid;

--return post response
owa_util.status_line(201, '', false);
owa_util.mime_header('application/json', true);
t2 := systimestamp; --get end time
htp.prn('{"status": "XML Inserted","Row ID":"'||v_rowid||'","Blob File Length Received":"'||blob_length||'","Clob File on Convert":"'||DBMS_LOB.GETLENGTH(v_xml)||',"Elapsed Processing Time(Seconds)":"'||TO_CHAR(t2-t1, 'SSSS.FF')||'"}');
--empty out the Clob
 v_xml := EMPTY_CLOB();
END IF;

EXCEPTION
      WHEN NO_DATA_FOUND THEN
            owa_util.status_line(411, 'Null XML File on REST POST Error', false);
            owa_util.mime_header('application/json', true);
            htp.prn('{"error": "411 - Null XML File on REST POST Error","message":"No xml file found in post request. Please return including the binary data in your post call."}');
            v_xml := EMPTY_CLOB();
      WHEN OTHERS
      THEN
            owa_util.status_line(412, 'Unknown Exception Error', false);
            owa_util.mime_header('application/json', true);
            htp.prn('{"error": "412 - Unknown Exception Error","status": "message","Something went wrong in the code, here is the sqlerr response:"'||SQLERRM||'}');
             v_xml := EMPTY_CLOB();

end;
```
