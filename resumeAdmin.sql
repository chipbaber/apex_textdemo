/*
* Package: resumeAdmin
* This package serves to automate the task of creating indexs for Oracle Text and some of the more advanced queries including
* themes, full themes, gists and filtered_docs.
*
**/
create or replace package resumeAdmin as
procedure Truncate_Table (p_tname in varchar2);

procedure Create_Theme (p_doc_id in resume.doc_id%type);
procedure Create_Full_Theme (p_doc_id in resume.doc_id%type);
procedure Create_Gist (p_doc_id in resume.doc_id%type);
procedure Create_Filtered_Doc (p_doc_id in resume.doc_id%type);

procedure Batch_Create_Themes;
procedure Batch_Create_Full_Themes;
procedure Batch_Create_Gists;
procedure Batch_Create_Filtered_Docs;

end resumeAdmin;
/

create or replace package body resumeAdmin as

	/*-----------------------
	Procedures to truncate a indexing table before creation of a new action on the table passing in the name of the table to truncate inside a
	dynamic sql statement.
	-----------------------*/
procedure Truncate_Table(p_tname in varchar2) is
	pragma autonomous_transaction;
	p_stmt	varchar2(100) := 'truncate table ' || p_tname;
begin
	execute immediate p_stmt;
	EXCEPTION
  WHEN others THEN
    DBMS_OUTPUT.PUT_LINE('Error in Truncate_table procedure.');
end Truncate_Table;

/*-----------------------
Procedures to perform a thematic indexing action on a single document.
-----------------------*/
procedure Create_Theme(p_doc_id in resume.doc_id%type) is
begin
	ctx_doc.themes('searchMyDocs', p_doc_id, 'themes', p_doc_id, full_themes => false);
  EXCEPTION
	WHEN others THEN
    DBMS_OUTPUT.PUT_LINE('Error in Create_Theme procedure.');
end Create_Theme;

/*-----------------------
Procedures to perform a full thematic indexing action on a single document.
-----------------------*/
procedure Create_Full_Theme(p_doc_id in resume.doc_id%type) is
begin
	ctx_doc.themes('searchMyDocs', p_doc_id, 'full_themes', p_doc_id, full_themes => true);
end Create_Full_Theme;

/*-----------------------
Procedures to perform a gist indexing action on a single document.
-----------------------*/
procedure Create_Gist(p_doc_id in resume.doc_id%type) is
begin
	 ctx_doc.gist('searchMyDocs', p_doc_id, 'gists',p_doc_id,'P', pov =>'GENERIC');
end Create_Gist;

/*-----------------------
Procedures to extract the text from a blob of types like pdf or docx and place inside a CLOB table column for faster retrieval.
-----------------------*/
procedure Create_Filtered_Doc(p_doc_id in resume.doc_id%type) is
begin
	ctx_doc.filter('searchMyDocs', p_doc_id, 'filtered_docs', p_doc_id, plaintext => true);
end Create_Filtered_Doc;

/*-----------------------
Procedures to perform a indexing action in a batch fashion on all blobs in a table these procedures are basic loops that
call back to the single document procedure actions above.
-----------------------*/

procedure Batch_Create_Themes is
begin
	Truncate_Table('themes');
	for x in (select doc_id from resume) loop
		Create_Theme(x.doc_id);
	end loop;
end Batch_Create_Themes;

procedure Batch_Create_Full_Themes is
begin
	Truncate_Table('full_themes');
	for x in (select doc_id from resume) loop
		Create_Full_Theme(x.doc_id);
	end loop;
end Batch_Create_Full_Themes;

procedure Batch_Create_Gists is
begin
	Truncate_Table('gists');
	for x in (select doc_id from resume) loop
		Create_Gist(x.doc_id);
	end loop;
end Batch_Create_Gists;

procedure Batch_Create_Filtered_Docs is
begin
	Truncate_Table('filtered_docs');
	for x in (select doc_id from resume) loop
		Create_Filtered_Doc(x.doc_id);
	end loop;
end Batch_Create_Filtered_Docs;


end resumeAdmin;
/
