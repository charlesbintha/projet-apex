prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
-- Application 102 - Service Desk Lite
-- Shared Components - Human Tasks and Ticket Lifecycle Workflow
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

prompt --application/shared_components/workflow/task_definitions/ticket_triage
begin
wwv_flow_imp_shared.create_task_def(
 p_id=>wwv_flow_imp.id(102900000000001)
,p_name=>'Affectation du ticket'
,p_static_id=>'SD_TICKET_TRIAGE'
,p_subject=>'Affecter le ticket &TICKET_NUMBER. - &SUBJECT.'
,p_task_type=>'ACTION'
,p_priority=>2
,p_due_on_interval=>'P1D'
,p_expiration_policy=>'NONE'
,p_due_on_type=>'INTERVAL'
,p_details_link_target=>'f?p=&APP_ID.:31:&SESSION.::&DEBUG.:RP,31:P31_TASK_ID:&TASK_ID.'
,p_actions_sql_query=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select ticket_number, subject, priority_label, category_name',
'  from sd_ticket_overview_v',
' where ticket_id = :APEX$TASK_PK'))
,p_initiator_can_complete=>false
);
wwv_flow_imp_shared.create_task_def_param(
 p_id=>wwv_flow_imp.id(102900000000002)
,p_task_def_id=>wwv_flow_imp.id(102900000000001)
,p_label=>'Agent a affecter'
,p_static_id=>'P_AGENT_ID'
,p_data_type=>'NUMBER'
,p_is_required=>false
,p_is_visible=>true
,p_is_updatable=>true
);
wwv_flow_imp_shared.create_task_def_participant(
 p_id=>wwv_flow_imp.id(102900000000003)
,p_task_def_id=>wwv_flow_imp.id(102900000000001)
,p_participant_type=>'POTENTIAL_OWNER'
,p_identity_type=>'USER'
,p_value_type=>'EXPRESSION'
,p_value_language=>'PLSQL'
,p_value=>'sd_workflow_api.admin_usernames'
);
wwv_flow_imp_shared.create_task_def_participant(
 p_id=>wwv_flow_imp.id(102900000000004)
,p_task_def_id=>wwv_flow_imp.id(102900000000001)
,p_participant_type=>'BUSINESS_ADMIN'
,p_identity_type=>'USER'
,p_value_type=>'EXPRESSION'
,p_value_language=>'PLSQL'
,p_value=>'sd_workflow_api.admin_usernames'
);
wwv_flow_imp_shared.create_task_def_participant(
 p_id=>wwv_flow_imp.id(102900000000005)
,p_task_def_id=>wwv_flow_imp.id(102900000000001)
,p_participant_type=>'POTENTIAL_OWNER'
,p_identity_type=>'USER'
,p_value_type=>'EXPRESSION'
,p_value_language=>'PLSQL'
,p_value=>':APEX$TASK_INITIATOR'
);
end;
/

prompt --application/shared_components/workflow/task_definitions/ticket_processing
begin
wwv_flow_imp_shared.create_task_def(
 p_id=>wwv_flow_imp.id(102900000000010)
,p_name=>'Traitement du ticket'
,p_static_id=>'SD_TICKET_PROCESSING'
,p_subject=>'Traiter le ticket &TICKET_NUMBER. - &SUBJECT.'
,p_task_type=>'ACTION'
,p_priority=>3
,p_due_on_interval=>'P2D'
,p_expiration_policy=>'NONE'
,p_due_on_type=>'INTERVAL'
,p_details_link_target=>'f?p=&APP_ID.:31:&SESSION.::&DEBUG.:RP,31:P31_TASK_ID:&TASK_ID.'
,p_actions_sql_query=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select ticket_number, subject, priority_label, category_name, assigned_agent_name',
'  from sd_ticket_overview_v',
' where ticket_id = :APEX$TASK_PK'))
,p_initiator_can_complete=>false
);
wwv_flow_imp_shared.create_task_def_param(
 p_id=>wwv_flow_imp.id(102900000000011)
,p_task_def_id=>wwv_flow_imp.id(102900000000010)
,p_label=>'Note de resolution'
,p_static_id=>'P_RESOLUTION_NOTE'
,p_data_type=>'VARCHAR2'
,p_is_required=>false
,p_is_visible=>true
,p_is_updatable=>true
);
wwv_flow_imp_shared.create_task_def_participant(
 p_id=>wwv_flow_imp.id(102900000000012)
,p_task_def_id=>wwv_flow_imp.id(102900000000010)
,p_participant_type=>'POTENTIAL_OWNER'
,p_identity_type=>'USER'
,p_value_type=>'EXPRESSION'
,p_value_language=>'PLSQL'
,p_value=>'sd_workflow_api.ticket_agent_username(:APEX$TASK_PK)'
);
wwv_flow_imp_shared.create_task_def_participant(
 p_id=>wwv_flow_imp.id(102900000000013)
,p_task_def_id=>wwv_flow_imp.id(102900000000010)
,p_participant_type=>'BUSINESS_ADMIN'
,p_identity_type=>'USER'
,p_value_type=>'EXPRESSION'
,p_value_language=>'PLSQL'
,p_value=>'sd_workflow_api.admin_usernames'
);
end;
/

