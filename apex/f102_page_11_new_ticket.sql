prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
-- Oracle APEX page export
-- Application 102 - Service Desk Lite / Demande Interne
-- Page 11        - Nouveau ticket
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

prompt --application/pages/delete_00011
begin
wwv_flow_imp_page.remove_page(
 p_flow_id=>wwv_flow.g_flow_id
,p_page_id=>11
);
end;
/

prompt --application/pages/page_00011
begin
wwv_flow_imp_page.create_page(
 p_id=>11
,p_name=>'Nouveau ticket'
,p_alias=>'NOUVEAU-TICKET'
,p_step_title=>'Nouveau ticket - Service Desk Lite'
,p_first_item=>'AUTO_FIRST_ITEM'
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_css_file_urls=>'#APP_FILES#app.css'
,p_step_template=>4073832297226169690
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'11'
);

wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(102011000000001)
,p_plug_name=>'Creer un ticket'
,p_static_id=>'new-ticket-breadcrumb'
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
 p_id=>wwv_flow_imp.id(102011000000010)
,p_plug_name=>'Informations de la demande'
,p_static_id=>'new-ticket-form'
,p_region_css_classes=>'sd-form-region'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4073835273271169698
,p_plug_display_sequence=>20
,p_plug_item_display_point=>'ABOVE'
,p_location=>null
,p_plug_source_type=>'NATIVE_STATIC'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(102011000000020)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(102011000000001)
,p_button_name=>'CANCEL'
,p_static_id=>'cancel'
,p_show_as_disabled=>false
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--iconLeft'
,p_button_template_id=>2350584059425431644
,p_button_image_alt=>'Annuler'
,p_button_position=>'PREVIOUS'
,p_button_redirect_url=>'f?p=&APP_ID.:10:&SESSION.::&DEBUG.:10'
,p_icon_css_classes=>'fa-arrow-left'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(102011000000021)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(102011000000001)
,p_button_name=>'CREATE_TICKET'
,p_static_id=>'create-ticket'
,p_show_as_disabled=>false
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--success:t-Button--iconLeft'
,p_button_template_id=>2084305881903810008
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Creer le ticket'
,p_button_position=>'CREATE'
,p_warn_on_unsaved_changes=>null
,p_icon_css_classes=>'fa-plus'
);

wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(102011000000022)
,p_branch_name=>'Ouvrir le ticket cree'
,p_branch_action=>'f?p=&APP_ID.:20:&SESSION.::&DEBUG.:20:P20_TICKET_ID:&P11_TICKET_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_when_button_id=>wwv_flow_imp.id(102011000000021)
,p_branch_sequence=>10
);

wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(102011000000030)
,p_name=>'P11_TICKET_ID'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(102011000000010)
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);

wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(102011000000031)
,p_name=>'P11_SUBJECT'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(102011000000010)
,p_prompt=>'Objet'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>60
,p_cMaxlength=>200
,p_colspan=>12
,p_field_template=>2528236951996823187
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);

wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(102011000000032)
,p_name=>'P11_DESCRIPTION'
,p_source_data_type=>'CLOB'
,p_is_required=>true
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(102011000000010)
,p_prompt=>'Description detaillee'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cHeight=>7
,p_colspan=>12
,p_field_template=>2528236951996823187
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'Y',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);

wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(102011000000033)
,p_name=>'P11_CATEGORY_ID'
,p_source_data_type=>'NUMBER'
,p_is_required=>true
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(102011000000010)
,p_prompt=>'Categorie'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select category_name d, category_id r from sd_categories where is_active = ''Y'' order by display_order, category_name'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'Selectionner une categorie'
,p_colspan=>6
,p_field_template=>2528236951996823187
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);

wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(102011000000034)
,p_name=>'P11_PRIORITY_CODE'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(102011000000010)
,p_item_default=>'MEDIUM'
,p_prompt=>'Priorite'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:Faible;LOW,Moyenne;MEDIUM,Haute;HIGH,Urgente;URGENT'
,p_lov_display_null=>'NO'
,p_begin_on_new_line=>'N'
,p_colspan=>6
,p_field_template=>2528236951996823187
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);

wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(102011000000035)
,p_name=>'P11_REQUESTER_NAME'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(102011000000010)
,p_prompt=>'Nom du demandeur'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>150
,p_colspan=>6
,p_field_template=>2528236951996823187
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);

wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(102011000000036)
,p_name=>'P11_REQUESTER_EMAIL'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(102011000000010)
,p_prompt=>'Adresse electronique'
,p_placeholder=>'nom@entreprise.sn'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>255
,p_begin_on_new_line=>'N'
,p_colspan=>6
,p_field_template=>2528236951996823187
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'EMAIL',
  'trim_spaces', 'BOTH')).to_clob
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(102011000000040)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Creer le ticket'
,p_static_id=>'create-ticket-process'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  :P11_TICKET_ID := sd_ticket_api.create_ticket(',
'    p_subject         => :P11_SUBJECT,',
'    p_description     => :P11_DESCRIPTION,',
'    p_category_id     => :P11_CATEGORY_ID,',
'    p_priority_code   => :P11_PRIORITY_CODE,',
'    p_requester_name  => :P11_REQUESTER_NAME,',
'    p_requester_email => :P11_REQUESTER_EMAIL,',
'    p_created_by      => :APP_USER',
'  );',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(102011000000021)
,p_process_success_message=>'Le ticket a ete cree avec succes.'
,p_internal_uid=>102011000000040
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(102011000000041)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_WORKFLOW'
,p_process_name=>'Demarrer le cycle de vie du ticket'
,p_static_id=>'start-ticket-lifecycle-workflow'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'details_primary_key_item', 'P11_TICKET_ID',
  'type', 'START',
  'workflow_definition_id', wwv_flow_imp.id(102900000000100))).to_clob
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(102011000000021)
,p_internal_uid=>102011000000041
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
