prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
-- Oracle APEX page export
-- Application 102 - Service Desk Lite / Demande Interne
-- Page 20        - Detail du ticket et actions metier
-- Target APEX    - 26.1.4
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

prompt APPLICATION 102 - Demande Interne

begin
null;
end;
/

prompt --application/pages/delete_00020
begin
wwv_flow_imp_page.remove_page(
 p_flow_id=>wwv_flow.g_flow_id
,p_page_id=>20
);
end;
/

prompt --application/pages/page_00020
begin
wwv_flow_imp_page.create_page(
 p_id=>20
,p_name=>'Detail du ticket'
,p_alias=>'DETAIL-TICKET'
,p_step_title=>'Detail du ticket - Service Desk Lite'
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_css_file_urls=>'#APP_FILES#app.css'
,p_step_template=>4073832297226169690
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'25'
);

wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(102020000000001)
,p_plug_name=>'Ticket &P20_TICKET_NUMBER.'
,p_static_id=>'ticket-detail-breadcrumb'
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

wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(102020000000010)
,p_plug_name=>'Informations du ticket'
,p_static_id=>'ticket-detail'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4502917002193490937
,p_plug_display_sequence=>20
,p_plug_item_display_point=>'ABOVE'
,p_location=>null
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'  l_ticket      sd_ticket_overview_v%rowtype;',
'  l_description varchar2(32767);',
'  l_html        clob;',
'begin',
'  select *',
'    into l_ticket',
'    from sd_ticket_overview_v',
'   where ticket_id = :P20_TICKET_ID;',
'',
'  l_description := dbms_lob.substr(l_ticket.description, 32767, 1);',
'',
'  l_html := ''<article class="sd-detail-card">'' ||',
'    ''<header class="sd-detail-header"><div>'' ||',
'      ''<span class="sd-detail-eyebrow">'' || apex_escape.html(l_ticket.ticket_number) || ''</span>'' ||',
'      ''<h2>'' || apex_escape.html(l_ticket.subject) || ''</h2></div>'' ||',
'      ''<span class="sd-status-badge '' || apex_escape.html_attribute(l_ticket.status_css_class) || ''">'' ||',
'        apex_escape.html(l_ticket.status_label) || ''</span></header>'' ||',
'',
'    ''<dl class="sd-detail-grid">'' ||',
'      ''<div><dt>Categorie</dt><dd>'' || apex_escape.html(l_ticket.category_name) || ''</dd></div>'' ||',
'      ''<div><dt>Priorite</dt><dd><span class="sd-priority-badge '' ||',
'        apex_escape.html_attribute(l_ticket.priority_css_class) || ''">'' ||',
'        apex_escape.html(l_ticket.priority_label) || ''</span></dd></div>'' ||',
'      ''<div><dt>Demandeur</dt><dd>'' || apex_escape.html(l_ticket.requester_name) || ''</dd></div>'' ||',
'      ''<div><dt>Courriel</dt><dd>'' || apex_escape.html(l_ticket.requester_email) || ''</dd></div>'' ||',
'      ''<div><dt>Agent affecte</dt><dd>'' ||',
'        apex_escape.html(nvl(l_ticket.assigned_agent_name, ''Non affecte'')) || ''</dd></div>'' ||',
'      ''<div><dt>Cree le</dt><dd>'' || to_char(l_ticket.created_at, ''DD/MM/YYYY HH24:MI'') || ''</dd></div>'' ||',
'      ''<div><dt>Derniere mise a jour</dt><dd>'' ||',
'        nvl(to_char(l_ticket.updated_at, ''DD/MM/YYYY HH24:MI''), ''-'' ) || ''</dd></div>'' ||',
'      ''<div><dt>Resolu le</dt><dd>'' ||',
'        nvl(to_char(l_ticket.resolved_at, ''DD/MM/YYYY HH24:MI''), ''-'' ) || ''</dd></div>'' ||',
'      ''<div class="sd-detail-wide"><dt>Description</dt><dd class="sd-description">'' ||',
'        apex_escape.html(l_description) || ''</dd></div>'' ||',
'    ''</dl></article>'';',
'',
'  return l_html;',
'exception',
'  when no_data_found then',
'    return ''<div class="t-Alert t-Alert--warning">Ticket introuvable.</div>'';',
'end;'))
,p_lazy_loading=>false
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);

wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(102020000000012)
,p_plug_name=>'Workflow du ticket'
,p_static_id=>'ticket-workflow-status'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4502917002193490937
,p_plug_display_sequence=>22
,p_plug_item_display_point=>'ABOVE'
,p_location=>null
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'  l_workflow_id number;',
'  l_state varchar2(100);',
'  l_title varchar2(4000);',
'  l_task_id number;',
'  l_task_subject varchar2(4000);',
'  l_workflow_url varchar2(4000);',
'  l_task_url varchar2(4000);',
'begin',
'  select workflow_id into l_workflow_id from sd_tickets where ticket_id=:P20_TICKET_ID;',
'',
'  select state_code, title',
'    into l_state, l_title',
'    from table(apex_workflow.get_workflows(',
'           p_context=>''SINGLE_WORKFLOW'',',
'           p_workflow_id=>l_workflow_id));',
'',
'  begin',
'    select task_id, subject',
'      into l_task_id, l_task_subject',
'      from (',
'        select task_id, subject',
'          from apex_tasks',
'         where application_id=:APP_ID',
'           and detail_pk=to_char(:P20_TICKET_ID)',
'           and state_code in (''UNASSIGNED'',''ASSIGNED'')',
'         order by created_on desc',
'      ) where rownum=1;',
'  exception when no_data_found then null;',
'  end;',
'',
'  l_workflow_url:=apex_page.get_url(p_page=>32,p_clear_cache=>''32'',p_items=>''P32_WORKFLOW_ID'',p_values=>l_workflow_id);',
'  if l_task_id is not null then',
'    l_task_url:=apex_page.get_url(p_page=>31,p_clear_cache=>''31'',p_items=>''P31_TASK_ID'',p_values=>l_task_id);',
'  end if;',
'',
'  return ''<div class="sd-kpi-card sd-kpi-open"><div class="sd-kpi-icon"><span class="fa fa-workflow"></span></div>'' ||',
'         ''<div class="sd-kpi-content"><span class="sd-kpi-label">Workflow actif</span><strong class="sd-kpi-value">'' || apex_escape.html(l_state) || ''</strong>'' ||',
'         ''<span class="sd-kpi-caption">'' || apex_escape.html(l_title) || ''</span>'' ||',
'         ''<a class="sd-ticket-link" href="'' || l_workflow_url || ''">Voir le diagramme</a>'' ||',
'         case when l_task_id is not null then '' &middot; <a class="sd-ticket-link" href="'' || l_task_url || ''">'' || apex_escape.html(l_task_subject) || ''</a>'' end ||',
'         ''</div></div>'';',
'exception when no_data_found then return null;',
'end;'))
,p_lazy_loading=>false
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
,p_plug_display_when_condition=>'select 1 from sd_tickets where ticket_id=:P20_TICKET_ID and workflow_id is not null'
,p_plug_display_condition_type=>'EXISTS'
);

wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(102020000000015)
,p_plug_name=>'Navigation du ticket'
,p_static_id=>'ticket-region-selector'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4502917002193490937
,p_plug_display_sequence=>25
,p_plug_item_display_point=>'ABOVE'
,p_location=>null
,p_plug_source_type=>'NATIVE_DISPLAY_SELECTOR'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_region_icons', 'N',
  'include_show_all', 'N',
  'rds_mode', 'STANDARD',
  'remember_selection', 'SESSION')).to_clob
);

wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(102020000000020)
,p_plug_name=>'Affectation'
,p_static_id=>'ticket-actions'
,p_region_css_classes=>'sd-form-region'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4073835273271169698
,p_plug_display_sequence=>30
,p_include_in_reg_disp_sel_yn=>'Y'
,p_plug_item_display_point=>'ABOVE'
,p_location=>null
,p_plug_display_when_condition=>'select 1 from sd_tickets where ticket_id = :P20_TICKET_ID and workflow_id is null and status_code in (''NEW'', ''ASSIGNED'', ''IN_PROGRESS'')'
,p_plug_display_condition_type=>'EXISTS'
,p_plug_source_type=>'NATIVE_STATIC'
);

wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(102020000000030)
,p_name=>'Historique'
,p_static_id=>'ticket-comments'
,p_region_css_classes=>'sd-report-region'
,p_template=>4073835273271169698
,p_display_sequence=>40
,p_include_in_reg_disp_sel_yn=>'Y'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#:t-Report--stretch:t-Report--rowHighlight'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select comment_id,',
'       case comment_type when ''PUBLIC'' then ''Public'' else ''Interne'' end comment_type_label,',
'       dbms_lob.substr(comment_text, 4000, 1) comment_text,',
'       created_by,',
'       created_at',
'  from sd_ticket_comments',
' where ticket_id = :P20_TICKET_ID',
' order by created_at desc'))
,p_ajax_enabled=>'Y'
,p_ajax_items_to_submit=>'P20_TICKET_ID'
,p_lazy_loading=>false
,p_query_row_template=>2540130677583398057
,p_query_num_rows=>10
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'Aucun commentaire pour ce ticket.'
,p_query_num_rows_type=>'NEXT_PREVIOUS_LINKS'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(102020000000031)
,p_query_column_id=>1
,p_column_alias=>'COMMENT_ID'
,p_column_display_sequence=>10
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(102020000000032)
,p_query_column_id=>2
,p_column_alias=>'COMMENT_TYPE_LABEL'
,p_column_display_sequence=>20
,p_column_heading=>'Type'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(102020000000033)
,p_query_column_id=>3
,p_column_alias=>'COMMENT_TEXT'
,p_column_display_sequence=>30
,p_column_heading=>'Commentaire'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'Y'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(102020000000034)
,p_query_column_id=>4
,p_column_alias=>'CREATED_BY'
,p_column_display_sequence=>40
,p_column_heading=>'Ajoute par'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(102020000000035)
,p_query_column_id=>5
,p_column_alias=>'CREATED_AT'
,p_column_display_sequence=>50
,p_column_heading=>'Ajoute le'
,p_column_format=>'DD/MM/YYYY HH24:MI'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(102020000000040)
,p_plug_name=>'Commentaire'
,p_static_id=>'add-ticket-comment'
,p_region_css_classes=>'sd-form-region'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4073835273271169698
,p_plug_display_sequence=>50
,p_include_in_reg_disp_sel_yn=>'Y'
,p_plug_item_display_point=>'ABOVE'
,p_location=>null
,p_plug_source_type=>'NATIVE_STATIC'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(102020000000100)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(102020000000001)
,p_button_name=>'BACK_TO_TICKETS'
,p_static_id=>'back-to-tickets'
,p_show_as_disabled=>false
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--iconLeft'
,p_button_template_id=>2350584059425431644
,p_button_image_alt=>'Retour aux tickets'
,p_button_position=>'PREVIOUS'
,p_button_redirect_url=>'f?p=&APP_ID.:10:&SESSION.::&DEBUG.:10'
,p_icon_css_classes=>'fa-arrow-left'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(102020000000101)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(102020000000001)
,p_button_name=>'START_TICKET'
,p_static_id=>'start-ticket'
,p_show_as_disabled=>false
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--hot:t-Button--iconLeft'
,p_button_template_id=>2084305881903810008
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Commencer le traitement'
,p_button_position=>'CREATE'
,p_button_condition=>'select 1 from sd_tickets where ticket_id = :P20_TICKET_ID and workflow_id is null and status_code = ''ASSIGNED'''
,p_button_condition_type=>'EXISTS'
,p_icon_css_classes=>'fa-play'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(102020000000102)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(102020000000001)
,p_button_name=>'RESOLVE_TICKET'
,p_static_id=>'resolve-ticket'
,p_show_as_disabled=>false
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--success:t-Button--iconLeft'
,p_button_template_id=>2084305881903810008
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Resoudre le ticket'
,p_button_position=>'CREATE'
,p_button_condition=>'select 1 from sd_tickets where ticket_id = :P20_TICKET_ID and workflow_id is null and status_code = ''IN_PROGRESS'''
,p_button_condition_type=>'EXISTS'
,p_icon_css_classes=>'fa-check'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(102020000000103)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(102020000000001)
,p_button_name=>'CLOSE_TICKET'
,p_static_id=>'close-ticket'
,p_show_as_disabled=>false
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--iconLeft'
,p_button_template_id=>2084305881903810008
,p_button_image_alt=>'Fermer le ticket'
,p_button_position=>'CREATE'
,p_button_condition=>'select 1 from sd_tickets where ticket_id = :P20_TICKET_ID and workflow_id is null and status_code = ''RESOLVED'''
,p_button_condition_type=>'EXISTS'
,p_icon_css_classes=>'fa-lock'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(102020000000104)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(102020000000020)
,p_button_name=>'ASSIGN_TICKET'
,p_static_id=>'assign-ticket'
,p_show_as_disabled=>false
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--iconLeft'
,p_button_template_id=>2084305881903810008
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Affecter le ticket'
,p_button_position=>'CREATE'
,p_button_condition=>'select 1 from sd_tickets where ticket_id = :P20_TICKET_ID and workflow_id is null and status_code not in (''RESOLVED'', ''CLOSED'')'
,p_button_condition_type=>'EXISTS'
,p_icon_css_classes=>'fa-user-plus'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(102020000000105)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(102020000000040)
,p_button_name=>'ADD_COMMENT'
,p_static_id=>'add-comment'
,p_show_as_disabled=>false
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--iconLeft'
,p_button_template_id=>2084305881903810008
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Ajouter le commentaire'
,p_button_position=>'CREATE'
,p_icon_css_classes=>'fa-comment-o'
);

wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(102020000000110)
,p_branch_name=>'Recharger le detail du ticket'
,p_branch_action=>'f?p=&APP_ID.:20:&SESSION.::&DEBUG.:20:P20_TICKET_ID:&P20_TICKET_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>100
);

wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(102020000000120)
,p_name=>'P20_TICKET_ID'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(102020000000010)
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);

wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(102020000000121)
,p_name=>'P20_TICKET_NUMBER'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(102020000000010)
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);

wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(102020000000122)
,p_name=>'P20_STATUS_CODE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(102020000000010)
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);

wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(102020000000123)
,p_name=>'P20_ASSIGNED_AGENT_ID'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(102020000000020)
,p_prompt=>'Agent affecte'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select full_name || '' - '' || email d, agent_id r from sd_agents where is_active = ''Y'' order by full_name'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'Selectionner un agent'
,p_colspan=>6
,p_field_template=>2320077351817916916
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);

wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(102020000000124)
,p_name=>'P20_RESOLUTION_NOTE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(102020000000020)
,p_prompt=>'Note de resolution'
,p_placeholder=>'Expliquez la solution apportee...'
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cHeight=>4
,p_begin_on_new_line=>'N'
,p_colspan=>6
,p_field_template=>2320077351817916916
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_display_when=>'select 1 from sd_tickets where ticket_id = :P20_TICKET_ID and status_code = ''IN_PROGRESS'''
,p_display_when_type=>'EXISTS'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'Y',
  'character_counter', 'Y',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);

wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(102020000000125)
,p_name=>'P20_COMMENT_TYPE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(102020000000040)
,p_item_default=>'PUBLIC'
,p_prompt=>'Visibilite'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:Public;PUBLIC,Interne;INTERNAL'
,p_lov_display_null=>'NO'
,p_colspan=>3
,p_field_template=>2320077351817916916
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);

wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(102020000000126)
,p_name=>'P20_COMMENT_TEXT'
,p_source_data_type=>'CLOB'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(102020000000040)
,p_prompt=>'Commentaire'
,p_placeholder=>'Saisissez votre commentaire...'
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cHeight=>4
,p_begin_on_new_line=>'N'
,p_colspan=>9
,p_field_template=>2320077351817916916
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'Y',
  'character_counter', 'Y',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(102020000000200)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Charger le contexte du ticket'
,p_static_id=>'load-ticket-context'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  select ticket_number, status_code, assigned_agent_id',
'    into :P20_TICKET_NUMBER, :P20_STATUS_CODE, :P20_ASSIGNED_AGENT_ID',
'    from sd_tickets',
'   where ticket_id = :P20_TICKET_ID;',
'exception',
'  when no_data_found then',
'    raise_application_error(-20001, ''Ticket introuvable.'');',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_internal_uid=>102020000000200
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(102020000000201)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Affecter le ticket'
,p_static_id=>'assign-ticket-process'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  sd_ticket_api.assign_ticket(',
'    p_ticket_id => :P20_TICKET_ID,',
'    p_agent_id  => :P20_ASSIGNED_AGENT_ID,',
'    p_actor     => :APP_USER);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(102020000000104)
,p_process_success_message=>'Le ticket a ete affecte.'
,p_internal_uid=>102020000000201
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(102020000000202)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Demarrer le traitement'
,p_static_id=>'start-ticket-process'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  sd_ticket_api.start_ticket(',
'    p_ticket_id => :P20_TICKET_ID,',
'    p_actor     => :APP_USER);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(102020000000101)
,p_process_success_message=>'Le traitement du ticket a commence.'
,p_internal_uid=>102020000000202
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(102020000000203)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Resoudre le ticket'
,p_static_id=>'resolve-ticket-process'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  sd_ticket_api.resolve_ticket(',
'    p_ticket_id       => :P20_TICKET_ID,',
'    p_resolution_note => :P20_RESOLUTION_NOTE,',
'    p_actor           => :APP_USER);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(102020000000102)
,p_process_success_message=>'Le ticket a ete resolu.'
,p_internal_uid=>102020000000203
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(102020000000204)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Fermer le ticket'
,p_static_id=>'close-ticket-process'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  sd_ticket_api.close_ticket(',
'    p_ticket_id => :P20_TICKET_ID,',
'    p_actor     => :APP_USER);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(102020000000103)
,p_process_success_message=>'Le ticket a ete ferme.'
,p_internal_uid=>102020000000204
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(102020000000205)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Ajouter le commentaire'
,p_static_id=>'add-comment-process'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  sd_ticket_api.add_comment(',
'    p_ticket_id    => :P20_TICKET_ID,',
'    p_comment_text => :P20_COMMENT_TEXT,',
'    p_comment_type => :P20_COMMENT_TYPE,',
'    p_actor        => :APP_USER);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(102020000000105)
,p_process_success_message=>'Le commentaire a ete ajoute.'
,p_internal_uid=>102020000000205
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
