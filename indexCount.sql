--Code to see how many docs need indexing and display or not display the rebuild button
begin

select (select count(query_id) from filtered_docs) - (select count(r.doc_id) from resume r)
 into needIndexing from dual;

 if needIndexing > 0 then
 return true;
 else
 return false;
 end if;

end;
