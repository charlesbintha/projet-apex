prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
-- Oracle APEX page export
-- Application 102 - Service Desk Lite / Demande Interne
-- Page 10        - Liste des tickets
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

prompt --application/pages/delete_00010
begin
wwv_flow_imp_page.remove_page(
 p_flow_id=>wwv_flow.g_flow_id
,p_page_id=>10
);
end;
/

prompt --application/pages/page_00010
begin
wwv_flow_imp_page.create_page(
 p_id=>10
,p_name=>'Liste des tickets'
,p_alias=>'TICKETS'
,p_step_title=>'Liste des tickets - Service Desk Lite'
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_css_file_urls=>'#APP_FILES#app.css'
,p_step_template=>4073832297226169690
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'23'
);

wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(102010000000001)
,p_plug_name=>'Tickets'
,p_static_id=>'tickets-breadcrumb'
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
 p_id=>wwv_flow_imp.id(102010000000002)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(102010000000001)
,p_button_name=>'NEW_TICKET'
,p_static_id=>'new-ticket'
,p_show_as_disabled=>false
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--success:t-Button--iconLeft'
,p_button_template_id=>2084305881903810008
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Nouveau ticket'
,p_button_position=>'CREATE'
,p_button_redirect_url=>'f?p=&APP_ID.:11:&SESSION.::&DEBUG.:11'
,p_icon_css_classes=>'fa-plus'
);

wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(102010000000010)
,p_plug_name=>'Filtres'
,p_static_id=>'ticket-filters'
,p_region_css_classes=>'sd-form-region'
,p_region_template_options=>'#DEFAULT#:t-Region--noPadding'
,p_plug_template=>4073835273271169698
,p_plug_display_sequence=>20
,p_plug_item_display_point=>'ABOVE'
,p_location=>null
,p_plug_source_type=>'NATIVE_STATIC'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(102010000000011)
,p_button_sequence=>80
,p_button_plug_id=>wwv_flow_imp.id(102010000000010)
,p_button_name=>'APPLY_FILTERS'
,p_static_id=>'apply-filters'
,p_show_as_disabled=>false
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--iconLeft'
,p_button_template_id=>2084305881903810008
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Filtrer'
,p_button_position=>'CREATE'
,p_warn_on_unsaved_changes=>null
,p_icon_css_classes=>'fa-filter'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(102010000000012)
,p_button_sequence=>90
,p_button_plug_id=>wwv_flow_imp.id(102010000000010)
,p_button_name=>'RESET_FILTERS'
,p_static_id=>'reset-filters'
,p_show_as_disabled=>false
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--iconLeft'
,p_button_template_id=>2084305881903810008
,p_button_image_alt=>'Reinitialiser'
,p_button_position=>'CREATE'
,p_button_redirect_url=>'f?p=&APP_ID.:10:&SESSION.::&DEBUG.:10::'
,p_icon_css_classes=>'fa-undo'
);

wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(102010000000020)
,p_name=>'P10_SEARCH'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(102010000000010)
,p_prompt=>'Recherche'
,p_placeholder=>'Numero, objet ou demandeur'
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_cMaxlength=>200
,p_colspan=>3
,p_field_template=>3033038003750078790
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'Y',
  'subtype', 'SEARCH',
  'trim_spaces', 'BOTH')).to_clob
);

wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(102010000000021)
,p_name=>'P10_STATUS_CODE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(102010000000010)
,p_prompt=>'Statut'
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:Nouveau;NEW,Affecte;ASSIGNED,En cours;IN_PROGRESS,Resolu;RESOLVED,Ferme;CLOSED'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'Tous les statuts'
,p_begin_on_new_line=>'N'
,p_colspan=>2
,p_field_template=>3033038003750078790
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);

wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(102010000000022)
,p_name=>'P10_PRIORITY_CODE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(102010000000010)
,p_prompt=>'Priorite'
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:Faible;LOW,Moyenne;MEDIUM,Haute;HIGH,Urgente;URGENT'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'Toutes les priorites'
,p_begin_on_new_line=>'N'
,p_colspan=>2
,p_field_template=>3033038003750078790
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);

wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(102010000000023)
,p_name=>'P10_CATEGORY_ID'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(102010000000010)
,p_prompt=>'Categorie'
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select category_name d, category_id r from sd_categories where is_active = ''Y'' order by display_order, category_name'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'Toutes les categories'
,p_begin_on_new_line=>'N'
,p_colspan=>2
,p_field_template=>3033038003750078790
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);

wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(102010000000024)
,p_name=>'P10_ASSIGNED_AGENT_ID'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(102010000000010)
,p_prompt=>'Agent affecte'
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select full_name d, agent_id r from sd_agents where is_active = ''Y'' order by full_name'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'Tous les agents'
,p_begin_on_new_line=>'N'
,p_colspan=>3
,p_field_template=>3033038003750078790
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);

wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(102010000000025)
,p_name=>'P10_STATUS_SCOPE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(102010000000010)
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);

wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(102010000000026)
,p_name=>'P10_UNASSIGNED'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(102010000000010)
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);

wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(102010000000027)
,p_name=>'P10_RESOLVED_TODAY'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(102010000000010)
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);

wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(102010000000030)
,p_plug_name=>'Tous les tickets'
,p_static_id=>'tickets-report'
,p_region_css_classes=>'sd-report-region'
,p_region_template_options=>'#DEFAULT#:t-Region--noPadding'
,p_plug_template=>4073835273271169698
,p_plug_display_sequence=>30
,p_plug_item_display_point=>'ABOVE'
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select ticket_id,',
'       ticket_number,',
'       subject,',
'       category_name,',
'       ''<span class="sd-priority-badge '' ||',
'         apex_escape.html_attribute(priority_css_class) || ''">'' ||',
'         apex_escape.html(priority_label) || ''</span>'' priority,',
'       ''<span class="sd-status-badge '' ||',
'         apex_escape.html_attribute(status_css_class) || ''">'' ||',
'         apex_escape.html(status_label) || ''</span>'' status,',
'       requester_name,',
'       nvl(assigned_agent_name, ''Non affecte'') assigned_agent_name,',
'       created_at,',
'       updated_at,',
'       apex_page.get_url(',
'         p_page        => 20,',
'         p_clear_cache => ''20'',',
'         p_items       => ''P20_TICKET_ID'',',
'         p_values      => ticket_id',
'       ) detail_url',
'  from sd_ticket_overview_v',
' where (:P10_STATUS_CODE is null or status_code = :P10_STATUS_CODE)',
'   and (:P10_PRIORITY_CODE is null or priority_code = :P10_PRIORITY_CODE)',
'   and (:P10_CATEGORY_ID is null or category_id = :P10_CATEGORY_ID)',
'   and (:P10_ASSIGNED_AGENT_ID is null or assigned_agent_id = :P10_ASSIGNED_AGENT_ID)',
'   and (',
'         :P10_SEARCH is null',
'         or upper(ticket_number) like ''%'' || upper(trim(:P10_SEARCH)) || ''%''',
'         or upper(subject) like ''%'' || upper(trim(:P10_SEARCH)) || ''%''',
'         or upper(requester_name) like ''%'' || upper(trim(:P10_SEARCH)) || ''%''',
'       )',
'   and (',
'         :P10_STATUS_SCOPE is null',
'         or :P10_STATUS_SCOPE <> ''OPEN''',
'         or status_code not in (''RESOLVED'', ''CLOSED'')',
'       )',
'   and (',
'         :P10_UNASSIGNED is null',
'         or :P10_UNASSIGNED <> ''Y''',
'         or assigned_agent_id is null',
'       )',
'   and (',
'         :P10_RESOLVED_TODAY is null',
'         or :P10_RESOLVED_TODAY <> ''Y''',
'         or (',
'              status_code in (''RESOLVED'', ''CLOSED'')',
'              and cast(resolved_at as date) >= trunc(sysdate)',
'              and cast(resolved_at as date) < trunc(sysdate) + 1',
'            )',
'       )',
' order by created_at desc'))
,p_ajax_items_to_submit=>'P10_SEARCH,P10_STATUS_CODE,P10_PRIORITY_CODE,P10_CATEGORY_ID,P10_ASSIGNED_AGENT_ID,P10_STATUS_SCOPE,P10_UNASSIGNED,P10_RESOLVED_TODAY'
,p_lazy_loading=>false
,p_plug_source_type=>'NATIVE_IR'
);

wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(102010000000031)
,p_max_row_count=>'1000000'
,p_no_data_found_message=>'Aucun ticket ne correspond aux filtres.'
,p_pagination_type=>'ROWS_X_TO_Y_OF_Z'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'N'
,p_owner=>'CHARLES.BINTHA'
,p_internal_uid=>102010000000031
);

wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(102010000000032)
,p_db_column_name=>'TICKET_ID'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'ID'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
);

wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(102010000000033)
,p_db_column_name=>'TICKET_NUMBER'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'Ticket'
,p_column_link=>'#DETAIL_URL#'
,p_column_linktext=>'#TICKET_NUMBER#'
,p_column_link_attr=>'class="sd-ticket-link" aria-label="Ouvrir le ticket #TICKET_NUMBER#"'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
);

wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(102010000000034)
,p_db_column_name=>'SUBJECT'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'Objet'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
);

wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(102010000000035)
,p_db_column_name=>'CATEGORY_NAME'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'Categorie'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
);

wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(102010000000036)
,p_db_column_name=>'PRIORITY'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'Priorite'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'LEFT'
);

wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(102010000000037)
,p_db_column_name=>'STATUS'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'Statut'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'LEFT'
);

wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(102010000000038)
,p_db_column_name=>'REQUESTER_NAME'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'Demandeur'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
);

wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(102010000000039)
,p_db_column_name=>'ASSIGNED_AGENT_NAME'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'Agent affecte'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
);

wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(102010000000040)
,p_db_column_name=>'CREATED_AT'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'Cree le'
,p_column_type=>'DATE'
,p_format_mask=>'DD/MM/YYYY HH24:MI'
,p_heading_alignment=>'LEFT'
);

wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(102010000000041)
,p_db_column_name=>'UPDATED_AT'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'Mis a jour le'
,p_column_type=>'DATE'
,p_format_mask=>'DD/MM/YYYY HH24:MI'
,p_heading_alignment=>'LEFT'
);

wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(102010000000042)
,p_db_column_name=>'DETAIL_URL'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'Lien detail'
,p_column_type=>'STRING'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
);

wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(102010000000043)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'102010'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'TICKET_NUMBER:SUBJECT:CATEGORY_NAME:PRIORITY:STATUS:REQUESTER_NAME:ASSIGNED_AGENT_NAME:CREATED_AT:UPDATED_AT'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(102010000000050)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Retirer les filtres contextuels'
,p_static_id=>'clear-context-filters'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  :P10_STATUS_SCOPE := null;',
'  :P10_UNASSIGNED := null;',
'  :P10_RESOLVED_TODAY := null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(102010000000011)
,p_internal_uid=>102010000000050
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