prompt --application/shared_components/workflow/task_definitions/resolution_approval
begin
wwv_flow_imp_shared.create_task_def(
 p_id=>wwv_flow_imp.id(102900000000020)
,p_name=>'Validation de la resolution'
,p_static_id=>'SD_RESOLUTION_APPROVAL'
,p_subject=>'Valider la resolution du ticket &TICKET_NUMBER. - &SUBJECT.'
,p_task_type=>'APPROVAL'
,p_priority=>3
,p_due_on_interval=>'P2D'
,p_expiration_policy=>'NONE'
,p_due_on_type=>'INTERVAL'
,p_details_link_target=>'f?p=&APP_ID.:31:&SESSION.::&DEBUG.:RP,31:P31_TASK_ID:&TASK_ID.'
,p_actions_sql_query=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select ticket_number, subject, priority_label, category_name, requester_name',
'  from sd_ticket_overview_v',
' where ticket_id = :APEX$TASK_PK'))
,p_initiator_can_complete=>false
);
wwv_flow_imp_shared.create_task_def_participant(
 p_id=>wwv_flow_imp.id(102900000000021)
,p_task_def_id=>wwv_flow_imp.id(102900000000020)
,p_participant_type=>'POTENTIAL_OWNER'
,p_identity_type=>'USER'
,p_value_type=>'EXPRESSION'
,p_value_language=>'PLSQL'
,p_value=>'sd_workflow_api.ticket_requester_username(:APEX$TASK_PK)'
);
wwv_flow_imp_shared.create_task_def_participant(
 p_id=>wwv_flow_imp.id(102900000000022)
,p_task_def_id=>wwv_flow_imp.id(102900000000020)
,p_participant_type=>'BUSINESS_ADMIN'
,p_identity_type=>'USER'
,p_value_type=>'EXPRESSION'
,p_value_language=>'PLSQL'
,p_value=>'sd_workflow_api.admin_usernames'
);
end;
/

prompt --application/shared_components/workflow/workflows/ticket_lifecycle
begin
wwv_flow_imp_shared.create_workflow(
 p_id=>wwv_flow_imp.id(102900000000100)
,p_name=>'Cycle de vie du ticket'
,p_static_id=>'SD_TICKET_LIFECYCLE'
,p_title=>'Ticket &TICKET_NUMBER. - &SUBJECT.'
,p_comment=>'Orchestre l''affectation, le traitement, la resolution et sa validation.'
);
wwv_flow_imp_shared.create_workflow_version(
 p_id=>wwv_flow_imp.id(102900000000101)
,p_workflow_id=>wwv_flow_imp.id(102900000000100)
,p_version=>'1.0'
,p_state=>'DEVELOPMENT'
,p_query_type=>'SQL'
,p_query_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select ticket_id, ticket_number, subject, priority_label, category_name,',
'       requester_name, requester_username, assigned_agent_name',
'  from sd_ticket_overview_v',
' where ticket_id = :APEX$WORKFLOW_DETAIL_PK'))
,p_diagram=>'orthogonal'
);
wwv_flow_imp_shared.create_workflow_variable(
 p_id=>wwv_flow_imp.id(102900000000110)
,p_workflow_version_id=>wwv_flow_imp.id(102900000000101)
,p_label=>'Tache affectation'
,p_static_id=>'V_TRIAGE_TASK_ID'
,p_direction=>'VARIABLE'
,p_data_type=>'NUMBER'
,p_value_type=>'NULL'
);
wwv_flow_imp_shared.create_workflow_variable(
 p_id=>wwv_flow_imp.id(102900000000111)
,p_workflow_version_id=>wwv_flow_imp.id(102900000000101)
,p_label=>'Tache traitement'
,p_static_id=>'V_PROCESSING_TASK_ID'
,p_direction=>'VARIABLE'
,p_data_type=>'NUMBER'
,p_value_type=>'NULL'
);
wwv_flow_imp_shared.create_workflow_variable(
 p_id=>wwv_flow_imp.id(102900000000112)
,p_workflow_version_id=>wwv_flow_imp.id(102900000000101)
,p_label=>'Tache validation'
,p_static_id=>'V_APPROVAL_TASK_ID'
,p_direction=>'VARIABLE'
,p_data_type=>'NUMBER'
,p_value_type=>'NULL'
);
wwv_flow_imp_shared.create_workflow_variable(
 p_id=>wwv_flow_imp.id(102900000000113)
,p_workflow_version_id=>wwv_flow_imp.id(102900000000101)
,p_label=>'Decision demandeur'
,p_static_id=>'V_APPROVAL_OUTCOME'
,p_direction=>'VARIABLE'
,p_data_type=>'VARCHAR2'
,p_value_type=>'NULL'
);

