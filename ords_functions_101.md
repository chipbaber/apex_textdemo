# ORDS Functions 101

## Introduction
THIS IS WIP NOT COMPLETE BUT WILL BE A NEW VIDEO IN TIME. This tutorial is designed to accompany the video []() with sample code to showcase how to Oracle REST Data Services to REST enable a function, secure the function then create a meaningful OPEN API specification to be consumed by AI Agents. While we will provide the code itself we will demonstrate in the new Redwood UI inside Database actions the manual steps required for the build. 


## Sample Code for the REST Service Generated in the GUI

--  DEFINE MODULE
BEGIN
    ORDS.DEFINE_MODULE(
        p_module_name => 'calcStats',
        p_base_path => '/calcStats/',
        p_items_per_page=> 0,
        p_status => 'PUBLISHED',
        p_comments=> 'The module calcStats is a simple example of how to rest enable a database function.'
    );
    
END;

--  DEFINE TEMPLATE
BEGIN
    ORDS.DEFINE_TEMPLATE(
        p_module_name => 'calcStats',
        p_pattern => 'getAvg',
        p_priority => 0,
        p_etag_type => 'NONE',
        p_comments => 'This is the template for the calcStats handler and the URI getAvg. getAvg inputs core baseball numerical values and calculates then outputs the players batting average and on base percentage.'
    );
    
END;


-- define handler getting 555 restriction on ui 

-Name: calcStats

- Method: Get

- Source PL/SQL

Core REST call code
```
BEGIN 
PLAYERS.myStats(:p_atBats,
                :p_hits,
                :p_walks_hbp,
                :p_sac,
                :p_battingAvg,
                :p_onBasePercentage);
END;
```
Comments
```
This is the handler for the get Avg function. It inputs the number of atbats, hits, sacrifices and walks + hbp for a player the outputs the players on base percentage and batting average.
```



-- DEFINE PARAMETER
BEGIN
    ORDS.DEFINE_PARAMETER(
        p_module_name => 'calcStats',
        p_pattern => 'getAvg',
        p_method => 'GET',
        p_name => 'p_atBats',
        p_bind_variable_name => 'p_atBats',
        p_source_type => 'HEADER',
        p_access_method => 'IN',
        p_comments => 'Number of at bats a baseball player has in a season or portion of a season.',
        p_param_type => 'INT'
    );
     
END;

-- DEFINE PARAMETER
BEGIN
    ORDS.DEFINE_PARAMETER(
        p_module_name => 'calcStats',
        p_pattern => 'getAvg',
        p_method => 'GET',
        p_name => 'p_battingAvg',
        p_bind_variable_name => 'p_battingAvg',
        p_source_type => 'RESPONSE',
        p_access_method => 'OUT',
        p_comments => 'The calculated batting average from the inputted parameters hits, at bats, sacrifices and walks plus hit by pitches.',
        p_param_type => 'DOUBLE'
    );
     
END;

-- DEFINE PARAMETER 
BEGIN
    ORDS.DEFINE_PARAMETER(
        p_module_name => 'calcStats',
        p_pattern => 'getAvg',
        p_method => 'GET',
        p_name => 'p_hits',
        p_bind_variable_name => 'p_hits',
        p_source_type => 'HEADER',
        p_access_method => 'IN',
        p_comments => 'Number of hits a baseball player has in a season or portion of a season.',
        p_param_type => 'INT'
    );
     
END;

-- DEFINE PARAMETER
BEGIN
    ORDS.DEFINE_PARAMETER(
        p_module_name => 'calcStats',
        p_pattern => 'getAvg',
        p_method => 'GET',
        p_name => 'p_onBasePercentage',
        p_bind_variable_name => 'p_onBasePercentage',
        p_source_type => 'RESPONSE',
        p_access_method => 'OUT',
        p_comments => 'Calculated on base percentage based on input metrics of at bats, hits, sacrifices, walks and hit by pitches.',
        p_param_type => 'DOUBLE'
    );
     
END;

-- DEFINE PARAMETER
BEGIN
    ORDS.DEFINE_PARAMETER(
        p_module_name => 'calcStats',
        p_pattern => 'getAvg',
        p_method => 'GET',
        p_name => 'p_sac',
        p_bind_variable_name => 'p_sac',
        p_source_type => 'HEADER',
        p_access_method => 'IN',
        p_comments => 'Number of sacrifice hits a player has in a season or portion of a season.',
        p_param_type => 'INT'
    );
     
END;

