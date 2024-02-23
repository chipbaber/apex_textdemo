--Example 1: Save and edit to device.   

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

--- Example Query 2: Visual Auto trace for Queries
SELECT ID, json_object('PONumber' VALUE PurchaseOrder.PONumber, 'OrderDate' VALUE PurchaseOrder.OrderDate, 
'Items' VALUE (select LISTAGG(json_object('PartNumber' VALUE Items.PartNumber, 'Product Name' VALUE Items.ProductName,'Quantity' VALUE Items.Quantity,'Price' VALUE Items.Price,'Notes' VALUE Items.Notes FORMAT JSON)) as ITEMJSONOUTPUT
  FROM STAGE_XML, XMLTABLE('/PurchaseOrder/Items/Item'  PASSING STAGE_XML.xml_col
    COLUMNS
        PartNumber VARCHAR2(30) PATH '@PartNumber',
        ProductName VARCHAR2(30) PATH 'ProductName',
        Quantity number(5) PATH 'Quantity',
        Price number(8,2) PATH 'USPrice',
        Notes VARCHAR2(30) PATH 'Comment'
         ) Items
   group by ID) FORMAT JSON) JSONOUTPUT
  FROM STAGE_XML, XMLTABLE('/PurchaseOrder'  PASSING STAGE_XML.xml_col
    COLUMNS
        PONumber VARCHAR2(30) PATH '@PurchaseOrderNumber',
        OrderDate VARCHAR2(30) PATH '@OrderDate'
        ) PurchaseOrder

--Example 3: SODA Query Support 
soda list
soda count MLB_PLAYERS
soda get MLB_PLAYERS -f {"player_info": {"queryResults": {"row": { "jersey_number": "97" }}}}




