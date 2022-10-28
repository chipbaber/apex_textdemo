## Processing trigger after insert on table


Core trigger for the on insert processing

```
CREATE OR REPLACE TRIGGER message_processing AFTER INSERT ON stage_xml FOR EACH ROW
DECLARE
v_messageId varchar2(30);
/*
CURSOR setBillTo IS
   SELECT MESSAGEID, CUSTOMERID,FULLNAME,FIRSTNAME,LASTNAME,EMAILADDRESS,PREFERREDLANGUAGECODE FROM V_BILLTO
   where
   */
BEGIN
  select messageId into v_messageId from v_orderheader where id = :new.id;
  log_action(v_messageId,'Beginning to process message.');



END;
/
```

log procedure to
```
create or replace procedure log_action(messageId in varchar2, v_action in varchar2) as
BEGIN
insert into processing_log (MESSAGE_ID, ACTION, log_time) values (messageId, v_action, systimestamp);
commit;
EXCEPTION
WHEN OTHERS
THEN
rollback;
end;
```
