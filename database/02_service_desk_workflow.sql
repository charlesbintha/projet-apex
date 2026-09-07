-- ============================================================================
-- Service Desk Lite - Extension APEX Workflow / Human Tasks
-- A executer apres 01_service_desk_lite_schema.sql
-- ============================================================================

set define off
set serveroutput on
whenever sqlerror exit failure rollback

prompt [1/5] Extension des identites et du suivi workflow...

declare
  procedure add_column_if_missing(
    p_table_name  in varchar2,
    p_column_name in varchar2,
    p_ddl         in varchar2
  ) is
    l_count pls_integer;
  begin
    select count(*)
      into l_count
      from user_tab_columns
     where table_name = upper(p_table_name)
       and column_name = upper(p_column_name);

    if l_count = 0 then
      execute immediate p_ddl;
    end if;
  end add_column_if_missing;
begin
  add_column_if_missing(
    'SD_AGENTS',
    'APEX_USERNAME',
    'alter table sd_agents add apex_username varchar2(255)'
  );
  add_column_if_missing(
    'SD_TICKETS',
    'REQUESTER_USERNAME',
    'alter table sd_tickets add requester_username varchar2(255)'
  );
  add_column_if_missing(
    'SD_TICKETS',
    'WORKFLOW_ID',
    'alter table sd_tickets add workflow_id number'
  );
end;
/

update sd_agents
   set apex_username = upper(email)
 where apex_username is null;

update sd_tickets
   set requester_username = upper(requester_email)
 where requester_username is null;

declare
  l_count pls_integer;
begin
  select count(*)
    into l_count
    from user_indexes
   where index_name = 'SD_AGENTS_APEX_USERNAME_UK';

  if l_count = 0 then
    execute immediate
      'create unique index sd_agents_apex_username_uk on sd_agents (apex_username)';
  end if;
end;
/

prompt [2/5] Synchronisation automatique des identites APEX...

create or replace trigger sd_ticket_workflow_identity_biu
before insert or update of requester_email, requester_username on sd_tickets
for each row
begin
  if :new.requester_username is null then
    :new.requester_username := coalesce(
      nullif(upper(apex_application.g_user), 'NOBODY'),
      upper(:new.requester_email)
    );
  else
    :new.requester_username := upper(trim(:new.requester_username));
  end if;
end;
/

prompt [3/5] Creation du package de liaison workflow...

create or replace package sd_workflow_api as
  function admin_usernames return varchar2;

  function ticket_agent_username(
    p_ticket_id in number
  ) return varchar2;

  function ticket_requester_username(
    p_ticket_id in number
  ) return varchar2;

  procedure record_workflow(
    p_ticket_id   in number,
    p_workflow_id in number
  );

  procedure assign_from_task(
    p_ticket_id in number,
    p_task_id   in number
  );

  procedure start_processing(
    p_ticket_id in number
  );

  procedure resolve_from_task(
    p_ticket_id in number,
    p_task_id   in number
  );

  procedure reopen_after_rejection(
    p_ticket_id in number
  );

  procedure close_after_approval(
    p_ticket_id in number
  );
end sd_workflow_api;
/

