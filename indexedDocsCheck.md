## This file contains some sample code on how to quickly tell how many documents have been indexed by Oracle Text, if any are still in the pending state.

- First we will query to see the tables with existing Oracle Text indexes. Notice the column IDX_DOCID_COUNT represents the number of documents currently indexed. See Oracle Text views for full spec. [https://docs.oracle.com/en/database/oracle/oracle-database/21/ccref/oracle-text-views.html](https://docs.oracle.com/en/database/oracle/oracle-database/21/ccref/oracle-text-views.html)
![](assets/indexedDocsCheck-0673052d.png)

```
select * from CTX_USER_INDEXES where idx_name = 'SEARCHMYDOCS';
```

- Next we will query out table to find out the number of documents.
![](assets/indexedDocsCheck-1efbcd19.png)
```
select count(*) from resume;
```

- To index the documents we need to run the following command.
```
alter index SEARCHMYDOCS rebuild online noparallel;
```

- Requery the CTX_USER_INDEXES view to see the number of indexed docs.
![](assets/indexedDocsCheck-7fabc7a3.png)
```
select * from CTX_USER_INDEXES where idx_name = 'SEARCHMYDOCS';
```

- To figure out the number of documents that need to be indexed issue the following query.
```
select IDX_DOCID_COUNT - (select count(*) from resume where resume is not null) "Documents to be Indexed" from CTX_USER_INDEXES where idx_name = 'SEARCHMYDOCS';
```
