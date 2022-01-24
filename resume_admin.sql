create or replace package resume_admin as
procedure Truncate_Table (p_tname in varchar2);
procedure Create_Theme (p_doc_id in docs.doc_id%type);
procedure Create_Full_Theme (p_doc_id in docs.doc_id%type);
procedure Create_Gist (p_doc_id in docs.doc_id%type);
procedure Create_Filtered_Doc (p_doc_id in docs.doc_id%type);

procedure Batch_Create_Themes;
procedure Batch_Create_Full_Themes;
procedure Batch_Create_Gists;
procedure Batch_Create_Filtered_Docs;

end Doc_Admin;
/
show errors
/

create or replace package body resume_admin as

--------------------------
-- private sub programs --
--------------------------
procedure Truncate_Table (p_tname in varchar2) is
	pragma autonomous_transaction;
	p_stmt	varchar2(100) := 'truncate table ' || p_tname;
begin
	execute immediate p_stmt;
end Truncate_Table;

------------------------
-- public subprograms --
------------------------
procedure Create_Theme (p_doc_id in docs.doc_id%type) is
begin
	ctx_doc.themes ('searchMyDocs', p_doc_id, 'themes', p_doc_id, full_themes => false);
end Create_Theme;

procedure Create_Full_Theme (p_doc_id in docs.doc_id%type) is
begin
	ctx_doc.themes ('searchMyDocs', p_doc_id, 'full_themes', p_doc_id, full_themes => true);
end Create_Full_Theme;

procedure Create_Gist (p_doc_id in docs.doc_id%type) is
begin
	 ctx_doc.gist('searchMyDocs', p_doc_id, 'gists',p_doc_id,'P', pov =>'GENERIC'); -
end Create_Gist;


procedure Create_Filtered_Doc (p_doc_id in docs.doc_id%type) is
begin
	ctx_doc.filter ('searchMyDocs', p_doc_id, 'filtered_docs', p_doc_id, plaintext => true);
end Create_Filtered_Doc;

procedure Batch_Create_Themes is
begin
	Truncate_Table ('themes');
	for x in (select doc_id from docs) loop
		Create_Theme (x.doc_id);
	end loop;
end Batch_Create_Themes;

procedure Batch_Create_Full_Themes is
begin
	Truncate_Table('full_themes');
	for x in (select doc_id from docs) loop
		Create_Full_Theme (x.doc_id);
	end loop;
end Batch_Create_Full_Themes;

procedure Batch_Create_Gists is
begin
	Truncate_Table ('gists');
	for x in (select doc_id from docs) loop
		Create_Gist (x.doc_id);
	end loop;
end Batch_Create_Gists;

procedure Batch_Create_Filtered_Docs is
begin
	Truncate_Table ('filtered_docs');
	for x in (select doc_id from docs) loop
		Create_Filtered_Doc (x.doc_id);
	end loop;
end Batch_Create_Filtered_Docs;


end resume_admin;
/
show errors
/
