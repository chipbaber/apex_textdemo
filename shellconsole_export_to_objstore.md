### Data Pump 101 for Autonomous Database in OCI Cloud Shell Console
In this video we will show how to quickly export information from your Autonomous database to object storage leveraging Oracle Data Pump and the OCI Shell Console. The video begins by setting up a auth token, a object storage bucket and opening the shell console. From there we connect into SQL*Web Developer and look at how to create a credential in the database to connect to object storage directly, then will construct a simple export statement that saves the .dmp to our object storage location. For learning purposes we will save our export.log file to the built in data pump directory, then show you how to both query the directory and how to move files from the out of the box directory to object storage leveraging the DBMS_CLOUD.PUT_OBJECT API. The code samples inside github include additional examples of import statements, export statements and code samples to delete credentials. 

Reference this video for how to connect your shell console to your autonomous db. [Connect your OCI Shell Console to an Autonomous Database APEX Schema in 3 min.](https://youtu.be/ts76gocXLe8)

- Please watch this video before proceeding to the sample code below [Data Pump 101 for Autonomous Database in OCI Cloud Shell Console](https://youtu.be/CvyzCjdDvTU).

- Create or collect your auth token. 

- Open the Cloud Shell console and source your .bash_profile.
```
. .bash_profile
```

- Create a new bucket and capture the namespace & name in the fields below. 
```
Namespace: 
Bucket name: 
```

- In a new browser tab open up database actions, and connect to SQL*Developer. This will make viewing some of the sample queries easier. 
```
https://<your database url>/ords/sql-developer?
Ex. URL
https://ayxzx2tnd0tqzed-sluggersapex.adb.us-ashburn-1.oraclecloudapps.com/ords/sql-developer?
```

- Check to see if you have an existing credintial. 
```
SELECT credential_name, username, comments FROM all_credentials;
```

- Create a new credential by pasting in your auth token into the password field below.
```
BEGIN
  DBMS_CLOUD.CREATE_CREDENTIAL(
    credential_name => 'CHIPS_CRED2',
    username => 'oracleidentitycloudservice/chipbaber@gmail.com',
    password => ''
  );
END;
```

- Using the fields above from your bucket create a object storage url to your bucket. 
```
https://objectstorage.us-ashburn-1.oraclecloud.com/n/<namespace>/b/<bucket-name>/o/

Example: 
https://objectstorage.us-ashburn-1.oraclecloud.com/n/id9ju5cntedk/b/apex-backup2024/o/
```

- Create your data pump export command and execute inside the Cloud Shell and launch a export command. Leverage your object storage url above as the dumpfile location. In this example we export a single table.  
```
expdp <database username>@<tns connection name> credential=<credential name> dumpfile=<object storage path>export.dmp TABLES=<schema name>.<table name> logfile=<export file name>.log directory=data_pump_dir  parallel=4

expdp searchdemo@sluggersapex_low credential=CHIPS_CRED2 dumpfile=https://objectstorage.us-ashburn-1.oraclecloud.com/n/id9ju5cntedk/b/apex-backup2024/o/playersbk_8-27.dmp TABLES=searchdemo.players logfile=export8-27.log directory=data_pump_dir parallel=4
```

- Syntax on all export options like schemas, mutliple tables, full database ... can be found here [https://docs.oracle.com/en/database/oracle/oracle-database/23/sutil/oracle-data-pump-overview.html#GUID-17FAE261-0972-4220-A2E4-44D479F519D4](https://docs.oracle.com/en/database/oracle/oracle-database/23/sutil/oracle-data-pump-overview.html#GUID-17FAE261-0972-4220-A2E4-44D479F519D4). 


- Post export you can query the files in your bucket from SQL*Plus. 
```
select object_name,bytes from dbms_cloud.list_objects('CHIPS_CRED2','https://objectstorage.us-ashburn-1.oraclecloud.com/n/<namespace>/b/<bucket-name>/o/');

Example: 
select object_name,bytes from dbms_cloud.list_objects('CHIPS_CRED2','https://objectstorage.us-ashburn-1.oraclecloud.com/n/id9ju5cntedk/b/apex-backup2024/o/');
```

- ADB comes with a pre-mapped data pump directory. This is where your log file in this example was saved. You can view all files in the data pump directory.  
```
SELECT * FROM DBMS_CLOUD.LIST_FILES('DATA_PUMP_DIR');
```

- You can move the log file from Data Pump Directory to Object Storage.
```
begin
DBMS_CLOUD.PUT_OBJECT(credential_name => 'CHIPS_CRED2',
     object_uri => 'https://objectstorage.us-ashburn-1.oraclecloud.com/n/<add namespace>/b/<add bucket name>/o/<add export file name>',
     directory_name => 'DATA_PUMP_DIR',
     file_name => '<add export file name>');
end;
```

- You can also delete files from the data pump directory with the following command. 
```
DBMS_CLOUD.DELETE_FILE ('DATA_PUMP_DIR','<name of file to delete>');
```

- (Optional) Drop your Cloud Credential 
```
BEGIN
   DBMS_CLOUD.DROP_CREDENTIAL('CHIPS_CRED2');
END;
```

- Optional, if DBA then you can leverage this query to see all credentials. 
```
SELECT owner, credential_name FROM dba_credentials;
```

```
- (Optional) Example Command to export to data pump dir a full schema. 
```
expdp searchdemo@sluggersapex_low DIRECTORY=data_pump_dir DUMPFILE=searchdemo.dmp SCHEMAS=searchdemo LOGFILE=searchdemo6-14.log
```

- (Optional) Example Import Statement
```
impdp searchdemo@sluggersapex_low credential=CHIPS_CRED2 dumpfile=https://objectstorage.us-ashburn-1.oraclecloud.com/n/id9ju5cntedk/b/db-backup2024/o/searchdemo7-10.dmp
```

