prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
-- Application 102 - Service Desk Lite
-- Correctif des parametres des taches creees par le workflow
-- Target APEX 26.1.4
--------------------------------------------------------------------------------
begin
wwv_flow_imp.import_begin (
 p_version_yyyy_mm_dd=>'2026.03.30'
,p_release=>'26.1.4'
,p_default_workspace_id=>8281986417106891
,p_default_application_id=>102
,p_default_id_offset=>0
,p_default_owner=>'WKSP_DEVSEN'
);
end;
/

prompt APPLICATION 102 - Service Desk Lite

prompt --application/shared_components/workflow/workflows/ticket_lifecycle/task_parameters_fix
begin
wwv_flow_imp_shared.create_task_def_comp_param(
 p_id=>wwv_flow_imp.id(102900000000320)
,p_workflow_activity_id=>wwv_flow_imp.id(102900000000202)
,p_task_def_param_id=>wwv_flow_imp.id(102900000000002)
,p_value_type=>'STATIC'
,p_value=>'0'
);
wwv_flow_imp_shared.create_task_def_comp_param(
 p_id=>wwv_flow_imp.id(102900000000321)
,p_workflow_activity_id=>wwv_flow_imp.id(102900000000205)
,p_task_def_param_id=>wwv_flow_imp.id(102900000000011)
,p_value_type=>'STATIC'
,p_value=>'#NOT_SET#'
);
end;
/

prompt --application/end_environment
begin
wwv_flow_imp.import_end(
 p_auto_install_sup_obj=>nvl(
   wwv_flow_application_install.get_auto_install_sup_obj,
   false
 )
);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
