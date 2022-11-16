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

-- Multi-Item Query for Extended Attributes

```
SELECT ID, m.messageID, m.customerorderid, m.OMSORDERID, ea.name, ea.description, ea.value
 FROM STAGE_XML, XMLTABLE('/OrdersToFulfill'  PASSING STAGE_XML.xml_col COLUMNS
MessageId varchar2(30) PATH 'MessageHeader/MessageData/MessageId',
CUSTOMERORDERID VARCHAR2(255) PATH 'Order/OrderHeader/CustomerOrderId',
OMSORDERID  VARCHAR2(40)  PATH 'Order/OrderHeader/OMSOrderId'
) m,
XMLTABLE('/OrdersToFulfill/Order/OrderDetail/ItemId/ExtendedAttributes'  PASSING STAGE_XML.xml_col COLUMNS
name varchar2(30) PATH 'Name',
description varchar2(30) PATH 'Description',
value varchar2(30) PATH 'Value'
) ea
```

-- multi-row parse for INVOICE
```
SELECT ID, m.messageID, m.customerorderid, m.OMSORDERID, ia.amounttype, ia.monetaryamount, ia.currencycode
 FROM STAGE_XML, XMLTABLE('/OrdersToFulfill'  PASSING STAGE_XML.xml_col COLUMNS
MessageId varchar2(30) PATH 'MessageHeader/MessageData/MessageId',
CUSTOMERORDERID VARCHAR2(255) PATH 'Order/OrderHeader/CustomerOrderId',
OMSORDERID  VARCHAR2(40)  PATH 'Order/OrderHeader/OMSOrderId'
) m,
XMLTABLE('/OrdersToFulfill/Order/OrderHeader/InvoiceAmount'  PASSING STAGE_XML.xml_col COLUMNS
amounttype varchar2(30) PATH 'Amount/AmountType',
monetaryamount varchar2(30) PATH 'Amount/MonetaryAmount',
currencycode varchar2(30) PATH 'Amount/CurrencyCode'
) ia
```