wwv_flow_imp_shared.create_workflow_activity(
 p_id=>wwv_flow_imp.id(102900000000200)
,p_workflow_version_id=>wwv_flow_imp.id(102900000000101)
,p_name=>'Debut'
,p_static_id=>'Start'
,p_display_sequence=>10
,p_activity_type=>'NATIVE_WORKFLOW_START'
);
wwv_flow_imp_shared.create_workflow_activity(
 p_id=>wwv_flow_imp.id(102900000000201)
,p_workflow_version_id=>wwv_flow_imp.id(102900000000101)
,p_name=>'Enregistrer le workflow'
,p_static_id=>'RecordWorkflow'
,p_display_sequence=>20
,p_activity_type=>'NATIVE_INVOKE_API'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'package', 'SD_WORKFLOW_API',
  'package_method', 'RECORD_WORKFLOW',
  'type', 'PLSQL_PACKAGE')).to_clob
);
wwv_flow_imp_shared.create_invokeapi_comp_param(
 p_id=>wwv_flow_imp.id(102900000000300)
,p_workflow_activity_id=>wwv_flow_imp.id(102900000000201)
,p_name=>'p_ticket_id'
,p_direction=>'IN'
,p_data_type=>'NUMBER'
,p_has_default=>false
,p_display_sequence=>10
,p_value_type=>'ITEM'
,p_value=>'APEX$WORKFLOW_DETAIL_PK'
);
wwv_flow_imp_shared.create_invokeapi_comp_param(
 p_id=>wwv_flow_imp.id(102900000000301)
,p_workflow_activity_id=>wwv_flow_imp.id(102900000000201)
,p_name=>'p_workflow_id'
,p_direction=>'IN'
,p_data_type=>'NUMBER'
,p_has_default=>false
,p_display_sequence=>20
,p_value_type=>'STATIC'
,p_value=>'&APEX$WORKFLOW_ID.'
);

wwv_flow_imp_shared.create_workflow_activity(
 p_id=>wwv_flow_imp.id(102900000000202)
,p_workflow_version_id=>wwv_flow_imp.id(102900000000101)
,p_name=>'Affecter le ticket'
,p_static_id=>'TriageTask'
,p_display_sequence=>30
,p_activity_type=>'NATIVE_CREATE_TASK'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'details_primary_key_item', 'APEX$WORKFLOW_DETAIL_PK',
  'initiator_can_complete', 'N',
  'task_definition_id', wwv_flow_imp.id(102900000000001),
  'task_id_item', 'V_TRIAGE_TASK_ID')).to_clob
);
wwv_flow_imp_shared.create_task_def_comp_param(
 p_id=>wwv_flow_imp.id(102900000000320)
,p_workflow_activity_id=>wwv_flow_imp.id(102900000000202)
,p_task_def_param_id=>wwv_flow_imp.id(102900000000002)
,p_value_type=>'STATIC'
,p_value=>'0'
);
wwv_flow_imp_shared.create_workflow_activity(
 p_id=>wwv_flow_imp.id(102900000000203)
,p_workflow_version_id=>wwv_flow_imp.id(102900000000101)
,p_name=>'Appliquer l''affectation'
,p_static_id=>'ApplyAssignment'
,p_display_sequence=>40
,p_activity_type=>'NATIVE_INVOKE_API'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'package', 'SD_WORKFLOW_API',
  'package_method', 'ASSIGN_FROM_TASK',
  'type', 'PLSQL_PACKAGE')).to_clob
);
wwv_flow_imp_shared.create_invokeapi_comp_param(
 p_id=>wwv_flow_imp.id(102900000000302)
,p_workflow_activity_id=>wwv_flow_imp.id(102900000000203)
,p_name=>'p_ticket_id'
,p_direction=>'IN'
,p_data_type=>'NUMBER'
,p_has_default=>false
,p_display_sequence=>10
,p_value_type=>'ITEM'
,p_value=>'APEX$WORKFLOW_DETAIL_PK'
);
wwv_flow_imp_shared.create_invokeapi_comp_param(
 p_id=>wwv_flow_imp.id(102900000000303)
,p_workflow_activity_id=>wwv_flow_imp.id(102900000000203)
,p_name=>'p_task_id'
,p_direction=>'IN'
,p_data_type=>'NUMBER'
,p_has_default=>false
,p_display_sequence=>20
,p_value_type=>'ITEM'
,p_value=>'V_TRIAGE_TASK_ID'
);

