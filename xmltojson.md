## Example Queries to quickly convert to JSON
While working on a project we came across a undocumented API that is very useful inside Oracle Autonomous DB. XMLTOJSON() is an API that will convert XML directly into JSON for you in a single query action. If you would like to work through the example below we suggest you first watch the following video to setup and upload XML via REST through ORDS in your database. [How to Ingest/Access XML Files with ORDS and APEX on Oracle ATP](https://www.youtube.com/watch?v=JPyVzhQgTV0&list=PLsnBif_-5JnA8Hzvp8e1bQ3fo6VEvYEB0&index=13&t=256s&pp=gAQBiAQB)

If you come across this git repo first we encourage you to watch this video before attempting the code below. []()

- Insert the following XML file into your database. []()

- Run the following queries to test the upload. 
```
SELECT ID, PurchaseOrder.* FROM STAGE_XML, XMLTABLE('/PurchaseOrder'  PASSING STAGE_XML.xml_col
    COLUMNS
        PONumber VARCHAR2(30) PATH '@PurchaseOrderNumber',
        OrderDate VARCHAR2(30) PATH '@OrderDate',
        shiptoName VARCHAR2(30) PATH 'Address[@Type="Shipping"]/Name',
        billingName VARCHAR2(30) PATH 'Address[@Type="Billing"]/Name',
        notes VARCHAR2(30) PATH 'DeliveryNotes'
        ) PurchaseOrder

SELECT ID, Items.* FROM STAGE_XML, XMLTABLE('/PurchaseOrder/Items/Item'  PASSING STAGE_XML.xml_col
    COLUMNS
        PartNumber VARCHAR2(30) PATH '@PartNumber',
        ProductName VARCHAR2(30) PATH 'ProductName',
        Quantity number(5) PATH 'Quantity',
        Price number(8,2) PATH 'USPrice',
        Notes VARCHAR2(30) PATH 'Comment'
         ) Items

SELECT PurchaseOrder.*, Items.*  FROM STAGE_XML, XMLTABLE('/PurchaseOrder/Items/Item'  PASSING STAGE_XML.xml_col
    COLUMNS
        PartNumber VARCHAR2(30) PATH '@PartNumber',
        ProductName VARCHAR2(30) PATH 'ProductName',
        Quantity number(5) PATH 'Quantity',
        Price number(8,2) PATH 'USPrice',
        Notes VARCHAR2(30) PATH 'Comment'
         ) Items, 
         XMLTABLE('/PurchaseOrder'  PASSING STAGE_XML.xml_col
    COLUMNS
        PONumber VARCHAR2(30) PATH '@PurchaseOrderNumber',
        OrderDate VARCHAR2(30) PATH '@OrderDate',
        shiptoName VARCHAR2(30) PATH 'Address[@Type="Shipping"]/Name',
        billingName VARCHAR2(30) PATH 'Address[@Type="Billing"]/Name',
        notes VARCHAR2(30) PATH 'DeliveryNotes'
        ) PurchaseOrder
```
- In the past json could be created leveraging a number of api's one of the most popular being
```
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
```

- Leveraging the undocumented APO XMLtoJSON. WIP
```
select id, XMLTOJSON(XML_COL) JSON_OUTPUT from STAGE_XML
```
