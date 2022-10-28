## Sample XML queries

-- Core Query to get the data for the MESSAGEHEADER Table
```
create or replace view v_messageheader as
SELECT ID, MESSAGEHEADER.* FROM STAGE_XML, XMLTABLE('/OrdersToFulfill'  PASSING STAGE_XML.xml_col
    COLUMNS
        std VARCHAR2(30) PATH 'MessageHeader/Standard',
        headerversion NUMBER(6,2) PATH 'MessageHeader/HeaderVersion',
        VersionReleaseNumber NUMBER(6,2) PATH 'MessageHeader/VersionReleaseNumber',
        SourceId varchar2(30) PATH 'MessageHeader/SourceData/SourceId',
        SourceType varchar2(30) PATH 'MessageHeader/SourceData/SourceType',
        DestinationId varchar2(30) PATH 'MessageHeader/DestinationData/DestinationId',
        DestinationType varchar2(30) PATH 'MessageHeader/DestinationData/DestinationType',
        EventType varchar2(30) PATH 'MessageHeader/EventType',
        MessageId varchar2(30) PATH 'MessageHeader/MessageData/MessageId',
        CorrelationId varchar2(30) PATH 'MessageHeader/MessageData/CorrelationId',
        CreateDateAndTime varchar2(30) PATH 'MessageHeader/CreateDateAndTime'
        ) MESSAGEHEADER
```

-- Order header
```
create or replace view v_orderheader as
SELECT ID, ORDERHEADER.* FROM STAGE_XML, XMLTABLE('/OrdersToFulfill'  PASSING STAGE_XML.xml_col COLUMNS
MessageId varchar2(30) PATH 'MessageHeader/MessageData/MessageId',
CATALOGID   VARCHAR2(255) PATH 'Order/OrderHeader/ExtendedAttributes[Name="CatalogId"]/Value',
CLIENTID       VARCHAR2(255) PATH 'Order/OrderHeader/ClientId',
CUSTOMERORDERID VARCHAR2(255) PATH 'Order/OrderHeader/CustomerOrderId',
FACILITYID  VARCHAR2(255) PATH 'Order/OrderHeader/FacilityId',
FULFILLMENTCHANNEL VARCHAR2(255) PATH 'Order/OrderHeader/FulfillmentChannel',
ORDERTYPE         VARCHAR2(255) PATH 'Order/OrderHeader/OrderType',
OMSORDERID  VARCHAR2(40)  PATH 'Order/OrderHeader/OMSOrderId',
SPLITORDERINDICATOR   VARCHAR2(255)  PATH 'Order/OrderHeader/SplitOrderIndicator',
ORDERENTRYDATETIME VARCHAR2(255) PATH 'Order/OrderHeader/OrderEntryDateTime',
INVOICECREATEDATETIME  VARCHAR2(255) PATH 'Order/OrderHeader/InvoiceCreateDateTime',
PROMISESHIPDATE      VARCHAR2(255)  PATH 'Order/OrderHeader/PromiseShipDate',
PROMISERECEIPTDATE  VARCHAR2(255) PATH 'Order/OrderHeader/PromiseReceiptDate',
LOCALE   VARCHAR2(255) PATH 'Order/OrderHeader/Locale',
GSI_STORE_ID       VARCHAR2(255) PATH 'Order/OrderHeader/ExtendedAttributes[Name="gsi_store_id"]/Value',
GSI_CLIENT_ID   VARCHAR2(255)  PATH 'Order/OrderHeader/ExtendedAttributes[Name="gsi_client_id"]/Value'
) ORDERHEADER
```

--- Missing elements in XML for reference
CATALOGIDORDER VARCHAR2(40)  
CLIENTIDORDER  VARCHAR2(40)
CUSTOMERORDERIDORDER VARCHAR2(40)
DELIVERYINSTRUCTIONS VARCHAR2(255)
DELIVERYINSTRUCTIONSORDER VARCHAR2(40)  
EXPEDITEDORDERINDICATOR  VARCHAR2(255)
EXPEDITEDORDERINDICATORORDER VARCHAR2(40)  
EXTERNALREFERENCEFACILITYID  VARCHAR2(255)
EXTERNALREFERENCEFACILITYIDORDER VARCHAR2(40)  
EXTERNALSHIPMENTID  VARCHAR2(255)
EXTERNALSHIPMENTIDORDER  VARCHAR2(40)  
FACILITYIDORDER  VARCHAR2(40)  
FULFILLMENTCHANNELORDER VARCHAR2(40)  
GSI_CLIENT_IDORDER VARCHAR2(40)  
GSI_STORE_IDORDER  VARCHAR2(40)  
INVOICECREATEDATETIMEORDER VARCHAR2(40)  
LOCALEORDER VARCHAR2(40)  
OMSORDERIDORDER VARCHAR2(40)  
ORDERENTRYDATETIMEORDER  VARCHAR2(40)  
ORDERHEADERORDER   VARCHAR2(40)  
ORDERHEADERPK     VARCHAR2(40)  
ORDERTYPEORDER     VARCHAR2(40)  
ORDER_FK           VARCHAR2(40)  
PROMISERECEIPTDATEORDER  VARCHAR2(40)  
PROMISESHIPDATEORDER  VARCHAR2(40)  
PURCHASEORDERNUMBER    VARCHAR2(255)
PURCHASEORDERNUMBERORDER   VARCHAR2(40)  
RETURNORDERNUMBER    VARCHAR2(255)
RETURNORDERNUMBERORDER VARCHAR2(40)  
SPLITORDERINDICATORORDER VARCHAR2(40)  
VATINVOICENUMBER      VARCHAR2(255)
VATINVOICENUMBERORDER   VARCHAR2(40)


-- Bill to
```
create or replace view v_billto as
SELECT ID, BILLTO.* FROM STAGE_XML, XMLTABLE('/OrdersToFulfill'  PASSING STAGE_XML.xml_col COLUMNS
MessageId varchar2(30) PATH 'MessageHeader/MessageData/MessageId',
CUSTOMERID  VARCHAR2(255) PATH 'Order/OrderHeader/BillTo/CustomerId',
FULLNAME    VARCHAR2(255) PATH 'Order/OrderHeader/BillTo/FullName',
FIRSTNAME   VARCHAR2(255) PATH 'Order/OrderHeader/BillTo/FirstName',
LASTNAME   VARCHAR2(255)  PATH 'Order/OrderHeader/BillTo/LastName',
EMAILADDRESS  VARCHAR2(255) PATH 'Order/OrderHeader/BillTo/EmailAddress',
PREFERREDLANGUAGECODE   VARCHAR2(255) PATH 'Order/OrderHeader/BillTo/PreferredLanguageCode'
) BillTO
```
BILLTOORDER VARCHAR2(20)  
BILLTOPK  VARCHAR2(20)  
CUSTOMERIDORDER  VARCHAR2(20)  
EMAILADDRESSORDER  VARCHAR2(50)  
FIRSTNAMEORDER  VARCHAR2(50)  
FULLNAMEORDER   VARCHAR2(20)  
LASTNAMEORDER  VARCHAR2(20)  
ORDERHEADERFK   VARCHAR2(20)  
PREFERREDLANGUAGECODEORDER  VARCHAR2(20)  
SALUTATION     VARCHAR2(255)
SALUTATIONORDER  VARCHAR2(20)   
