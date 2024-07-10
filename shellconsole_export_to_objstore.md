### Oracle Cloud Shell Export Database to Object Storage
In this video we will show how to export your Autonomous database manually to object storage. 

```
BEGIN
  DBMS_CLOUD.CREATE_CREDENTIAL(
    credential_name => 'CHIPS_CRED2',
    username => 'oracleidentitycloudservice/chipbaber@gmail.com',
    password => ''
  );
END;

begin
DBMS_CLOUD.CREATE_CREDENTIAL (
credential_name => 'CHIPS_CRED',
user_ocid => '',
tenancy_ocid => '',
private_key => '',
fingerprint => '');
END;

BEGIN
   DBMS_CLOUD.DROP_CREDENTIAL('CHIPS_CRED2');
END;

SELECT owner, credential_name FROM dba_credentials;

select object_name,bytes from dbms_cloud.list_objects('CHIPS_CRED2','https://objectstorage.us-ashburn-1.oraclecloud.com/n/id9ju5cntedk/b/db-backup2024/o/');

```
- Test exp
```
expdp admin@sluggersapex_high credential=CHIPS_CRED2 SCHEMAS=searchdemo,sluggers,cbaber,ADTRIVED,SASANKA.ABEYSINGHE@ORACLE.COM,SHAYNE,SHAYNE.JAYAWARDENE@ORACLE.COM,TAYLOR.ZHENG@ORACLE.COM dumpfile=https://objectstorage.us-ashburn-1.oraclecloud.com/n/id9ju5cntedk/b/db-backup2024/o/searchdem6-28%U.dmp logfile=export6-28.log directory=data_pump_dir

---
expdp admin@sluggersapex_high filesize=5GB credential=CHIPS_CRED2 SCHEMAS=searchdemo,sluggers,cbaber,ADTRIVED,SASANKA.ABEYSINGHE@ORACLE.COM,SHAYNE,SHAYNE.JAYAWARDENE@ORACLE.COM,TAYLOR.ZHENG@ORACLE.COM
 dumpfile=https://objectstorage.us-ashburn-1.oraclecloud.com/n/id9ju5cntedk/b/db-backup2024/o/searchdem6-24%U.dmp parallel=16 encryption_pwd_prompt=yes logfile=searchdem6-26.log directory=data_pump_dir

expdp admin@sluggersapex_high filesize=5GB credential=CHIPS_CRED2 FULL=y dumpfile=https://objectstorage.us-ashburn-1.oraclecloud.com/n/id9ju5cntedk/b/db-backup2024/o/searchdem6-26%U.dmp parallel=16  logfile=searchdem6-26.log directory=data_pump_dir
```

- Import Statement
```
impdp admin@sluggersapex23ai_high credential=CHIPS_CRED2 dumpfile=https://objectstorage.us-ashburn-1.oraclecloud.com/n/id9ju5cntedk/b/db-backup2024/o/searchdem6-2801.dmp exclude=cluster,indextype,db_link directory=data_pump_dir 
```



- Access internal data pump dir and or move a file
```
SELECT * FROM DBMS_CLOUD.LIST_FILES('DATA_PUMP_DIR');

select object_name from DBMS_CLOUD.LIST_FILES('DATA_PUMP_DIR');

DBMS_CLOUD.DELETE_FILE ('DATA_PUMP_DIR','export6-14.log');

begin
DBMS_CLOUD.PUT_OBJECT(credential_name => 'CHIPS_CRED',
     object_uri => 'https://objectstorage.us-ashburn-1.oraclecloud.com/n/id9ju5cntedk/b/db-backup2024/o/searchdemo.dmp',
     directory_name => 'DATA_PUMP_DIR',
     file_name => 'searchdemo.dmp');
end;
```




Other example exports. 
```
expdp admin@sluggersapex_low FULL=y DUMPFILE=fulldbbk_6-14.dmp DIRECTORY=data_pump_dir  VERSION=latest COMPRESSION=all LOGFILE=export6-14.log

expdp admin@sluggersapex_low DIRECTORY=data_pump_dir DUMPFILE=searchdemo.dmp SCHEMAS=searchdemo LOGFILE=searchdemo6-14.log

```