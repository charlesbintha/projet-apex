-- SQLcl : @database/migrations/V001__ajout_reference_externe.sql TEST_ENV
-- Meme fichier en production simulee, apres approbation : ... PROD_ENV
-- Executer dans une session dediee, sans transaction metier en cours.
-- Ne plus modifier ce fichier apres sa premiere livraison.
set define on
set serveroutput on
whenever sqlerror exit failure rollback

declare
  l_expected varchar2(128) := upper('&1');
  l_count    pls_integer;
begin
  if l_expected not in ('TEST_ENV', 'PROD_ENV')
     or sys_context('USERENV', 'SESSION_USER') <> l_expected
     or sys_context('USERENV', 'CURRENT_SCHEMA') <> l_expected then
    raise_application_error(-20001, 'Mauvais compte ou schema cible.');
  end if;
  select count(*) into l_count from user_tables
   where table_name = 'SD_TICKETS';
  if l_count <> 1 then
    raise_application_error(-20002, 'Table SD_TICKETS absente.');
  end if;
  select count(*) into l_count from user_tables
   where table_name = 'SD_SCHEMA_MIGRATIONS';
  if l_count = 0 then
    execute immediate 'create table sd_schema_migrations (
      version varchar2(30) primary key,
      script_name varchar2(255) not null,
      applied_at timestamp with time zone default systimestamp not null,
      applied_by varchar2(128) not null
    )';
  end if;
end;
/

declare
  l_logged pls_integer;
  l_exists pls_integer;
  l_valid  pls_integer;
begin
  select count(*) into l_logged from sd_schema_migrations
   where version = 'V001';
  select count(*), count(case
    when data_type = 'VARCHAR2' and char_length = 100
     and char_used = 'C' and nullable = 'Y' then 1 end)
    into l_exists, l_valid
    from user_tab_columns
   where table_name = 'SD_TICKETS' and column_name = 'REFERENCE_EXTERNE';

  if l_logged = 1 then
    if l_valid <> 1 then
      raise_application_error(-20003, 'V001 journalisee mais colonne non conforme.');
    end if;
    dbms_output.put_line('V001 deja appliquee : colonne conforme, aucune modification.');
  else
    if l_exists <> 0 then
      raise_application_error(-20004,
        'Colonne deja presente sans journal V001 : reconciliation manuelle requise.');
    end if;
    execute immediate
      'alter table sd_tickets add reference_externe varchar2(100 char)';
    insert into sd_schema_migrations(version, script_name, applied_by)
    values ('V001', 'V001__ajout_reference_externe.sql',
            sys_context('USERENV', 'SESSION_USER'));
    commit;
    dbms_output.put_line('V001 appliquee et journalisee.');
  end if;
end;
/
undefine 1
