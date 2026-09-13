-- Test en lecture seule. A lancer apres V001, dans le meme schema.
set serveroutput on
whenever sqlerror exit failure rollback
declare
  l_count pls_integer;
begin
  select count(*) into l_count from user_tab_columns
   where table_name = 'SD_TICKETS'
     and column_name = 'REFERENCE_EXTERNE'
     and data_type = 'VARCHAR2'
     and char_length = 100 and char_used = 'C' and nullable = 'Y';
  if l_count <> 1 then
    raise_application_error(-20010, 'Colonne absente ou non conforme.');
  end if;
  select count(*) into l_count from sd_schema_migrations
   where version = 'V001'
     and script_name = 'V001__ajout_reference_externe.sql';
  if l_count <> 1 then
    raise_application_error(-20011, 'Journal V001 absent ou non conforme.');
  end if;
  dbms_output.put_line('OK : REFERENCE_EXTERNE VARCHAR2(100 CHAR), nullable, V001 journalisee.');
end;
/
select version, script_name, applied_at, applied_by
from sd_schema_migrations order by applied_at;

-- Une evolution DDL peut invalider des dependances : verifier ce resultat.
select object_name, object_type, status
from user_objects where status = 'INVALID'
order by object_type, object_name;