wwv_flow_imp_shared.create_workflow_activity(
 p_id=>wwv_flow_imp.id(102900000000204)
,p_workflow_version_id=>wwv_flow_imp.id(102900000000101)
,p_name=>'Demarrer le traitement'
,p_static_id=>'StartProcessing'
,p_display_sequence=>50
,p_activity_type=>'NATIVE_INVOKE_API'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'package', 'SD_WORKFLOW_API',
  'package_method', 'START_PROCESSING',
  'type', 'PLSQL_PACKAGE')).to_clob
);
wwv_flow_imp_shared.create_invokeapi_comp_param(
 p_id=>wwv_flow_imp.id(102900000000304)
,p_workflow_activity_id=>wwv_flow_imp.id(102900000000204)
,p_name=>'p_ticket_id'
,p_direction=>'IN'
,p_data_type=>'NUMBER'
,p_has_default=>false
,p_display_sequence=>10
,p_value_type=>'ITEM'
,p_value=>'APEX$WORKFLOW_DETAIL_PK'
);

wwv_flow_imp_shared.create_workflow_activity(
 p_id=>wwv_flow_imp.id(102900000000205)
,p_workflow_version_id=>wwv_flow_imp.id(102900000000101)
,p_name=>'Traiter le ticket'
,p_static_id=>'ProcessingTask'
,p_display_sequence=>60
,p_activity_type=>'NATIVE_CREATE_TASK'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'details_primary_key_item', 'APEX$WORKFLOW_DETAIL_PK',
  'initiator_can_complete', 'N',
  'task_definition_id', wwv_flow_imp.id(102900000000010),
  'task_id_item', 'V_PROCESSING_TASK_ID')).to_clob
);
wwv_flow_imp_shared.create_task_def_comp_param(
 p_id=>wwv_flow_imp.id(102900000000321)
,p_workflow_activity_id=>wwv_flow_imp.id(102900000000205)
,p_task_def_param_id=>wwv_flow_imp.id(102900000000011)
,p_value_type=>'STATIC'
,p_value=>'#NOT_SET#'
);
wwv_flow_imp_shared.create_workflow_activity(
 p_id=>wwv_flow_imp.id(102900000000206)
,p_workflow_version_id=>wwv_flow_imp.id(102900000000101)
,p_name=>'Resoudre le ticket'
,p_static_id=>'ResolveTicket'
,p_display_sequence=>70
,p_activity_type=>'NATIVE_INVOKE_API'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'package', 'SD_WORKFLOW_API',
  'package_method', 'RESOLVE_FROM_TASK',
  'type', 'PLSQL_PACKAGE')).to_clob
);
wwv_flow_imp_shared.create_invokeapi_comp_param(
 p_id=>wwv_flow_imp.id(102900000000305)
,p_workflow_activity_id=>wwv_flow_imp.id(102900000000206)
,p_name=>'p_ticket_id'
,p_direction=>'IN'
,p_data_type=>'NUMBER'
,p_has_default=>false
,p_display_sequence=>10
,p_value_type=>'ITEM'
,p_value=>'APEX$WORKFLOW_DETAIL_PK'
);
wwv_flow_imp_shared.create_invokeapi_comp_param(
 p_id=>wwv_flow_imp.id(102900000000306)
,p_workflow_activity_id=>wwv_flow_imp.id(102900000000206)
,p_name=>'p_task_id'
,p_direction=>'IN'
,p_data_type=>'NUMBER'
,p_has_default=>false
,p_display_sequence=>20
,p_value_type=>'ITEM'
,p_value=>'V_PROCESSING_TASK_ID'
);

