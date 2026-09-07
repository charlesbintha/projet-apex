-- Installation initiale de Service Desk Lite dans le schéma DEV TESTCL.
-- Ce script refuse toute autre cible et refuse une réinstallation destructive.

set define off
set serveroutput on
set verify off
whenever sqlerror exit failure rollback

prompt ============================================================
prompt Controle de la cible de deploiement
prompt ============================================================

declare
  l_sd_object_count pls_integer;
begin
  if user <> 'TESTCL' then
    raise_application_error(
      -20001,
      'Cible refusee. Utilisateur courant=' || user || ', cible attendue=TESTCL.'
    );
  end if;

  select count(*)
    into l_sd_object_count
    from user_objects
   where object_name like 'SD\_%' escape '\';

  if l_sd_object_count > 0 then
    raise_application_error(
      -20002,
      'Installation initiale refusee: ' || l_sd_object_count ||
      ' objet(s) SD_* existe(nt) deja dans TESTCL.'
    );
  end if;

  dbms_output.put_line('Cible confirmee: TESTCL');
  dbms_output.put_line('Aucun objet SD_* existant. Installation autorisee.');
end;
/

prompt ============================================================
prompt Installation du schema Service Desk Lite
prompt ============================================================

@@01_service_desk_lite_schema.sql

prompt ============================================================
prompt Installation des extensions workflow
prompt ============================================================

@@02_service_desk_workflow.sql

prompt ============================================================
prompt Verification finale
prompt ============================================================

@@tests/00_verify_install.sql

prompt Installation initiale terminee dans TESTCL.