-- DEFINE PARAMETER
BEGIN
    ORDS.DEFINE_PARAMETER(
        p_module_name => 'calcStats',
        p_pattern => 'getAvg',
        p_method => 'GET',
        p_name => 'p_walks_hbp',
        p_bind_variable_name => 'p_walks_hbp',
        p_source_type => 'HEADER',
        p_access_method => 'IN',
        p_comments => 'Total number of walks plus the number of hit by pitches (hpb) a player has in a season or portion of a season.',
        p_param_type => 'INT'
    );
     
END;





## Accessing the REST Service

- Example CURL command with headers. 
```
curl --location -H 'p_walks_hbp:1' -H 'p_sac:0' -H 'p_hits:3' -H 'p_atBats:10' "https://ayxzx2tnd0tqzed-sluggersapex.adb.us-ashburn-1.oraclecloudapps.com/ords/players/calcStats/getAvg"
```



## Securing the Rest Service

- Create a new Role

```
BEGIN
    ORDS.CREATE_ROLE(
        P_ROLE_NAME => 'players.calc.role'
    );
    
END;
```

- Create a Priviledge, assign to players calc role and link to calcStats module created.
```
DECLARE
L_PRIV_ROLES owa.vc_arr;
L_PRIV_PATTERNS owa.vc_arr;
L_PRIV_MODULES owa.vc_arr;
BEGIN
L_PRIV_ROLES( 1 ) := 'players.calc.role';
L_PRIV_MODULES( 1 ) := 'calcStats';
ORDS.DEFINE_PRIVILEGE(
    P_PRIVILEGE_NAME => 'players.analyst.priv',
    P_ROLES => L_PRIV_ROLES,
    P_PATTERNS =>  L_PRIV_PATTERNS,
    P_MODULES => L_PRIV_MODULES,
    P_LABEL => 'players.analyst.priv',
    P_DESCRIPTION => 'Privilege for individuals access to access player data and calculate statistics via REST.',
    P_COMMENTS=> 'Privilege for access to access player data and calculate statistics.'
);

END;
```


- Create an Oauth client with the correct roles and priviledges. 
```
BEGIN
    L_CLIENT_CREDS := ORDS_METADATA.ORDS_SECURITY.REGISTER_CLIENT(
        P_NAME => 'players_oauth_client',
        P_GRANT_TYPE => 'client_credentials',
        P_SUPPORT_EMAIL => 'chipbaber@yahoo.com',
        P_DESCRIPTION => 'This is an ORDS OAuth Token for a client grant.',
        P_CLIENT_SECRET => ORDS_CONSTANTS.OAUTH_CLIENT_SECRET_DEFAULT ,
        P_PRIVILEGE_NAMES => 'players.analyst.priv',
        P_ORIGINS_ALLOWED => '',
        P_REDIRECT_URI => '',
        P_SUPPORT_URI => ''
    );
    ORDS_METADATA.ORDS_SECURITY.GRANT_CLIENT_ROLE(
        P_CLIENT_NAME => 'players_oauth_client',
        P_ROLE_NAME => 'players.calc.role'
    );
    COMMIT;
END;
```

- Copy the client secret & client id

- Request an access token. Ex. ADB Name: https://ayxzx2tnd0tqzed-sluggersapex.adb.us-ashburn-1.oraclecloudapps.com/
```
<adbname>.oraclecloudapps.com/ords/ords101/oauth/token

curl --user <client id>:<client secret> --data 'grant_type=client_credentials' '<adb Name>/ords/players/oauth/token'
```

- Copy your access token

- Formulate your REST Call with your token to access. 

```
curl --location -H 'Authorization: Bearer <bearer token>'  -H 'p_walks_hbp:1' -H 'p_sac:0' -H 'p_hits:3' -H 'p_atBats:10' "https://ayxzx2tnd0tqzed-sluggersapex.adb.us-ashburn-1.oraclecloudapps.com/ords/players/calcStats/getAvg"
``` 

### Example Queries to View more Your Token and Users

To view information about OAuth clients in Oracle Autonomous Database, you can use the following SQL query:

```sql
SELECT 
    id,
    name,
    description,
    client_id,
    client_secret,
    support_email,
    created_by,
    created_on,
    updated_on
FROM 
    user_ords_clients
ORDER BY 
    created_on DESC;
```

## Some other Useful Views
```
select * from user_ords_clients;
select * from user_ords_client_privileges;
select * from user_ords_client_roles;
select * from user_ords_roles where created_by ='PLAYERS';
select * from user_ords_privileges where created_by ='PLAYERS';
select * from user_ords_privilege_roles;
select * from user_ords_privilege_mappings where created_by ='PLAYERS';
```
