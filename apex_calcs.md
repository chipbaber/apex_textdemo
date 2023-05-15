## Three Approaches to Developing Excel Calculations in APEX

In this brief tutorial we will take a look at three approaches for replicating excel calculations inside Oracle APEX. The first will focus on end users, enabling access to data online and providing out of the box functionality to create calculations. The second is a bit more advanced and will leverage SQL Worksheet to create virtual columns on the core table with equations that calculate on query. The third is the most advanced and showcases how to create a function for a calculation. Functions will enable you to pull information from other tables (tabs in excel) and easily calculate results.

### Example 1: Oracle APEX: Replicate an Excel Calculation inside a Interactive Report
We will begin by taking a look at a sample excel spreadsheet called Fall_Stats.xlsx. We will make a copy as a .csv, remove the calculation columns and upload into Oracle APEX. Once uploaded we will create a new page in a sample application with a interactive report. Inside the interactive report we will show you how a end user can easily replicate a calculation in excel inside Oracle APEX. We will also showcase how one can save calculations in personal versions of the interactive report for future use. 

If you would like to follow along in this tutorial please access the sample excel here [](). Please watch this tutorial video. 

### Example 2: Oracle APEX: Replicating Excel Calculation with Virtual Columns
In our example we could use this table in many parts of a application. Lets take a look at how an Oracle APEX developer can replicate excel calculations at the table level inside Oracle virtual columns. We wil start by repeating our simple batting average calculation from Example 1. Then add two slightly more advanced calculations for on base percentage (OBP) and slugging (SLG). Last but not least we will touch on a limitation of this approach. You are not able to leverage virtual columns inside other virtual column calculations. For example the baseball stat OPS is a combination of both OBP and SLG. Trying to calculate this as a virtual column will generate a  ORA-54012. Don't worry though, part three of this series shows how to build for scenarios like this leveraging Oracle functions. 

Please watch the following video for more guidance. 

```
select * from teamstats
select name, round(H/AB,3) avg from teamstats
```

```
ALTER TABLE teamstats
ADD (avg AS (round(H/AB,3)));
```

- test the virtual column
```
select name, avg from teamstats
```

- Test Query for OBP and slg
```
select name, ROUND((H+BB+HBP)/(AB+BB+HBP+SAC),3) obp, ROUND(TB/AB,3) slg from teamstats
```

- Add two more virtual columns
```
ALTER TABLE teamstats
ADD (obp AS (ROUND((H+BB+HBP)/(AB+BB+HBP+SAC),3)),
slg AS (ROUND(TB/AB,3)));
```

- Test the columns
```
select name, avg, obp, slg from teamstats
```

- Example to fix formatting
```
select a.name, to_char(a.slg,'FM99999.000') from teamstats a
```

- So what happens when you try to leverage virtual columns in calculations, queries work but ...
```
select name, ROUND(OBP+SLG,3) OPS from teamstats
```

- Virtual columns on virtual columns won't work. You will get a ORA-54012: virtual column is referenced in a column expression
```
ALTER TABLE teamstats
ADD (OPS AS (ROUND(OBP+SLG,3)));
```

### Example 3: Replicating Excel Calculations with Functions in Oracle APEX
In part 3 of this series we are going to leverage functions to create calculations commonly performed in excel. Functions are programmatic in nature and provide a means for quering other tables, pulling in that data and then working with variables to really perform almost any formula provided in excel. The end result of a function is a single output, just like a cell in Excel. Our example today will begin by calculating OPS based off 2 virtual columns created in video 2 above. We will then showcase how you can call the function in a query. After that we will construct a slighlty more advanced function where we will calculate the team batting average, then compare to a players batting average and output the points above or below the team average the player is. Finally we will demonstrate how to create a view to hide the complexity of the virtual columns and functions for easy consumption and development inside Oracle APEX. 

- Creating a function for the OPS calculation. 

```
CREATE OR REPLACE Function ops ( slg IN number, ops IN number ) RETURN number
IS 
v_ops number;
BEGIN
v_ops := slg + ops;
RETURN v_ops;
EXCEPTION
WHEN OTHERS THEN
   raise_application_error(-20001,'An error was encountered calculating OPS - '||SQLCODE||' -ERROR- '||SQLERRM);
END;
```

- Test your OPS function
```
select a.name, ops(a.slg, a.obp) OPS from teamstats a
```

- Add formatting around your OPS function
```
select a.name, to_char(ops(a.slg, a.obp),'FM9.000') OPS from teamstats a
```

- Create a view including your new function
```
create or replace view v_teamstats as select a.name, avg, slg, obp, ops(a.slg, a.obp) ops from teamstats a
```

- Query View
```
select * from v_teamstats
```

- Now for something a little more complex. Get the team batting avg, show players performance above or below team avg. 

```
CREATE OR REPLACE Function avgRating(v_avg in number) RETURN number
IS 
v_rating number;
v_teamavg number;
BEGIN
--get the team avg from the table
select round(sum(h)/sum(ab),3) into v_teamavg from teamstats;

--see how much player is above or below the team avg
v_rating := v_avg - v_teamavg;
RETURN v_rating;
EXCEPTION
WHEN OTHERS THEN
   raise_application_error(-20001,'An error was encountered player performance above team avg - '||SQLCODE||' -ERROR- '||SQLERRM);
END;
```

- Test function
```
select a.name, a.avg, avgRating(a.avg) Batting_Ranking from teamstats a
```

- Update view
```
create or replace view v_teamstats as select a.name, avg, slg, obp, ops(a.slg, a.obp) ops, avgRating(a.avg) Team_Avg_Rating from teamstats a
```

- Query View
```
select * from v_teamstats
```