wwv_flow_imp_shared.create_workflow_activity(
 p_id=>wwv_flow_imp.id(102900000000207)
,p_workflow_version_id=>wwv_flow_imp.id(102900000000101)
,p_name=>'Valider la resolution'
,p_static_id=>'ApprovalTask'
,p_display_sequence=>80
,p_activity_type=>'NATIVE_CREATE_TASK'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'details_primary_key_item', 'APEX$WORKFLOW_DETAIL_PK',
  'initiator_can_complete', 'N',
  'outcome_item', 'V_APPROVAL_OUTCOME',
  'task_definition_id', wwv_flow_imp.id(102900000000020),
  'task_id_item', 'V_APPROVAL_TASK_ID')).to_clob
);
wwv_flow_imp_shared.create_workflow_activity(
 p_id=>wwv_flow_imp.id(102900000000208)
,p_workflow_version_id=>wwv_flow_imp.id(102900000000101)
,p_name=>'Resolution acceptee ?'
,p_static_id=>'ApprovalDecision'
,p_display_sequence=>90
,p_activity_type=>'NATIVE_WORKFLOW_SWITCH'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'compare_variable', 'V_APPROVAL_OUTCOME',
  'type', 'CHECK_WF_VARIABLE')).to_clob
);

wwv_flow_imp_shared.create_workflow_activity(
 p_id=>wwv_flow_imp.id(102900000000209)
,p_workflow_version_id=>wwv_flow_imp.id(102900000000101)
,p_name=>'Retourner en traitement'
,p_static_id=>'ReopenTicket'
,p_display_sequence=>100
,p_activity_type=>'NATIVE_INVOKE_API'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'package', 'SD_WORKFLOW_API',
  'package_method', 'REOPEN_AFTER_REJECTION',
  'type', 'PLSQL_PACKAGE')).to_clob
);
wwv_flow_imp_shared.create_invokeapi_comp_param(
 p_id=>wwv_flow_imp.id(102900000000307)
,p_workflow_activity_id=>wwv_flow_imp.id(102900000000209)
,p_name=>'p_ticket_id'
,p_direction=>'IN'
,p_data_type=>'NUMBER'
,p_has_default=>false
,p_display_sequence=>10
,p_value_type=>'ITEM'
,p_value=>'APEX$WORKFLOW_DETAIL_PK'
);

wwv_flow_imp_shared.create_workflow_activity(
 p_id=>wwv_flow_imp.id(102900000000210)
,p_workflow_version_id=>wwv_flow_imp.id(102900000000101)
,p_name=>'Fermer le ticket'
,p_static_id=>'CloseTicket'
,p_display_sequence=>110
,p_activity_type=>'NATIVE_INVOKE_API'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'package', 'SD_WORKFLOW_API',
  'package_method', 'CLOSE_AFTER_APPROVAL',
  'type', 'PLSQL_PACKAGE')).to_clob
);
wwv_flow_imp_shared.create_invokeapi_comp_param(
 p_id=>wwv_flow_imp.id(102900000000308)
,p_workflow_activity_id=>wwv_flow_imp.id(102900000000210)
,p_name=>'p_ticket_id'
,p_direction=>'IN'
,p_data_type=>'NUMBER'
,p_has_default=>false
,p_display_sequence=>10
,p_value_type=>'ITEM'
,p_value=>'APEX$WORKFLOW_DETAIL_PK'
);

wwv_flow_imp_shared.create_workflow_activity(
 p_id=>wwv_flow_imp.id(102900000000211)
,p_workflow_version_id=>wwv_flow_imp.id(102900000000101)
,p_name=>'Fin'
,p_static_id=>'End'
,p_display_sequence=>120
,p_activity_type=>'NATIVE_WORKFLOW_END'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'end_state', 'COMPLETED')).to_clob
);

