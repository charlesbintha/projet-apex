prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
-- Application 102 - Service Desk Lite
-- Shared Component - Service Desk Navigation
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

prompt --application/shared_components/navigation/lists/service_desk_navigation
begin
wwv_flow_imp_shared.create_list(
 p_id=>wwv_flow_imp.id(102800000000000)
,p_name=>'Service Desk Navigation'
,p_static_id=>'service-desk-navigation'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(102800000000001)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>'Tableau de bord'
,p_static_id=>'dashboard'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&SESSION.::&DEBUG.::::'
,p_list_item_icon=>'fa-home'
,p_list_item_current_type=>'COLON_DELIMITED_PAGE_LIST'
,p_list_item_current_for_pages=>'1'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(102800000000010)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'Tickets'
,p_static_id=>'tickets'
,p_list_item_link_target=>'f?p=&APP_ID.:10:&SESSION.::&DEBUG.::::'
,p_list_item_icon=>'fa-list'
,p_list_item_current_type=>'COLON_DELIMITED_PAGE_LIST'
,p_list_item_current_for_pages=>'10,20'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(102800000000020)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>'Nouveau ticket'
,p_static_id=>'new-ticket'
,p_list_item_link_target=>'f?p=&APP_ID.:11:&SESSION.::&DEBUG.::::'
,p_list_item_icon=>'fa-plus-circle'
,p_list_item_current_type=>'COLON_DELIMITED_PAGE_LIST'
,p_list_item_current_for_pages=>'11'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(102800000000030)
,p_list_item_display_sequence=>40
,p_list_item_link_text=>'Mes taches'
,p_static_id=>'my-tasks'
,p_list_item_link_target=>'f?p=&APP_ID.:30:&SESSION.::&DEBUG.::::'
,p_list_item_icon=>'fa-tasks'
,p_list_item_current_type=>'COLON_DELIMITED_PAGE_LIST'
,p_list_item_current_for_pages=>'30,31'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(102800000000040)
,p_list_item_display_sequence=>50
,p_list_item_link_text=>'Suivi des workflows'
,p_static_id=>'workflow-monitoring'
,p_list_item_link_target=>'f?p=&APP_ID.:32:&SESSION.::&DEBUG.::::'
,p_list_item_icon=>'fa-workflow'
,p_list_item_current_type=>'COLON_DELIMITED_PAGE_LIST'
,p_list_item_current_for_pages=>'32'
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