create or replace package body sd_workflow_api as
  function actor return varchar2 is
  begin
    return coalesce(
      nullif(trim(apex_application.g_user), ''),
      sys_context('USERENV', 'SESSION_USER'),
      'WORKFLOW'
    );
  end actor;

  function task_parameter(
    p_task_id         in number,
    p_param_static_id in varchar2,
    p_required        in boolean default true
  ) return varchar2 is
    l_value apex_task_parameters.param_value%type;
  begin
    select param_value
      into l_value
      from apex_task_parameters
     where task_id = p_task_id
       and param_static_id = upper(p_param_static_id);

    if p_required and trim(l_value) is null then
      raise_application_error(
        -20101,
        'Le parametre de tache ' || upper(p_param_static_id) || ' est obligatoire.'
      );
    end if;

    return l_value;
  exception
    when no_data_found then
      if p_required then
        raise_application_error(
          -20102,
          'Parametre de tache introuvable : ' || upper(p_param_static_id) || '.'
        );
      end if;
      return null;
  end task_parameter;

  function admin_usernames return varchar2 is
    l_usernames varchar2(4000);
    l_current   varchar2(255) := nullif(upper(apex_application.g_user), 'NOBODY');
  begin
    select listagg(apex_username, ',') within group (order by full_name)
      into l_usernames
      from sd_agents
     where role_code = 'ADMIN'
       and is_active = 'Y'
       and apex_username is not null;

    if l_current is not null
       and instr(',' || l_usernames || ',', ',' || l_current || ',') = 0 then
      l_usernames := l_usernames || case when l_usernames is not null then ',' end || l_current;
    end if;

    return coalesce(l_usernames, l_current);
  end admin_usernames;

  function ticket_agent_username(
    p_ticket_id in number
  ) return varchar2 is
    l_username sd_agents.apex_username%type;
  begin
    select a.apex_username
      into l_username
      from sd_tickets t
      join sd_agents a
        on a.agent_id = t.assigned_agent_id
     where t.ticket_id = p_ticket_id
       and a.is_active = 'Y';

    if l_username is null then
      raise_application_error(-20103, 'Aucun utilisateur APEX n''est associe a l''agent.');
    end if;

    return l_username;
  exception
    when no_data_found then
      raise_application_error(-20104, 'Le ticket ne possede aucun agent actif.');
  end ticket_agent_username;

  function ticket_requester_username(
    p_ticket_id in number
  ) return varchar2 is
    l_username sd_tickets.requester_username%type;
  begin
    select requester_username
      into l_username
      from sd_tickets
     where ticket_id = p_ticket_id;

    if l_username is null then
      raise_application_error(-20105, 'Le demandeur ne possede aucun utilisateur APEX.');
    end if;

    return l_username;
  exception
    when no_data_found then
      raise_application_error(-20001, 'Ticket introuvable.');
  end ticket_requester_username;

  procedure record_workflow(
    p_ticket_id   in number,
    p_workflow_id in number
  ) is
    l_actor varchar2(255) := actor;
  begin
    update sd_tickets
       set workflow_id = p_workflow_id,
           updated_by = l_actor
     where ticket_id = p_ticket_id;

    if sql%rowcount = 0 then
      raise_application_error(-20001, 'Ticket introuvable.');
    end if;
  end record_workflow;

  procedure assign_from_task(
    p_ticket_id in number,
    p_task_id   in number
  ) is
    l_agent_id number;
  begin
    l_agent_id := to_number(task_parameter(p_task_id, 'P_AGENT_ID'));

    sd_ticket_api.assign_ticket(
      p_ticket_id => p_ticket_id,
      p_agent_id  => l_agent_id,
      p_actor     => actor
    );
  exception
    when value_error then
      raise_application_error(-20106, 'L''agent selectionne est invalide.');
  end assign_from_task;

  procedure start_processing(
    p_ticket_id in number
  ) is
  begin
    sd_ticket_api.start_ticket(
      p_ticket_id => p_ticket_id,
      p_actor     => actor
    );
  end start_processing;

  procedure resolve_from_task(
    p_ticket_id in number,
    p_task_id   in number
  ) is
    l_resolution_note varchar2(4000);
  begin
    l_resolution_note := task_parameter(
      p_task_id         => p_task_id,
      p_param_static_id => 'P_RESOLUTION_NOTE',
      p_required        => true
    );

    sd_ticket_api.resolve_ticket(
      p_ticket_id       => p_ticket_id,
      p_resolution_note => l_resolution_note,
      p_actor           => actor
    );
  end resolve_from_task;

  procedure reopen_after_rejection(
    p_ticket_id in number
  ) is
    l_actor varchar2(255) := actor;
  begin
    update sd_tickets
       set status_code = 'IN_PROGRESS',
           resolved_at = null,
           updated_by = l_actor
     where ticket_id = p_ticket_id
       and status_code = 'RESOLVED';

    if sql%rowcount = 0 then
      raise_application_error(-20107, 'Seul un ticket resolu peut retourner en traitement.');
    end if;

    sd_ticket_api.add_comment(
      p_ticket_id    => p_ticket_id,
      p_comment_text => 'La resolution a ete refusee. Le ticket retourne en traitement.',
      p_comment_type => 'PUBLIC',
      p_actor        => l_actor
    );
  end reopen_after_rejection;

  procedure close_after_approval(
    p_ticket_id in number
  ) is
  begin
    sd_ticket_api.close_ticket(
      p_ticket_id => p_ticket_id,
      p_actor     => actor
    );
  end close_after_approval;
end sd_workflow_api;
/

prompt [4/5] Extension de la vue de consultation...

create or replace view sd_ticket_overview_v as
select
  t.ticket_id,
  t.ticket_number,
  t.subject,
  t.description,
  t.category_id,
  c.category_name,
  c.color_code as category_color,
  t.priority_code,
  case t.priority_code
    when 'LOW' then 'Faible'
    when 'MEDIUM' then 'Moyenne'
    when 'HIGH' then 'Haute'
    when 'URGENT' then 'Urgente'
  end as priority_label,
  'sd-priority-' || lower(t.priority_code) as priority_css_class,
  t.status_code,
  case t.status_code
    when 'NEW' then 'Nouveau'
    when 'ASSIGNED' then 'Affecte'
    when 'IN_PROGRESS' then 'En cours'
    when 'RESOLVED' then 'Resolu'
    when 'CLOSED' then 'Ferme'
  end as status_label,
  'sd-status-' || lower(replace(t.status_code, '_', '-')) as status_css_class,
  t.requester_name,
  t.requester_email,
  t.requester_username,
  t.assigned_agent_id,
  a.full_name as assigned_agent_name,
  a.email as assigned_agent_email,
  a.apex_username as assigned_agent_username,
  t.workflow_id,
  t.created_at,
  t.created_by,
  t.updated_at,
  t.updated_by,
  t.resolved_at,
  trunc(sysdate - cast(t.created_at as date)) as age_days,
  (
    select count(*)
      from sd_ticket_comments cm
     where cm.ticket_id = t.ticket_id
  ) as comment_count
from sd_tickets t
join sd_categories c
  on c.category_id = t.category_id
left join sd_agents a
  on a.agent_id = t.assigned_agent_id;

prompt [5/5] Verification des objets...

declare
  l_invalid_count pls_integer;
begin
  select count(*)
    into l_invalid_count
    from user_objects
   where object_name in (
     'SD_TICKET_WORKFLOW_IDENTITY_BIU',
     'SD_WORKFLOW_API',
     'SD_TICKET_OVERVIEW_V'
   )
     and status <> 'VALID';

  if l_invalid_count > 0 then
    raise_application_error(-20150, 'Un ou plusieurs objets du workflow sont invalides.');
  end if;
end;
/

commit;
prompt Extension workflow Service Desk Lite installee.