wwv_flow_imp_shared.create_workflow_transition(p_id=>wwv_flow_imp.id(102900000000400),p_name=>'Suivant',p_transition_type=>'NORMAL',p_from_activity_id=>wwv_flow_imp.id(102900000000200),p_to_activity_id=>wwv_flow_imp.id(102900000000201));
wwv_flow_imp_shared.create_workflow_transition(p_id=>wwv_flow_imp.id(102900000000401),p_name=>'Suivant',p_transition_type=>'NORMAL',p_from_activity_id=>wwv_flow_imp.id(102900000000201),p_to_activity_id=>wwv_flow_imp.id(102900000000202));
wwv_flow_imp_shared.create_workflow_transition(p_id=>wwv_flow_imp.id(102900000000402),p_name=>'Suivant',p_transition_type=>'NORMAL',p_from_activity_id=>wwv_flow_imp.id(102900000000202),p_to_activity_id=>wwv_flow_imp.id(102900000000203));
wwv_flow_imp_shared.create_workflow_transition(p_id=>wwv_flow_imp.id(102900000000403),p_name=>'Suivant',p_transition_type=>'NORMAL',p_from_activity_id=>wwv_flow_imp.id(102900000000203),p_to_activity_id=>wwv_flow_imp.id(102900000000204));
wwv_flow_imp_shared.create_workflow_transition(p_id=>wwv_flow_imp.id(102900000000404),p_name=>'Suivant',p_transition_type=>'NORMAL',p_from_activity_id=>wwv_flow_imp.id(102900000000204),p_to_activity_id=>wwv_flow_imp.id(102900000000205));
wwv_flow_imp_shared.create_workflow_transition(p_id=>wwv_flow_imp.id(102900000000405),p_name=>'Suivant',p_transition_type=>'NORMAL',p_from_activity_id=>wwv_flow_imp.id(102900000000205),p_to_activity_id=>wwv_flow_imp.id(102900000000206));
wwv_flow_imp_shared.create_workflow_transition(p_id=>wwv_flow_imp.id(102900000000406),p_name=>'Suivant',p_transition_type=>'NORMAL',p_from_activity_id=>wwv_flow_imp.id(102900000000206),p_to_activity_id=>wwv_flow_imp.id(102900000000207));
wwv_flow_imp_shared.create_workflow_transition(p_id=>wwv_flow_imp.id(102900000000407),p_name=>'Suivant',p_transition_type=>'NORMAL',p_from_activity_id=>wwv_flow_imp.id(102900000000207),p_to_activity_id=>wwv_flow_imp.id(102900000000208));
wwv_flow_imp_shared.create_workflow_transition(p_id=>wwv_flow_imp.id(102900000000408),p_name=>'Approuvee',p_execution_sequence=>10,p_transition_type=>'BRANCH',p_from_activity_id=>wwv_flow_imp.id(102900000000208),p_to_activity_id=>wwv_flow_imp.id(102900000000210),p_condition_expr1=>'APPROVED');
wwv_flow_imp_shared.create_workflow_transition(p_id=>wwv_flow_imp.id(102900000000409),p_name=>'Refusee',p_execution_sequence=>20,p_transition_type=>'BRANCH',p_from_activity_id=>wwv_flow_imp.id(102900000000208),p_to_activity_id=>wwv_flow_imp.id(102900000000209),p_condition_expr1=>'REJECTED');
wwv_flow_imp_shared.create_workflow_transition(p_id=>wwv_flow_imp.id(102900000000410),p_name=>'Reprendre',p_transition_type=>'NORMAL',p_from_activity_id=>wwv_flow_imp.id(102900000000209),p_to_activity_id=>wwv_flow_imp.id(102900000000205));
wwv_flow_imp_shared.create_workflow_transition(p_id=>wwv_flow_imp.id(102900000000411),p_name=>'Terminer',p_transition_type=>'NORMAL',p_from_activity_id=>wwv_flow_imp.id(102900000000210),p_to_activity_id=>wwv_flow_imp.id(102900000000211));

wwv_flow_imp_shared.create_workflow_participant(
 p_id=>wwv_flow_imp.id(102900000000500)
,p_workflow_version_id=>wwv_flow_imp.id(102900000000101)
,p_participant_type=>'OWNER'
,p_name=>'Equipe Service Desk'
,p_identity_type=>'USER'
,p_value_type=>'EXPRESSION'
,p_value_language=>'PLSQL'
,p_value=>'sd_workflow_api.admin_usernames'
);
wwv_flow_imp_shared.create_workflow_participant(
 p_id=>wwv_flow_imp.id(102900000000501)
,p_workflow_version_id=>wwv_flow_imp.id(102900000000101)
,p_participant_type=>'ADMIN'
,p_name=>'Administrateurs Service Desk'
,p_identity_type=>'USER'
,p_value_type=>'EXPRESSION'
,p_value_language=>'PLSQL'
,p_value=>'sd_workflow_api.admin_usernames'
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
