## Intro to SODA Collections (JSON) in SQL Worksheet

In this short tutorial we will showcase how Oracle APEX (free tier) can quickly consume and leverage json documents in a matter of minutes. This 101 tutorial will begin with the creation of a SODA collection in SQL Workshop including a Data Load. We will then show how to easily:

- Append more documents to the collection in SQL workshop and Database Actions
- Query the raw json
- Update Nested JSON elements through JSON_TRANSFORM and JSON_MERGEPATCH
- Understand and query the default soda collection view in SQL. 
- Query the collection using javascript syntax in SQL Workshop.
- Create a custom view in SQL Worksheet. 

We reccomend you watch this video before proceeding through the steps below. [Intro to SODA Collections (JSON) in SQL Worksheet on Oracle APEX](https://youtu.be/kGTdOywjnuo)

- To perform these steps the APEX schema user needs to be granted SODA collection from admin. Execute the query below as your user once logged into SQL*Worksheet. If the priviledge does not exist then you will need to have your Autonomous Admin user grant it to you. 
```
SELECT * FROM USER_ROLE_PRIVS;

grant SODA_APP to SEARCHDEMO;
```


- Get Example to get json player data, simple change the player ID number to access and download other json files.
http://lookup-service-prod.mlb.com/json/named.player_info.bam?sport_code='mlb'&player_id='493316'


- See the video above to learn how to create a SODA collection in SQL Worksheet. Once created query the base table. 
```
select * from MLB_PLAYERS
```

- Query the default SODA Collection View in APEX, copy an id for a document record
```
select * from MLB_PLAYERS_VIEW
```

- Query through common javascript syntax in SQL
```
SELECT p.json_document.player_info.queryResults."row".name_display_first_last "Player Name", 
p.json_document.player_info.queryResults."row".jersey_number "Jersey",
p.json_document.player_info.queryResults."row".name_nick "Nick Name"  
FROM MLB_PLAYERS p;

SELECT p.json_document.player_info.queryResults."row".name_display_first_last "Player Name", 
p.json_document.player_info.queryResults."row".jersey_number "Jersey",
p.json_document.player_info.queryResults."row".name_nick "Nick Name"  
FROM MLB_PLAYERS p where p.id = '<add id>';

SELECT p.json_document.player_info.queryResults."row".name_display_first_last "Player Name", 
p.json_document.player_info.queryResults."row".jersey_number "Jersey",
p.json_document.player_info.queryResults."row".name_nick "Nick Name"  
FROM MLB_PLAYERS p where p.json_document.player_info.queryResults."row".jersey_number like '"97"';
```

- Handling keyword row in json collection in SQL Worksheet
```
SELECT ltrim(rtrim(p.json_document.player_info.queryResults."row".twitter_id,'"'),'"') "Twitter Handle" FROM MLB_PLAYERS p;
```

- Example SQL Query to get the raw JSON, notes the copyright text for the next segment.
```
SELECT json_serialize(json_document) "RAW_JSON" FROM MLB_PLAYERS;
```

- Query and remove a segment of JSON from Result. In this example we will leverage the json_transform function remove the copyRight data from all, insert a element of homeruns as a JSON number. Please note the text RETURNING CLOB PRETTY makes this a little eaiser to see on video but is not required. 

```
SELECT json_transform(JSON_DOCUMENT, REMOVE '$.player_info.copyRight' RETURNING CLOB PRETTY)  FROM MLB_PLAYERS;

SELECT json_transform(JSON_DOCUMENT, INSERT '$.player_info.queryResults.row.homeruns' = '20' format JSON RETURNING CLOB PRETTY) "JSON" FROM MLB_PLAYERS p where p.id = '<add id>';

SELECT json_transform(JSON_DOCUMENT, 
SET '$.player_info.queryResults.row.age' = 39, SET '$.player_info.queryResults.row.jersey_number' = '"39"'  format JSON RETURNING CLOB PRETTY) "JSON" FROM MLB_PLAYERS p where p.id =  '<add id>';

SELECT p.json_document.player_info.queryResults."row".name_display_first_last "Player Name", 
p.json_document.player_info.queryResults."row".age "Age",
p.json_document.player_info.queryResults."row".jersey_number "Jersey Number"
FROM MLB_PLAYERS p where p.id = '<add id>';

update MLB_PLAYERS p 
set p.JSON_DOCUMENT = JSON_Transform(JSON_DOCUMENT,
SET '$.player_info.queryResults.row.age' = 39, 
SET '$.player_info.queryResults.row.jersey_number' = '39'
) where p.id = '<add id>';
```

- When it comes time to update both json_transform and JSON merge can be leveraged to select or update. The example below updates a single record's copyRight text

```
select json_mergepatch(p.json_document.player_info, '{"copyRight": "Much Shorter copyright"}' RETURNING CLOB PRETTY) "JSON" from MLB_PLAYERS p where p.id = '<add id>'

SELECT json_serialize(json_document) "RAW_JSON" FROM MLB_PLAYERS p where p.id = '<add id>';

UPDATE MLB_PLAYERS p SET json_document =  json_mergepatch(p.json_document.player_info, '{"copyRight": "Much Shorter copyright"}') where p.id = '<add id>';

SELECT json_serialize(json_document) "RAW_JSON" FROM MLB_PLAYERS p where p.id = '<add id>';
```


- Build out query view

```
SELECT 
"RT"."ID", JT."AGE",JT."BATS", JT."STATUS",JT."THROWS",JT."WEIGHT",
JT."COLLEGE",JT."FULLNAME", JT."DOB", JT."FIRSTNAME", JT."LASTNAME",JT."NICKNAME",JT."PLAYERID",
JT."TWITTER_HANDLE"
FROM  "MLB_PLAYERS" RT, 
JSON_TABLE("JSON_DOCUMENT" FORMAT JSON, '$' COLUMNS 
"AGE" varchar2(2) path '$.player_info.queryResults.row.age', 
"BATS" varchar2(1) path '$.player_info.queryResults.row.bats', 
"STATUS" varchar2(16) path '$.player_info.queryResults.row.status',
"THROWS" varchar2(1) path '$.player_info.queryResults.row.throws', 
"WEIGHT" varchar2(4) path '$.player_info.queryResults.row.weight',
"COLLEGE" varchar2(1) path '$.player_info.queryResults.row.college',
"FULLNAME" varchar2(16) path '$.player_info.queryResults.row.name_full',
"FIRSTNAME" varchar2(8) path '$.player_info.queryResults.row.name_first',
"LASTNAME" varchar2(8) path '$.player_info.queryResults.row.name_last',
"NICKNAME" varchar2(16) path '$.player_info.queryResults.row.name_nick',
"PLAYERID" varchar2(8) path '$.player_info.queryResults.row.player_id',
"TEAM" varchar2(16) path '$.player_info.queryResults.row.team_name',
"DOB" varchar2(32) path '$.player_info.queryResults.row.birth_date',
"TWITTER_HANDLE" varchar2(16) path '$.player_info.queryResults.row.twitter_id') JT  
```

- Query to see the high level information of your collection.

```
SELECT * FROM USER_SODA_COLLECTIONS WHERE URI_NAME = 'MLB_PLAYERS';
```

- How to delete your collection
```
SELECT DBMS_SODA.drop_collection('MLB_PLAYERS') AS drop_status FROM DUAL;
```


## APEX and SODA Collections 201 REST Access
In this section we will show some of the basis to access the default SODA API's created with a SODA colletion in Oracle APEX. We will focus on:

- Basic Authentication from the command line using curl
- Setting up postman with basic authentication calls

- Curl command to get the latest collections from a schema

```
curl -X GET -u 'SEARCHDEMO:<password>' https://ayxzx2tnd0tqzed-sluggersapex.adb.us-ashburn-1.oraclecloudapps.com/ords/searchdemo/soda/latest
```

- Curl command to create a collection called ChipsCollection
```
curl -X PUT -u 'SEARCHDEMO:<password>' https://ayxzx2tnd0tqzed-sluggersapex.adb.us-ashburn-1.oraclecloudapps.com/ords/searchdemo/soda/latest/ChipsCollection
```

- Curl command to delete a collection called ChipsCollection
```
curl -X DELETE -u 'SEARCHDEMO:<password>' https://ayxzx2tnd0tqzed-sluggersapex.adb.us-ashburn-1.oraclecloudapps.com/ords/searchdemo/soda/latest/ChipsCollection
```

- Curl command to insert a document as a binary into a collection
```
curl -X POST -u 'SEARCHDEMO:<password>' --data-binary @/C:/temp/json_mlb/valeri.json -H "Content-Type: application/json" https://ayxzx2tnd0tqzed-sluggersapex.adb.us-ashburn-1.oraclecloudapps.com/ords/searchdemo/soda/latest/MLB_PLAYERS
```

- Curl command to get a individual document based on the document id (ex. doc id - F79DA23912B74E369C36C8F020602A34)
```
curl -X GET -u 'SEARCHDEMO:<password>' https://ayxzx2tnd0tqzed-sluggersapex.adb.us-ashburn-1.oraclecloudapps.com/ords/searchdemo/soda/latest/MLB_PLAYERS/<add doc id>
```

- Curl command to delete a individual document
```
curl -X DELETE -u 'SEARCHDEMO:<password>' https://ayxzx2tnd0tqzed-sluggersapex.adb.us-ashburn-1.oraclecloudapps.com/ords/searchdemo/soda/latest/MLB_PLAYERS/<add doc id>
```
## APEX OATUH in ORDS for SODA Collections 202 REST Access
In this section we are going to show how to: 
- Create oauth token for a developer in pl/sql
- 

- In SQL Workshop take a look at the user_ords_clients view structure
```
desc user_ords_clients;
```

- Query the table to see if any clients are existing. 
```
select * from user_ords_clients;
select * from user_ords_client_privileges;
select * from user_ords_client_roles;
```

- Query the user_ords_roles view, priviledges view, priviledge roles view
```
select * from user_ords_roles;
select * from user_ords_privileges;
select * from user_ords_privilege_roles;
select * from user_ords_privilege_mappings;
```

- Below is example code to create a OAUTH client called player_dev for the developer Chip Baber. Generate a OAuth Token.
```
BEGIN
  OAUTH.create_client(
    p_name            => 'player_dev',
    p_grant_type      => 'client_credentials',
    p_owner           => 'Chip Baber',
    p_description     => 'A client for developer cbaber to access the SODA API',
    p_support_email   => 'support@fakecompany.com',
    p_privilege_names => 'oracle.soda.privilege.developer',
    p_redirect_uri => 'https://fakecompany.com/404',
    p_support_uri => 'https://fakecompany.com/support'
  );
 
  OAUTH.grant_client_role(
    p_client_name => 'player_dev',
    p_role_name   => 'SQL Developer'
  );
 
  OAUTH.grant_client_role(
    p_client_name => 'player_dev',
    p_role_name   => 'SODA Developer'
  );
  COMMIT;
END;
/
```
- Query in SQL Worksheet to get the client_id and client_secret. Copy these values. 

```
SELECT id, name, client_id, client_secret FROM user_ords_clients;
```

- Collect your Client ID and Client Secret
![image of query](/assets/2023-03-13-10-43-58.png)

- Insert the client id and client secret into the curl statement below to get your oauth token. 
```
curl -i -k --user <client id>:<client secret> --data "grant_type=client_credentials" https://ayxzx2tnd0tqzed-sluggersapex.adb.us-ashburn-1.oraclecloudapps.com/ords/searchdemo/oauth/token

curl -i -k --user DEOMyQBpaL2eqBq4BVHcPA..:5qexV2lqmU7O7HLRRUC7Gg.. --data "grant_type=client_credentials" https://ayxzx2tnd0tqzed-sluggersapex.adb.us-ashburn-1.oraclecloudapps.com/ords/searchdemo/oauth/token
```
![](/assets/2023-03-13-10-55-44.png)

- Add Bearer token to Postman, test basic rest endpoints.
```
curl -i -H "Authorization: Bearer <add bearer token>" -X GET  https://ayxzx2tnd0tqzed-sluggersapex.adb.us-ashburn-1.oraclecloudapps.com/ords/searchdemo/soda/latest
```

- Delete Client
```
BEGIN
  OAUTH.revoke_client_role('player_dev','SQL Developer');
  OAUTH.revoke_client_role('player_dev','SODA Developer');
  OAUTH.delete_client('player_dev');
  COMMIT;
END;
/
```

## Example SODA Commands
- These commands will not execute inside SQL Worksheet but will inside Database Actions. 

```
soda create MLB_PLAYERS
```

- Example SODA actions
```
soda list
soda count MLB_PLAYERS
soda get MLB_PLAYERS -all
soda get MLB_PLAYERS -k <add key>
soda insert MLB_PLAYERS {"name" : "Chip is awesome!"}
soda get MLB_PLAYERS -k <add key of inserted record>
soda remove MLB_PLAYERS -k <add key of inserted record>
soda get MLB_PLAYERS -f {"player_info": {"queryResults": {"row": { "jersey_number": "97" }}}}
```

