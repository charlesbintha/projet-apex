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
prompt --application/pages/delete_00031
begin
wwv_flow_imp_page.remove_page(p_flow_id=>wwv_flow.g_flow_id,p_page_id=>31);
end;
/
prompt --application/pages/page_00031
begin
wwv_flow_imp_page.create_page(
 p_id=>31
,p_name=>'Detail de la tache'
,p_alias=>'DETAIL-TACHE'
,p_step_title=>'Detail de la tache - Service Desk Lite'
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_css_file_urls=>'#APP_FILES#app.css'
,p_step_template=>4073832297226169690
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'25'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(102031000000001)
,p_plug_name=>'Detail de la tache'
,p_static_id=>'task-detail-breadcrumb'
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
 p_id=>wwv_flow_imp.id(102031000000010)
,p_plug_name=>'Tache et ticket'
,p_static_id=>'task-ticket-summary'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4502917002193490937
,p_plug_display_sequence=>20
,p_plug_item_display_point=>'ABOVE'
,p_location=>null
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'  l_task_def_name varchar2(255);',
'  l_subject varchar2(4000);',
'  l_state varchar2(100);',
'  l_task_type varchar2(100);',
'  l_owner varchar2(255);',
'  l_due_on timestamp with time zone;',
'  l_ticket_id number;',
'  l_ticket sd_ticket_overview_v%rowtype;',
'begin',
'  select d.name, t.subject, t.state, t.task_type_code, t.actual_owner, t.due_on, to_number(t.detail_pk)',
'    into l_task_def_name, l_subject, l_state, l_task_type, l_owner, l_due_on, l_ticket_id',
'    from apex_tasks t',
'    join apex_appl_taskdefs d on d.task_def_id=t.task_def_id',
'   where t.task_id = :P31_TASK_ID;',
'',
'  select * into l_ticket from sd_ticket_overview_v where ticket_id = l_ticket_id;',
'',
'  return ''<article class="sd-detail-card"><header class="sd-detail-header"><div>'' ||',
'         ''<span class="sd-detail-eyebrow">'' || apex_escape.html(l_task_def_name) || ''</span>'' ||',
'         ''<h2>'' || apex_escape.html(l_subject) || ''</h2></div>'' ||',
'         ''<span class="sd-status-badge '' || apex_escape.html_attribute(l_ticket.status_css_class) || ''">'' ||',
'         apex_escape.html(l_ticket.status_label) || ''</span></header>'' ||',
'         ''<dl class="sd-detail-grid">'' ||',
'         ''<div><dt>Ticket</dt><dd><a class="sd-ticket-link" href="'' ||',
'         apex_page.get_url(p_page=>20,p_clear_cache=>''20'',p_items=>''P20_TICKET_ID'',p_values=>l_ticket_id) ||',
'         ''">'' || apex_escape.html(l_ticket.ticket_number) || ''</a></dd></div>'' ||',
'         ''<div><dt>Type</dt><dd>'' || apex_escape.html(l_task_type) || ''</dd></div>'' ||',
'         ''<div><dt>Etat de la tache</dt><dd>'' || apex_escape.html(l_state) || ''</dd></div>'' ||',
'         ''<div><dt>Proprietaire</dt><dd>'' || apex_escape.html(nvl(l_owner,''Non reclamee'')) || ''</dd></div>'' ||',
'         ''<div><dt>Demandeur</dt><dd>'' || apex_escape.html(l_ticket.requester_name) || ''</dd></div>'' ||',
'         ''<div><dt>Echeance</dt><dd>'' || nvl(to_char(l_due_on,''DD/MM/YYYY HH24:MI''),''-'') || ''</dd></div>'' ||',
'         ''<div class="sd-detail-wide"><dt>Description</dt><dd class="sd-description">'' ||',
'         apex_escape.html(dbms_lob.substr(l_ticket.description,32767,1)) || ''</dd></div></dl></article>'';',
'exception when no_data_found then',
'  return ''<div class="t-Alert t-Alert--warning">Tache ou ticket introuvable.</div>'';',
'end;'))
,p_lazy_loading=>false
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(102031000000020)
,p_plug_name=>'Choisir l''agent'
,p_static_id=>'task-assignment'
,p_region_css_classes=>'sd-form-region'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4073835273271169698
,p_plug_display_sequence=>30
,p_plug_item_display_point=>'ABOVE'
,p_location=>null
,p_plug_display_when_condition=>'select 1 from apex_tasks where task_id = :P31_TASK_ID and task_def_static_id = ''SD_TICKET_TRIAGE'' and state_code not in (''COMPLETED'',''CANCELED'',''EXPIRED'')'
,p_plug_display_condition_type=>'EXISTS'
,p_plug_source_type=>'NATIVE_STATIC'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(102031000000030)
,p_plug_name=>'Resolution'
,p_static_id=>'task-resolution'
,p_region_css_classes=>'sd-form-region'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4073835273271169698
,p_plug_display_sequence=>40
,p_plug_item_display_point=>'ABOVE'
,p_location=>null
,p_plug_display_when_condition=>'select 1 from apex_tasks where task_id = :P31_TASK_ID and task_def_static_id = ''SD_TICKET_PROCESSING'' and state_code not in (''COMPLETED'',''CANCELED'',''EXPIRED'')'
,p_plug_display_condition_type=>'EXISTS'
,p_plug_source_type=>'NATIVE_STATIC'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(102031000000040)
,p_plug_name=>'Actions'
,p_static_id=>'task-actions'
,p_region_template_options=>'#DEFAULT#:t-ButtonRegion--stickToBottom'
,p_plug_template=>2127905476394690047
,p_plug_display_sequence=>50
,p_plug_item_display_point=>'ABOVE'
,p_location=>null
,p_plug_source_type=>'NATIVE_STATIC'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(102031000000050)
,p_name=>'P31_TASK_ID'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>10
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2('value_protected','Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(102031000000051)
,p_name=>'P31_AGENT_ID'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(102031000000020)
,p_prompt=>'Agent'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select full_name || '' - '' || apex_username d, agent_id r from sd_agents where is_active = ''Y'' and role_code = ''AGENT'' order by full_name'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'Selectionner un agent'
,p_colspan=>12
,p_field_template=>2528236951996823187
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2('page_action_on_selection','NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(102031000000052)
,p_name=>'P31_RESOLUTION_NOTE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(102031000000030)
,p_prompt=>'Note de resolution'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>4000
,p_cHeight=>6
,p_colspan=>12
,p_field_template=>2528236951996823187
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2('auto_height','N','character_counter','Y','resizable','Y','trim_spaces','BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(102031000000053)
,p_name=>'P31_TRIAGE_PARAM_NAME'
,p_item_sequence=>20
,p_item_default=>'P_AGENT_ID'
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2('value_protected','Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(102031000000054)
,p_name=>'P31_PROCESS_PARAM_NAME'
,p_item_sequence=>30
,p_item_default=>'P_RESOLUTION_NOTE'
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2('value_protected','Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(102031000000060)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(102031000000040)
,p_button_name=>'BACK'
,p_static_id=>'back'
,p_show_as_disabled=>false
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--iconLeft'
,p_button_template_id=>2350584059425431644
,p_button_image_alt=>'Retour aux taches'
,p_button_position=>'PREVIOUS'
,p_button_redirect_url=>'f?p=&APP_ID.:30:&SESSION.::&DEBUG.:30'
,p_icon_css_classes=>'fa-arrow-left'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(102031000000061)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(102031000000040)
,p_button_name=>'CLAIM'
,p_static_id=>'claim'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--iconLeft'
,p_button_template_id=>2084305881903810008
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Reclamer la tache'
,p_button_position=>'CREATE'
,p_button_condition=>wwv_flow_string.join(wwv_flow_t_varchar2('apex_human_task.is_allowed (','  p_task_id => :P31_TASK_ID,','  p_operation => apex_human_task.c_task_op_claim )'))
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
,p_icon_css_classes=>'fa-hand-paper-o'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(102031000000062)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(102031000000040)
,p_button_name=>'COMPLETE_TRIAGE'
,p_static_id=>'complete-triage'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--success:t-Button--iconLeft'
,p_button_template_id=>2084305881903810008
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Valider l''affectation'
,p_button_position=>'CREATE'
,p_button_condition=>'select 1 from apex_tasks where task_id=:P31_TASK_ID and task_def_static_id=''SD_TICKET_TRIAGE'' and actual_owner=:APP_USER and state_code not in (''COMPLETED'',''CANCELED'',''EXPIRED'')'
,p_button_condition_type=>'EXISTS'
,p_icon_css_classes=>'fa-check'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(102031000000063)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(102031000000040)
,p_button_name=>'COMPLETE_PROCESSING'
,p_static_id=>'complete-processing'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--success:t-Button--iconLeft'
,p_button_template_id=>2084305881903810008
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Terminer le traitement'
,p_button_position=>'CREATE'
,p_button_condition=>'select 1 from apex_tasks where task_id=:P31_TASK_ID and task_def_static_id=''SD_TICKET_PROCESSING'' and actual_owner=:APP_USER and state_code not in (''COMPLETED'',''CANCELED'',''EXPIRED'')'
,p_button_condition_type=>'EXISTS'
,p_icon_css_classes=>'fa-check'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(102031000000064)
,p_button_sequence=>50
,p_button_plug_id=>wwv_flow_imp.id(102031000000040)
,p_button_name=>'APPROVE'
,p_static_id=>'approve'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--success:t-Button--iconLeft'
,p_button_template_id=>2084305881903810008
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Approuver la resolution'
,p_button_position=>'CREATE'
,p_button_condition=>wwv_flow_string.join(wwv_flow_t_varchar2('apex_human_task.is_allowed (','  p_task_id => :P31_TASK_ID,','  p_operation => apex_human_task.c_task_op_approve )'))
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
,p_icon_css_classes=>'fa-check'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(102031000000065)
,p_button_sequence=>60
,p_button_plug_id=>wwv_flow_imp.id(102031000000040)
,p_button_name=>'REJECT'
,p_static_id=>'reject'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--danger:t-Button--link:t-Button--iconLeft'
,p_button_template_id=>2084305881903810008
,p_button_image_alt=>'Refuser la resolution'
,p_button_position=>'CREATE'
,p_button_condition=>wwv_flow_string.join(wwv_flow_t_varchar2('apex_human_task.is_allowed (','  p_task_id => :P31_TASK_ID,','  p_operation => apex_human_task.c_task_op_reject )'))
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
,p_icon_css_classes=>'fa-times-circle-o'
);
wwv_flow_imp_page.create_page_validation(p_id=>wwv_flow_imp.id(102031000000070),p_validation_name=>'Agent obligatoire',p_validation_sequence=>10,p_validation=>'P31_AGENT_ID',p_validation_type=>'ITEM_NOT_NULL',p_error_message=>'Selectionnez un agent.',p_when_button_pressed=>wwv_flow_imp.id(102031000000062),p_associated_item=>wwv_flow_imp.id(102031000000051),p_error_display_location=>'INLINE_WITH_FIELD');
wwv_flow_imp_page.create_page_validation(p_id=>wwv_flow_imp.id(102031000000071),p_validation_name=>'Note obligatoire',p_validation_sequence=>20,p_validation=>'P31_RESOLUTION_NOTE',p_validation_type=>'ITEM_NOT_NULL',p_error_message=>'Saisissez la note de resolution.',p_when_button_pressed=>wwv_flow_imp.id(102031000000063),p_associated_item=>wwv_flow_imp.id(102031000000052),p_error_display_location=>'INLINE_WITH_FIELD');
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(102031000000080)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Charger les parametres de la tache'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2('begin','  select nullif(max(case when param_static_id=''P_AGENT_ID'' then param_value end), ''0''),','         nullif(max(case when param_static_id=''P_RESOLUTION_NOTE'' then param_value end), ''#NOT_SET#'')','    into :P31_AGENT_ID, :P31_RESOLUTION_NOTE','    from apex_task_parameters','   where task_id=:P31_TASK_ID;','end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>102031000000080
);
wwv_flow_imp_page.create_page_process(p_id=>wwv_flow_imp.id(102031000000081),p_process_sequence=>10,p_process_point=>'AFTER_SUBMIT',p_process_type=>'NATIVE_MANAGE_TASK',p_process_name=>'Enregistrer agent',p_static_id=>'save-agent-param',p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2('new_value_item','P31_AGENT_ID','parameter_item','P31_TRIAGE_PARAM_NAME','task_id_item','P31_TASK_ID','type','SET_TASK_PARAMS')).to_clob,p_process_error_message=>'#SQLERRM_TEXT#',p_error_display_location=>'INLINE_IN_NOTIFICATION',p_process_when_button_id=>wwv_flow_imp.id(102031000000062),p_internal_uid=>102031000000081);
wwv_flow_imp_page.create_page_process(p_id=>wwv_flow_imp.id(102031000000082),p_process_sequence=>20,p_process_point=>'AFTER_SUBMIT',p_process_type=>'NATIVE_MANAGE_TASK',p_process_name=>'Completer affectation',p_static_id=>'complete-triage-task',p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2('task_id_item','P31_TASK_ID','type','COMPLETE_TASK')).to_clob,p_process_error_message=>'#SQLERRM_TEXT#',p_error_display_location=>'INLINE_IN_NOTIFICATION',p_process_when_button_id=>wwv_flow_imp.id(102031000000062),p_process_success_message=>'Affectation validee.',p_internal_uid=>102031000000082);
wwv_flow_imp_page.create_page_process(p_id=>wwv_flow_imp.id(102031000000083),p_process_sequence=>10,p_process_point=>'AFTER_SUBMIT',p_process_type=>'NATIVE_MANAGE_TASK',p_process_name=>'Enregistrer resolution',p_static_id=>'save-resolution-param',p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2('new_value_item','P31_RESOLUTION_NOTE','parameter_item','P31_PROCESS_PARAM_NAME','task_id_item','P31_TASK_ID','type','SET_TASK_PARAMS')).to_clob,p_process_error_message=>'#SQLERRM_TEXT#',p_error_display_location=>'INLINE_IN_NOTIFICATION',p_process_when_button_id=>wwv_flow_imp.id(102031000000063),p_internal_uid=>102031000000083);
wwv_flow_imp_page.create_page_process(p_id=>wwv_flow_imp.id(102031000000084),p_process_sequence=>20,p_process_point=>'AFTER_SUBMIT',p_process_type=>'NATIVE_MANAGE_TASK',p_process_name=>'Completer traitement',p_static_id=>'complete-processing-task',p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2('task_id_item','P31_TASK_ID','type','COMPLETE_TASK')).to_clob,p_process_error_message=>'#SQLERRM_TEXT#',p_error_display_location=>'INLINE_IN_NOTIFICATION',p_process_when_button_id=>wwv_flow_imp.id(102031000000063),p_process_success_message=>'Traitement termine.',p_internal_uid=>102031000000084);
wwv_flow_imp_page.create_page_process(p_id=>wwv_flow_imp.id(102031000000085),p_process_sequence=>10,p_process_point=>'AFTER_SUBMIT',p_process_type=>'NATIVE_MANAGE_TASK',p_process_name=>'Reclamer',p_static_id=>'claim-task',p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2('task_id_item','P31_TASK_ID','type','CLAIM_TASK')).to_clob,p_process_error_message=>'#SQLERRM_TEXT#',p_error_display_location=>'INLINE_IN_NOTIFICATION',p_process_when_button_id=>wwv_flow_imp.id(102031000000061),p_process_success_message=>'Tache reclamee.',p_internal_uid=>102031000000085);
wwv_flow_imp_page.create_page_process(p_id=>wwv_flow_imp.id(102031000000086),p_process_sequence=>10,p_process_point=>'AFTER_SUBMIT',p_process_type=>'NATIVE_MANAGE_TASK',p_process_name=>'Approuver',p_static_id=>'approve-task',p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2('task_id_item','P31_TASK_ID','type','APPROVE_TASK')).to_clob,p_process_error_message=>'#SQLERRM_TEXT#',p_error_display_location=>'INLINE_IN_NOTIFICATION',p_process_when_button_id=>wwv_flow_imp.id(102031000000064),p_process_success_message=>'Resolution approuvee.',p_internal_uid=>102031000000086);
wwv_flow_imp_page.create_page_process(p_id=>wwv_flow_imp.id(102031000000087),p_process_sequence=>10,p_process_point=>'AFTER_SUBMIT',p_process_type=>'NATIVE_MANAGE_TASK',p_process_name=>'Refuser',p_static_id=>'reject-task',p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2('task_id_item','P31_TASK_ID','type','REJECT_TASK')).to_clob,p_process_error_message=>'#SQLERRM_TEXT#',p_error_display_location=>'INLINE_IN_NOTIFICATION',p_process_when_button_id=>wwv_flow_imp.id(102031000000065),p_process_success_message=>'Resolution refusee.',p_internal_uid=>102031000000087);
wwv_flow_imp_page.create_page_branch(p_id=>wwv_flow_imp.id(102031000000090),p_branch_name=>'Rester apres reclamation',p_branch_action=>'f?p=&APP_ID.:31:&SESSION.::&DEBUG.:31:P31_TASK_ID:&P31_TASK_ID.&success_msg=#SUCCESS_MSG#',p_branch_point=>'AFTER_PROCESSING',p_branch_type=>'REDIRECT_URL',p_branch_when_button_id=>wwv_flow_imp.id(102031000000061),p_branch_sequence=>10);
wwv_flow_imp_page.create_page_branch(p_id=>wwv_flow_imp.id(102031000000091),p_branch_name=>'Retour apres action',p_branch_action=>'f?p=&APP_ID.:30:&SESSION.::&DEBUG.:30::&success_msg=#SUCCESS_MSG#',p_branch_point=>'AFTER_PROCESSING',p_branch_type=>'REDIRECT_URL',p_branch_sequence=>20);
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
