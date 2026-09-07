prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
begin
wwv_flow_imp.import_begin(
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
begin null; end;
/
prompt --application/pages/delete_00032
begin
wwv_flow_imp_page.remove_page(p_flow_id=>wwv_flow.g_flow_id,p_page_id=>32);
end;
/
prompt --application/pages/page_00032
begin
wwv_flow_imp_page.create_page(
 p_id=>32
,p_name=>'Suivi des workflows'
,p_alias=>'SUIVI-WORKFLOWS'
,p_step_title=>'Suivi des workflows - Service Desk Lite'
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_css_file_urls=>'#APP_FILES#app.css'
,p_step_template=>4073832297226169690
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'23'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(102032000000001)
,p_plug_name=>'Suivi des workflows'
,p_static_id=>'workflows-breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useRegionTitle'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2532939663579242476
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_plug_item_display_point=>'ABOVE'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(86377528310063764)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>4073839682315169711
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(102032000000002)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(102032000000001)
,p_button_name=>'MY_TASKS'
,p_static_id=>'my-tasks'
,p_show_as_disabled=>false
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--iconLeft'
,p_button_template_id=>2084305881903810008
,p_button_image_alt=>'Mes taches'
,p_button_position=>'CREATE'
,p_button_redirect_url=>'f?p=&APP_ID.:30:&SESSION.::&DEBUG.:30'
,p_icon_css_classes=>'fa-clipboard-check-alt'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(102032000000005)
,p_name=>'P32_WORKFLOW_ID'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>10
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2('value_protected','Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(102032000000010)
,p_plug_name=>'Instances du workflow'
,p_static_id=>'workflow-instances'
,p_region_css_classes=>'sd-report-region'
,p_region_template_options=>'#DEFAULT#:t-Region--noPadding'
,p_plug_template=>4073835273271169698
,p_plug_display_sequence=>20
,p_plug_item_display_point=>'ABOVE'
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select workflow_id,',
'       workflow_def_name,',
'       title,',
'       initiator,',
'       state_code,',
'       created_on,',
'       last_updated_on,',
'       apex_page.get_url(',
'         p_page=>32,',
'         p_clear_cache=>''32'',',
'         p_items=>''P32_WORKFLOW_ID'',',
'         p_values=>workflow_id',
'       ) detail_url',
'  from table(apex_workflow.get_workflows(',
'         p_context=>''MY_WORKFLOWS'',',
'         p_application_id=>:APP_ID',
'       ))',
' order by created_on desc'))
,p_lazy_loading=>false
,p_plug_source_type=>'NATIVE_IR'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(102032000000011)
,p_max_row_count=>'1000000'
,p_no_data_found_message=>'Aucune instance de workflow disponible.'
,p_pagination_type=>'ROWS_X_TO_Y_OF_Z'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:XLSX:PDF'
,p_enable_mail_download=>'N'
,p_owner=>'CHARLES.BINTHA'
,p_internal_uid=>102032000000011
);
wwv_flow_imp_page.create_worksheet_column(p_id=>wwv_flow_imp.id(102032000000012),p_db_column_name=>'WORKFLOW_ID',p_display_order=>10,p_column_identifier=>'A',p_column_label=>'ID',p_column_type=>'NUMBER',p_display_text_as=>'HIDDEN_ESCAPE_SC');
wwv_flow_imp_page.create_worksheet_column(p_id=>wwv_flow_imp.id(102032000000013),p_db_column_name=>'WORKFLOW_DEF_NAME',p_display_order=>20,p_column_identifier=>'B',p_column_label=>'Workflow',p_column_type=>'STRING',p_heading_alignment=>'LEFT');
wwv_flow_imp_page.create_worksheet_column(p_id=>wwv_flow_imp.id(102032000000014),p_db_column_name=>'TITLE',p_display_order=>30,p_column_identifier=>'C',p_column_label=>'Instance',p_column_link=>'#DETAIL_URL#',p_column_linktext=>'#TITLE#',p_column_link_attr=>'class="sd-ticket-link"',p_column_type=>'STRING',p_heading_alignment=>'LEFT');
wwv_flow_imp_page.create_worksheet_column(p_id=>wwv_flow_imp.id(102032000000015),p_db_column_name=>'INITIATOR',p_display_order=>40,p_column_identifier=>'D',p_column_label=>'Initie par',p_column_type=>'STRING',p_heading_alignment=>'LEFT');
wwv_flow_imp_page.create_worksheet_column(p_id=>wwv_flow_imp.id(102032000000016),p_db_column_name=>'STATE_CODE',p_display_order=>50,p_column_identifier=>'E',p_column_label=>'Etat',p_column_type=>'STRING',p_heading_alignment=>'LEFT');
wwv_flow_imp_page.create_worksheet_column(p_id=>wwv_flow_imp.id(102032000000017),p_db_column_name=>'CREATED_ON',p_display_order=>60,p_column_identifier=>'F',p_column_label=>'Cree le',p_column_type=>'DATE',p_format_mask=>'DD/MM/YYYY HH24:MI',p_heading_alignment=>'LEFT');
wwv_flow_imp_page.create_worksheet_column(p_id=>wwv_flow_imp.id(102032000000018),p_db_column_name=>'LAST_UPDATED_ON',p_display_order=>70,p_column_identifier=>'G',p_column_label=>'Mis a jour le',p_column_type=>'DATE',p_format_mask=>'DD/MM/YYYY HH24:MI',p_heading_alignment=>'LEFT');
wwv_flow_imp_page.create_worksheet_column(p_id=>wwv_flow_imp.id(102032000000019),p_db_column_name=>'DETAIL_URL',p_display_order=>80,p_column_identifier=>'H',p_column_label=>'Lien',p_column_type=>'STRING',p_display_text_as=>'HIDDEN_ESCAPE_SC');
wwv_flow_imp_page.create_worksheet_rpt(p_id=>wwv_flow_imp.id(102032000000020),p_application_user=>'APXWS_DEFAULT',p_report_seq=>10,p_report_alias=>'102032',p_status=>'PUBLIC',p_is_default=>'Y',p_report_columns=>'WORKFLOW_DEF_NAME:TITLE:INITIATOR:STATE_CODE:CREATED_ON:LAST_UPDATED_ON');
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(102032000000030)
,p_plug_name=>'Diagramme de l''instance'
,p_static_id=>'workflow-diagram'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4073835273271169698
,p_plug_display_sequence=>30
,p_plug_item_display_point=>'ABOVE'
,p_location=>null
,p_plug_source_type=>'NATIVE_WORKFLOW_DIAGRAM'
,p_plug_display_when_condition=>'P32_WORKFLOW_ID'
,p_plug_display_condition_type=>'ITEM_IS_NOT_NULL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'enable_navigator','Y',
  'initial_zoom','0',
  'workflow_id','P32_WORKFLOW_ID')).to_clob
);
end;
/
prompt --application/end_environment
begin
wwv_flow_imp.import_end(p_auto_install_sup_obj=>nvl(wwv_flow_application_install.get_auto_install_sup_obj,false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done
