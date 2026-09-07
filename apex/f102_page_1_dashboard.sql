prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- Oracle APEX page export
-- Application 102 - Service Desk Lite / Demande Interne
-- Page 1         - Tableau de bord
-- Target APEX    - 26.1.4
--
-- Navigation contract used by this page:
--   Page 10: P10_STATUS_SCOPE, P10_STATUS_CODE, P10_PRIORITY_CODE,
--            P10_UNASSIGNED, P10_RESOLVED_TODAY
--   Page 20: P20_TICKET_ID
--
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

prompt --application/pages/delete_00001
begin
wwv_flow_imp_page.remove_page(
 p_flow_id=>wwv_flow.g_flow_id
,p_page_id=>1
);
end;
/

prompt --application/pages/page_00001
begin
wwv_flow_imp_page.create_page(
 p_id=>1
,p_name=>'Tableau de bord'
,p_alias=>'TABLEAU-DE-BORD'
,p_step_title=>'Tableau de bord - Service Desk Lite'
,p_first_item=>'AUTO_FIRST_ITEM'
,p_autocomplete_on_off=>'ON'
,p_css_file_urls=>'#APP_FILES#app.css'
,p_step_template=>4073832297226169690
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'13'
);

wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(102001000000001)
,p_plug_name=>'Fil d''Ariane'
,p_static_id=>'dashboard-breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
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
 p_id=>wwv_flow_imp.id(102001000000002)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(102001000000001)
,p_button_name=>'TICKETS'
,p_static_id=>'tickets'
,p_show_as_disabled=>false
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--iconLeft'
,p_button_template_id=>2084305881903810008
,p_button_image_alt=>'Liste des tickets'
,p_button_position=>'CREATE'
,p_button_redirect_url=>'f?p=&APP_ID.:10:&SESSION.::&DEBUG.:10'
,p_icon_css_classes=>'fa-list'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(102001000000003)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(102001000000001)
,p_button_name=>'MY_TASKS'
,p_static_id=>'my-tasks'
,p_show_as_disabled=>false
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--success:t-Button--iconLeft'
,p_button_template_id=>2084305881903810008
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Mes taches'
,p_button_position=>'CREATE'
,p_button_redirect_url=>'f?p=&APP_ID.:30:&SESSION.::&DEBUG.:30'
,p_icon_css_classes=>'fa-clipboard-check-alt'
);

wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(102001000000010)
,p_plug_name=>'Indicateurs cles'
,p_static_id=>'sd-dashboard-kpis'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4502917002193490937
,p_plug_display_sequence=>10
,p_plug_item_display_point=>'ABOVE'
,p_location=>null
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'  l_html             clob;',
'  l_open             number;',
'  l_urgent           number;',
'  l_unassigned       number;',
'  l_resolved_today   number;',
'  l_open_url         varchar2(4000);',
'  l_urgent_url       varchar2(4000);',
'  l_unassigned_url   varchar2(4000);',
'  l_resolved_url     varchar2(4000);',
'begin',
'  select count(case when status_code not in (''RESOLVED'', ''CLOSED'') then 1 end),',
'         count(case when priority_code = ''URGENT''',
'                          and status_code not in (''RESOLVED'', ''CLOSED'') then 1 end),',
'         count(case when assigned_agent_id is null',
'                          and status_code not in (''RESOLVED'', ''CLOSED'') then 1 end),',
'         count(case when status_code in (''RESOLVED'', ''CLOSED'')',
'                          and cast(resolved_at as date) >= trunc(sysdate)',
'                          and cast(resolved_at as date) < trunc(sysdate) + 1 then 1 end)',
'    into l_open, l_urgent, l_unassigned, l_resolved_today',
'    from sd_tickets;',
'',
'  l_open_url := apex_page.get_url(',
'    p_page        => 10,',
'    p_clear_cache => ''10'',',
'    p_items       => ''P10_STATUS_SCOPE'',',
'    p_values      => ''OPEN'');',
'',
'  l_urgent_url := apex_page.get_url(',
'    p_page        => 10,',
'    p_clear_cache => ''10'',',
'    p_items       => ''P10_PRIORITY_CODE'',',
'    p_values      => ''URGENT'');',
'',
'  l_unassigned_url := apex_page.get_url(',
'    p_page        => 10,',
'    p_clear_cache => ''10'',',
'    p_items       => ''P10_UNASSIGNED'',',
'    p_values      => ''Y'');',
'',
'  l_resolved_url := apex_page.get_url(',
'    p_page        => 10,',
'    p_clear_cache => ''10'',',
'    p_items       => ''P10_RESOLVED_TODAY'',',
'    p_values      => ''Y'');',
'',
'  l_html := ''<div class="sd-kpi-grid">'' ||',
'    ''<a class="sd-kpi-card sd-kpi-open" href="'' ||',
'      apex_escape.html_attribute(l_open_url) ||',
'      ''" aria-label="Afficher les tickets ouverts">'' ||',
'      ''<span class="sd-kpi-icon fa fa-folder-open-o" aria-hidden="true"></span>'' ||',
'      ''<span class="sd-kpi-content"><strong>'' || l_open ||',
'      ''</strong><span>Tickets ouverts</span></span></a>'' ||',
'',
'    ''<a class="sd-kpi-card sd-kpi-urgent" href="'' ||',
'      apex_escape.html_attribute(l_urgent_url) ||',
'      ''" aria-label="Afficher les tickets urgents">'' ||',
'      ''<span class="sd-kpi-icon fa fa-exclamation-triangle" aria-hidden="true"></span>'' ||',
'      ''<span class="sd-kpi-content"><strong>'' || l_urgent ||',
'      ''</strong><span>Tickets urgents</span></span></a>'' ||',
'',
'    ''<a class="sd-kpi-card sd-kpi-unassigned" href="'' ||',
'      apex_escape.html_attribute(l_unassigned_url) ||',
'      ''" aria-label="Afficher les tickets non affectes">'' ||',
'      ''<span class="sd-kpi-icon fa fa-user-times" aria-hidden="true"></span>'' ||',
'      ''<span class="sd-kpi-content"><strong>'' || l_unassigned ||',
'      ''</strong><span>Tickets non affectes</span></span></a>'' ||',
'',
'    ''<a class="sd-kpi-card sd-kpi-resolved" href="'' ||',
'      apex_escape.html_attribute(l_resolved_url) ||',
'      ''" aria-label="Afficher les tickets resolus aujourd hui">'' ||',
'      ''<span class="sd-kpi-icon fa fa-check-circle" aria-hidden="true"></span>'' ||',
'      ''<span class="sd-kpi-content"><strong>'' || l_resolved_today ||',
'      ''</strong><span>Resolus aujourd&#39;hui</span></span></a>'' ||',
'    ''</div>'';',
'',
'  return l_html;',
'end;'))
,p_lazy_loading=>false
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);

wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(102001000000020)
,p_plug_name=>'Tickets par statut'
,p_static_id=>'sd-chart-status'
,p_region_css_classes=>'sd-chart-region'
,p_region_template_options=>'#DEFAULT#'
,p_escape_on_http_output=>'Y'
,p_plug_template=>4073835273271169698
,p_plug_display_sequence=>20
,p_plug_grid_column_span=>6
,p_plug_item_display_point=>'ABOVE'
,p_location=>null
,p_plug_source_type=>'NATIVE_JET_CHART'
);

wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(102001000000021)
,p_region_id=>wwv_flow_imp.id(102001000000020)
,p_chart_type=>'donut'
,p_height=>'320'
,p_animation_on_display=>'alphaFade'
,p_animation_on_data_change=>'auto'
,p_data_cursor=>'auto'
,p_data_cursor_behavior=>'auto'
,p_hide_and_show_behavior=>'withRescale'
,p_hover_behavior=>'dim'
,p_stack=>'off'
,p_stack_label=>'off'
,p_connect_nulls=>'Y'
,p_value_format_scaling=>'none'
,p_sorting=>'value-desc'
,p_fill_multi_series_gaps=>true
,p_tooltip_rendered=>'Y'
,p_show_series_name=>false
,p_show_group_name=>true
,p_show_value=>true
,p_legend_rendered=>'on'
,p_legend_position=>'auto'
,p_overview_rendered=>'off'
,p_pie_other_threshold=>0
,p_pie_selection_effect=>'highlight'
);

wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(102001000000022)
,p_chart_id=>wwv_flow_imp.id(102001000000021)
,p_static_id=>'tickets-par-statut'
,p_seq=>10
,p_name=>'Tickets'
,p_data_source_type=>'SQL'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select case status_code',
'         when ''NEW'' then ''Nouveau''',
'         when ''ASSIGNED'' then ''Affecte''',
'         when ''IN_PROGRESS'' then ''En cours''',
'         when ''RESOLVED'' then ''Resolu''',
'         when ''CLOSED'' then ''Ferme''',
'       end label,',
'       count(*) value,',
'       case status_code',
'         when ''NEW'' then ''#64748B''',
'         when ''ASSIGNED'' then ''#2563EB''',
'         when ''IN_PROGRESS'' then ''#F59E0B''',
'         when ''RESOLVED'' then ''#16A34A''',
'         when ''CLOSED'' then ''#475569''',
'       end color,',
'       apex_page.get_url(',
'         p_page        => 10,',
'         p_clear_cache => ''10'',',
'         p_items       => ''P10_STATUS_CODE'',',
'         p_values      => status_code) link',
'  from sd_tickets',
' group by status_code',
' order by decode(status_code,',
'   ''NEW'', 1, ''ASSIGNED'', 2, ''IN_PROGRESS'', 3, ''RESOLVED'', 4, ''CLOSED'', 5)'))
,p_series_type=>'donut'
,p_items_value_column_name=>'VALUE'
,p_items_label_column_name=>'LABEL'
,p_color=>'&COLOR.'
,p_items_label_rendered=>false
,p_items_label_display_as=>'PERCENT'
,p_threshold_display=>'onIndicator'
,p_link_target=>'&LINK.'
,p_link_target_type=>'REDIRECT_URL'
);

wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(102001000000030)
,p_plug_name=>'Tickets par priorite'
,p_static_id=>'sd-chart-priority'
,p_region_css_classes=>'sd-chart-region'
,p_region_template_options=>'#DEFAULT#'
,p_escape_on_http_output=>'Y'
,p_plug_template=>4073835273271169698
,p_plug_display_sequence=>30
,p_plug_new_grid_row=>false
,p_plug_grid_column_span=>6
,p_plug_item_display_point=>'ABOVE'
,p_location=>null
,p_plug_source_type=>'NATIVE_JET_CHART'
);

wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(102001000000031)
,p_region_id=>wwv_flow_imp.id(102001000000030)
,p_chart_type=>'bar'
,p_height=>'320'
,p_animation_on_display=>'alphaFade'
,p_animation_on_data_change=>'auto'
,p_orientation=>'vertical'
,p_data_cursor=>'auto'
,p_data_cursor_behavior=>'auto'
,p_hide_and_show_behavior=>'withRescale'
,p_hover_behavior=>'dim'
,p_stack=>'off'
,p_stack_label=>'off'
,p_connect_nulls=>'Y'
,p_sorting=>'label-asc'
,p_fill_multi_series_gaps=>true
,p_zoom_and_scroll=>'off'
,p_tooltip_rendered=>'Y'
,p_show_series_name=>false
,p_show_group_name=>true
,p_show_value=>true
,p_legend_rendered=>'off'
,p_legend_position=>'auto'
,p_overview_rendered=>'off'
);

wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(102001000000032)
,p_chart_id=>wwv_flow_imp.id(102001000000031)
,p_static_id=>'tickets-par-priorite'
,p_seq=>10
,p_name=>'Tickets'
,p_data_source_type=>'SQL'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select case priority_code',
'         when ''LOW'' then ''Faible''',
'         when ''MEDIUM'' then ''Moyenne''',
'         when ''HIGH'' then ''Haute''',
'         when ''URGENT'' then ''Urgente''',
'       end label,',
'       count(*) value,',
'       case priority_code',
'         when ''LOW'' then ''#16A34A''',
'         when ''MEDIUM'' then ''#2563EB''',
'         when ''HIGH'' then ''#F59E0B''',
'         when ''URGENT'' then ''#DC2626''',
'       end color,',
'       apex_page.get_url(',
'         p_page        => 10,',
'         p_clear_cache => ''10'',',
'         p_items       => ''P10_PRIORITY_CODE'',',
'         p_values      => priority_code) link',
'  from sd_tickets',
' group by priority_code',
' order by decode(priority_code,',
'   ''LOW'', 1, ''MEDIUM'', 2, ''HIGH'', 3, ''URGENT'', 4)'))
,p_series_type=>'bar'
,p_items_value_column_name=>'VALUE'
,p_items_label_column_name=>'LABEL'
,p_color=>'&COLOR.'
,p_assigned_to_y2=>'off'
,p_items_label_rendered=>false
,p_items_label_display_as=>'PERCENT'
,p_threshold_display=>'onIndicator'
,p_link_target=>'&LINK.'
,p_link_target_type=>'REDIRECT_URL'
);

wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(102001000000033)
,p_chart_id=>wwv_flow_imp.id(102001000000031)
,p_static_id=>'x'
,p_axis=>'x'
,p_is_rendered=>'on'
,p_format_scaling=>'auto'
,p_scaling=>'linear'
,p_baseline_scaling=>'zero'
,p_major_tick_rendered=>'on'
,p_minor_tick_rendered=>'off'
,p_tick_label_rendered=>'on'
,p_tick_label_rotation=>'auto'
,p_tick_label_position=>'outside'
);

wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(102001000000034)
,p_chart_id=>wwv_flow_imp.id(102001000000031)
,p_static_id=>'y'
,p_axis=>'y'
,p_title=>'Nombre de tickets'
,p_is_rendered=>'on'
,p_format_type=>'decimal'
,p_format_scaling=>'none'
,p_decimal_places=>0
,p_scaling=>'linear'
,p_baseline_scaling=>'zero'
,p_position=>'auto'
,p_major_tick_rendered=>'on'
,p_minor_tick_rendered=>'off'
,p_tick_label_rendered=>'on'
);

wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(102001000000040)
,p_plug_name=>'Cinq tickets les plus recents'
,p_static_id=>'sd-recent-tickets'
,p_region_css_classes=>'sd-report-region'
,p_region_template_options=>'#DEFAULT#:t-Region--noPadding'
,p_plug_template=>4073835273271169698
,p_plug_display_sequence=>40
,p_plug_item_display_point=>'ABOVE'
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select ticket_id,',
'       ticket_number,',
'       subject,',
'       category_name,',
'       priority_label,',
'       status_label,',
'       nvl(assigned_agent_name, ''Non affecte'') assigned_agent_name,',
'       created_at,',
'       apex_page.get_url(',
'         p_page        => 20,',
'         p_clear_cache => ''20'',',
'         p_items       => ''P20_TICKET_ID'',',
'         p_values      => ticket_id) detail_url',
'  from sd_ticket_overview_v',
' order by created_at desc',
' fetch first 5 rows only'))
,p_plug_source_type=>'NATIVE_IR'
,p_plug_query_num_rows=>5
);

wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(102001000000041)
,p_max_row_count=>'5'
,p_no_data_found_message=>'Aucun ticket disponible.'
,p_pagination_type=>'ROWS_X_TO_Y_OF_Z'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:XLSX'
,p_enable_mail_download=>'N'
,p_owner=>'CHARLES.BINTHA'
,p_internal_uid=>102001000000041
);

wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(102001000000042)
,p_db_column_name=>'TICKET_ID'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'ID'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
);

wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(102001000000043)
,p_db_column_name=>'TICKET_NUMBER'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'Ticket'
,p_column_link=>'#DETAIL_URL#'
,p_column_linktext=>'#TICKET_NUMBER#'
,p_column_link_attr=>'class="sd-ticket-link"'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
);

wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(102001000000044)
,p_db_column_name=>'SUBJECT'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'Objet'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
);

wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(102001000000045)
,p_db_column_name=>'CATEGORY_NAME'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'Categorie'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
);

wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(102001000000046)
,p_db_column_name=>'PRIORITY_LABEL'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'Priorite'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
);

wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(102001000000047)
,p_db_column_name=>'STATUS_LABEL'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'Statut'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
);

wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(102001000000048)
,p_db_column_name=>'ASSIGNED_AGENT_NAME'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'Agent'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
);

wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(102001000000049)
,p_db_column_name=>'CREATED_AT'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'Cree le'
,p_column_type=>'DATE'
,p_format_mask=>'DD/MM/YYYY HH24:MI'
,p_heading_alignment=>'LEFT'
);

wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(102001000000050)
,p_db_column_name=>'DETAIL_URL'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'URL detail'
,p_column_type=>'STRING'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
,p_heading_alignment=>'LEFT'
);

wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(102001000000051)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'102001'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'TICKET_NUMBER:SUBJECT:CATEGORY_NAME:PRIORITY_LABEL:STATUS_LABEL:ASSIGNED_AGENT_NAME:CREATED_AT'
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
