## Rapid Data Load and Manipulation in APEX

In this example we will take look at a very common scenario in which a business user provides a member of IT a spreadsheet list of data. The list is intended to guide IT on a new report or application action. IT needs to consume the spreadsheet then programmatically generate code that can be leveraged in an application. In this example the core need is for a Oracle Analytics Cloud Data Visualizer Calculation to filter all the rows with certain global id's. 

- Please what this video for details on how to execute the example below. []()

- For this example we will leverage the [example_data.csv](example_data.csv) as our input file.

- Our desired output filter will look like, only it will include :

```
CASE WHEN "DV - SE Team"."Customer"."Oracle Global Ultimate ID" IN ('1259193') THEN 'P1'
WHEN "DV - SE Team"."Customer"."Oracle Global Ultimate ID" IN ('1257516') THEN 'P2'
WHEN "DV - SE Team"."Customer"."Oracle Global Ultimate ID" IN ('3687527') THEN 'P3'
WHEN "DV - SE Team"."Customer"."Oracle Global Ultimate ID" IN ('11724079') THEN 'P4'
WHEN "DV - SE Team"."Customer"."Oracle Global Ultimate ID" IN ('4511969') THEN 'P5'
ELSE '-' END
```

-- Example Query to gauge the number of records that should be a part of the query. 

```
select count(*) from ACCOUNT_PRIORITY where PGM_ACCT_PRIORITY is not null
```

-- Get number of IDs by priority accounts
```
select PGM_ACCT_PRIORITY, count(*)
 from ACCOUNT_PRIORITY where PGM_ACCT_PRIORITY is not null group by PGM_ACCT_PRIORITY order by PGM_ACCT_PRIORITY
```

-- Example Code to Generate Desired filter output. 

```
declare
-- core CLOB to hold the needed transformation
v_calc clob;
v_guid account_priority.END_USER_ORCL_GLB_ULT_REG_ID%type;

CURSOR P1 IS select ''''|| END_USER_ORCL_GLB_ULT_REG_ID ||'''' from ACCOUNT_PRIORITY where PGM_ACCT_PRIORITY = 1;

CURSOR P2 IS select ''''|| END_USER_ORCL_GLB_ULT_REG_ID ||'''' from ACCOUNT_PRIORITY where PGM_ACCT_PRIORITY = 2;

CURSOR P3 IS select ''''|| END_USER_ORCL_GLB_ULT_REG_ID ||'''' from ACCOUNT_PRIORITY where PGM_ACCT_PRIORITY = 3;

CURSOR P4 IS select ''''|| END_USER_ORCL_GLB_ULT_REG_ID ||'''' from ACCOUNT_PRIORITY where PGM_ACCT_PRIORITY = 4;

CURSOR P5 IS select ''''|| END_USER_ORCL_GLB_ULT_REG_ID ||'''' from ACCOUNT_PRIORITY where PGM_ACCT_PRIORITY = 5;

begin
-- Start CLOB variable construction 
v_calc := 'CASE WHEN "DV - SE Team"."Customer"."Oracle Global Ultimate ID" IN ( ';

OPEN P1; 
   LOOP 
   FETCH P1 into v_guid; 
      EXIT WHEN P1%notfound; 
      v_calc := v_calc||v_guid||', '; 
   END LOOP; 
   CLOSE P1; 

-- Trim last x2 characters from clob, then close first evaluation in block
v_calc := substr(v_calc, 1, length(v_calc)-2) || ') THEN ''P1'' WHEN "DV - SE Team"."Customer"."Oracle Global Ultimate ID" IN ( ';

-- Add P2 Accounts
OPEN P2; 
   LOOP 
   FETCH P2 into v_guid; 
      EXIT WHEN P2%notfound; 
      v_calc := v_calc||v_guid||', '; 
   END LOOP; 
   CLOSE P2;

-- Trim last x2 characters from clob, then close first evaluation in block
v_calc := substr(v_calc, 1, length(v_calc)-2) || ') THEN ''P2'' WHEN "DV - SE Team"."Customer"."Oracle Global Ultimate ID" IN ( ';

-- Add P3 Accounts
OPEN P3; 
   LOOP 
   FETCH P3 into v_guid; 
      EXIT WHEN P3%notfound; 
      v_calc := v_calc||v_guid||', '; 
   END LOOP; 
   CLOSE P3;

-- Trim last x2 characters from clob, then close first evaluation in block
v_calc := substr(v_calc, 1, length(v_calc)-2) || ') THEN ''P3'' WHEN "DV - SE Team"."Customer"."Oracle Global Ultimate ID" IN ( ';

-- Add P4 Accounts
OPEN P4; 
   LOOP 
   FETCH P4 into v_guid; 
      EXIT WHEN P4%notfound; 
      v_calc := v_calc||v_guid||', '; 
   END LOOP; 
   CLOSE P4;
-- Trim last x2 characters from clob, then close first evaluation in block
v_calc := substr(v_calc, 1, length(v_calc)-2) || ') THEN ''P4'' WHEN "DV - SE Team"."Customer"."Oracle Global Ultimate ID" IN ( ';

-- Add P5 Accounts
OPEN P5; 
   LOOP 
   FETCH P5 into v_guid; 
      EXIT WHEN P5%notfound; 
      v_calc := v_calc||v_guid||', '; 
   END LOOP; 
   CLOSE P5;
-- Trim last x2 characters from clob, then close first evaluation in block
v_calc := substr(v_calc, 1, length(v_calc)-2) || ') THEN ''P5'' ELSE ''-'' END ';

dbms_output.put_line(v_calc);
end;
```