-- ============================================================================
-- Service Desk Lite - Installation complete du schema Oracle
-- Compatible Oracle Database / Oracle APEX
--
-- ATTENTION : ce script reinstalle le schema fonctionnel SD_*.
-- Il supprime uniquement les objets Service Desk Lite connus ci-dessous.
-- ============================================================================

set define off
set serveroutput on
whenever sqlerror exit failure rollback

prompt [1/9] Suppression controlee des objets existants...

begin
  execute immediate 'drop view sd_ticket_overview_v';
exception
  when others then
    if sqlcode != -942 then raise; end if;
end;
/

begin
  execute immediate 'drop package sd_ticket_api';
exception
  when others then
    if sqlcode != -4043 then raise; end if;
end;
/

begin
  execute immediate 'drop table sd_ticket_comments cascade constraints purge';
exception
  when others then
    if sqlcode != -942 then raise; end if;
end;
/

begin
  execute immediate 'drop table sd_tickets cascade constraints purge';
exception
  when others then
    if sqlcode != -942 then raise; end if;
end;
/

begin
  execute immediate 'drop table sd_categories cascade constraints purge';
exception
  when others then
    if sqlcode != -942 then raise; end if;
end;
/

begin
  execute immediate 'drop table sd_agents cascade constraints purge';
exception
  when others then
    if sqlcode != -942 then raise; end if;
end;
/

begin
  for r in (
    select sequence_name
      from user_sequences
     where sequence_name in (
       'SD_AGENT_SEQ',
       'SD_CATEGORY_SEQ',
       'SD_TICKET_SEQ',
       'SD_TICKET_NUMBER_SEQ',
       'SD_COMMENT_SEQ'
     )
  ) loop
    execute immediate 'drop sequence ' || dbms_assert.simple_sql_name(r.sequence_name);
  end loop;
end;
/

prompt [2/9] Creation des sequences...

create sequence sd_agent_seq
  start with 1 increment by 1 nocycle cache 20;

create sequence sd_category_seq
  start with 1 increment by 1 nocycle cache 20;

create sequence sd_ticket_seq
  start with 1 increment by 1 nocycle cache 20;

create sequence sd_ticket_number_seq
  start with 1 increment by 1 nocycle cache 20;

create sequence sd_comment_seq
  start with 1 increment by 1 nocycle cache 20;

prompt [3/9] Creation des tables...

create table sd_agents (
  agent_id       number          not null,
  full_name      varchar2(150)   not null,
  email          varchar2(255)   not null,
  role_code      varchar2(20)    default 'AGENT' not null,
  is_active      char(1)         default 'Y' not null,
  created_at     timestamp with local time zone default systimestamp not null,
  created_by     varchar2(255)    default user not null,
  updated_at     timestamp with local time zone,
  updated_by     varchar2(255),
  constraint sd_agents_pk primary key (agent_id),
  constraint sd_agents_role_ck check (role_code in ('ADMIN', 'AGENT')),
  constraint sd_agents_active_ck check (is_active in ('Y', 'N')),
  constraint sd_agents_email_ck check (instr(email, '@') > 1)
);

create table sd_categories (
  category_id    number          not null,
  category_name  varchar2(100)   not null,
  color_code     varchar2(7)     default '#2563EB' not null,
  is_active      char(1)         default 'Y' not null,
  display_order  number          default 10 not null,
  created_at     timestamp with local time zone default systimestamp not null,
  created_by     varchar2(255)    default user not null,
  updated_at     timestamp with local time zone,
  updated_by     varchar2(255),
  constraint sd_categories_pk primary key (category_id),
  constraint sd_categories_active_ck check (is_active in ('Y', 'N')),
  constraint sd_categories_color_ck check (
    length(color_code) = 7 and substr(color_code, 1, 1) = '#'
  ),
  constraint sd_categories_order_ck check (display_order >= 0)
);

create table sd_tickets (
  ticket_id          number          not null,
  ticket_number      varchar2(30)    not null,
  subject            varchar2(200)   not null,
  description        clob            not null,
  category_id        number          not null,
  priority_code      varchar2(20)    default 'MEDIUM' not null,
  status_code        varchar2(20)    default 'NEW' not null,
  requester_name     varchar2(150)   not null,
  requester_email    varchar2(255)   not null,
  assigned_agent_id  number,
  created_at         timestamp with local time zone default systimestamp not null,
  created_by         varchar2(255)    default user not null,
  updated_at         timestamp with local time zone,
  updated_by         varchar2(255),
  resolved_at        timestamp with local time zone,
  constraint sd_tickets_pk primary key (ticket_id),
  constraint sd_tickets_number_uk unique (ticket_number),
  constraint sd_tickets_category_fk foreign key (category_id)
    references sd_categories (category_id),
  constraint sd_tickets_agent_fk foreign key (assigned_agent_id)
    references sd_agents (agent_id),
  constraint sd_tickets_priority_ck check (
    priority_code in ('LOW', 'MEDIUM', 'HIGH', 'URGENT')
  ),
  constraint sd_tickets_status_ck check (
    status_code in ('NEW', 'ASSIGNED', 'IN_PROGRESS', 'RESOLVED', 'CLOSED')
  ),
  constraint sd_tickets_email_ck check (instr(requester_email, '@') > 1),
  constraint sd_tickets_assignment_ck check (
    (status_code = 'NEW' and assigned_agent_id is null)
    or
    (status_code <> 'NEW' and assigned_agent_id is not null)
  ),
  constraint sd_tickets_resolution_ck check (
    (status_code in ('RESOLVED', 'CLOSED') and resolved_at is not null)
    or
    (status_code not in ('RESOLVED', 'CLOSED') and resolved_at is null)
  )
);

create table sd_ticket_comments (
  comment_id      number          not null,
  ticket_id       number          not null,
  comment_text    clob            not null,
  comment_type    varchar2(20)    default 'PUBLIC' not null,
  created_by      varchar2(255)   default user not null,
  created_at      timestamp with local time zone default systimestamp not null,
  constraint sd_ticket_comments_pk primary key (comment_id),
  constraint sd_comments_ticket_fk foreign key (ticket_id)
    references sd_tickets (ticket_id) on delete cascade,
  constraint sd_comments_type_ck check (comment_type in ('PUBLIC', 'INTERNAL'))
);

comment on table sd_agents is 'Agents autorises a traiter les tickets.';
comment on table sd_categories is 'Categories fonctionnelles des demandes.';
comment on table sd_tickets is 'Tickets de support du Service Desk Lite.';
comment on table sd_ticket_comments is 'Historique public et interne des tickets.';

comment on column sd_tickets.ticket_number is 'Numero lisible genere sous la forme TCK-AAAA-NNNNN.';
comment on column sd_tickets.priority_code is 'LOW, MEDIUM, HIGH ou URGENT.';
comment on column sd_tickets.status_code is 'NEW, ASSIGNED, IN_PROGRESS, RESOLVED ou CLOSED.';
comment on column sd_ticket_comments.comment_type is 'PUBLIC ou INTERNAL.';

prompt [4/9] Creation des index...

create unique index sd_agents_email_uix on sd_agents (lower(email));
create unique index sd_categories_name_uix on sd_categories (lower(category_name));
create index sd_tickets_status_ix on sd_tickets (status_code);
create index sd_tickets_priority_ix on sd_tickets (priority_code);
create index sd_tickets_category_ix on sd_tickets (category_id);
create index sd_tickets_agent_ix on sd_tickets (assigned_agent_id);
create index sd_tickets_created_ix on sd_tickets (created_at);
create index sd_comments_ticket_ix on sd_ticket_comments (ticket_id, created_at);

prompt [5/9] Creation des triggers...

create or replace trigger sd_agents_biu
before insert or update on sd_agents
for each row
begin
  if inserting then
    if :new.agent_id is null then
      :new.agent_id := sd_agent_seq.nextval;
    end if;
    :new.email      := lower(trim(:new.email));
    :new.full_name  := trim(:new.full_name);
    :new.created_at := coalesce(:new.created_at, systimestamp);
    :new.created_by := coalesce(:new.created_by, sys_context('APEX$SESSION', 'APP_USER'), user);
  else
    :new.updated_at := systimestamp;
    if :new.updated_by is null or :new.updated_by = :old.updated_by then
      :new.updated_by := coalesce(sys_context('APEX$SESSION', 'APP_USER'), user);
    end if;
    :new.email      := lower(trim(:new.email));
    :new.full_name  := trim(:new.full_name);
  end if;
end;
/

create or replace trigger sd_categories_biu
before insert or update on sd_categories
for each row
begin
  if inserting then
    if :new.category_id is null then
      :new.category_id := sd_category_seq.nextval;
    end if;
    :new.category_name := trim(:new.category_name);
    :new.color_code    := upper(trim(:new.color_code));
    :new.created_at    := coalesce(:new.created_at, systimestamp);
    :new.created_by    := coalesce(:new.created_by, sys_context('APEX$SESSION', 'APP_USER'), user);
  else
    :new.updated_at    := systimestamp;
    if :new.updated_by is null or :new.updated_by = :old.updated_by then
      :new.updated_by := coalesce(sys_context('APEX$SESSION', 'APP_USER'), user);
    end if;
    :new.category_name := trim(:new.category_name);
    :new.color_code    := upper(trim(:new.color_code));
  end if;
end;
/

create or replace trigger sd_tickets_biu
before insert or update on sd_tickets
for each row
begin
  if inserting then
    if :new.ticket_id is null then
      :new.ticket_id := sd_ticket_seq.nextval;
    end if;

    if :new.ticket_number is null then
      :new.ticket_number :=
        'TCK-' || to_char(systimestamp, 'YYYY') || '-' ||
        lpad(sd_ticket_number_seq.nextval, 5, '0');
    end if;

    :new.subject         := trim(:new.subject);
    :new.requester_name  := trim(:new.requester_name);
    :new.requester_email := lower(trim(:new.requester_email));
    :new.created_at      := coalesce(:new.created_at, systimestamp);
    :new.created_by      := coalesce(:new.created_by, sys_context('APEX$SESSION', 'APP_USER'), user);
  else
    :new.updated_at      := systimestamp;
    if :new.updated_by is null or :new.updated_by = :old.updated_by then
      :new.updated_by := coalesce(sys_context('APEX$SESSION', 'APP_USER'), user);
    end if;
    :new.subject         := trim(:new.subject);
    :new.requester_name  := trim(:new.requester_name);
    :new.requester_email := lower(trim(:new.requester_email));
  end if;
end;
/

create or replace trigger sd_comments_bi
before insert on sd_ticket_comments
for each row
begin
  if :new.comment_id is null then
    :new.comment_id := sd_comment_seq.nextval;
  end if;
  :new.created_at := coalesce(:new.created_at, systimestamp);
  :new.created_by := coalesce(:new.created_by, sys_context('APEX$SESSION', 'APP_USER'), user);
end;
/

create or replace trigger sd_comments_ai
after insert on sd_ticket_comments
for each row
begin
  update sd_tickets
     set updated_at = systimestamp,
         updated_by = :new.created_by
   where ticket_id = :new.ticket_id;
end;
/

prompt [6/9] Creation du package metier SD_TICKET_API...

create or replace package sd_ticket_api as
  function create_ticket (
    p_subject           in varchar2,
    p_description       in clob,
    p_category_id       in number,
    p_priority_code     in varchar2,
    p_requester_name    in varchar2,
    p_requester_email   in varchar2,
    p_created_by        in varchar2 default null
  ) return number;

  procedure assign_ticket (
    p_ticket_id         in number,
    p_agent_id          in number,
    p_actor             in varchar2 default null
  );

  procedure start_ticket (
    p_ticket_id         in number,
    p_actor             in varchar2 default null
  );

  procedure resolve_ticket (
    p_ticket_id         in number,
    p_resolution_note   in varchar2 default null,
    p_actor             in varchar2 default null
  );

  procedure close_ticket (
    p_ticket_id         in number,
    p_actor             in varchar2 default null
  );

  procedure add_comment (
    p_ticket_id         in number,
    p_comment_text      in clob,
    p_comment_type      in varchar2 default 'PUBLIC',
    p_actor             in varchar2 default null
  );
end sd_ticket_api;
/

create or replace package body sd_ticket_api as

  function current_actor(p_actor in varchar2) return varchar2 is
  begin
    return coalesce(
      trim(p_actor),
      sys_context('APEX$SESSION', 'APP_USER'),
      user
    );
  end current_actor;

  procedure lock_ticket (
    p_ticket_id    in number,
    p_status_code  out varchar2
  ) is
  begin
    select status_code
      into p_status_code
      from sd_tickets
     where ticket_id = p_ticket_id
       for update;
  exception
    when no_data_found then
      raise_application_error(-20001, 'Ticket introuvable.');
  end lock_ticket;

  function create_ticket (
    p_subject           in varchar2,
    p_description       in clob,
    p_category_id       in number,
    p_priority_code     in varchar2,
    p_requester_name    in varchar2,
    p_requester_email   in varchar2,
    p_created_by        in varchar2 default null
  ) return number is
    l_ticket_id      sd_tickets.ticket_id%type;
    l_category_count pls_integer;
    l_priority       sd_tickets.priority_code%type := upper(trim(p_priority_code));
    l_actor          varchar2(255) := current_actor(p_created_by);
  begin
    if trim(p_subject) is null then
      raise_application_error(-20002, 'L''objet du ticket est obligatoire.');
    end if;
    if p_description is null or dbms_lob.getlength(p_description) < 10 then
      raise_application_error(-20003, 'La description doit contenir au moins 10 caracteres.');
    end if;
    if trim(p_requester_name) is null then
      raise_application_error(-20004, 'Le nom du demandeur est obligatoire.');
    end if;
    if instr(trim(p_requester_email), '@') <= 1 then
      raise_application_error(-20005, 'L''adresse electronique du demandeur est invalide.');
    end if;
    if l_priority not in ('LOW', 'MEDIUM', 'HIGH', 'URGENT') then
      raise_application_error(-20006, 'Priorite invalide.');
    end if;

    select count(*)
      into l_category_count
      from sd_categories
     where category_id = p_category_id
       and is_active = 'Y';

    if l_category_count = 0 then
      raise_application_error(-20007, 'La categorie est inexistante ou inactive.');
    end if;

    insert into sd_tickets (
      subject,
      description,
      category_id,
      priority_code,
      status_code,
      requester_name,
      requester_email,
      created_by
    ) values (
      trim(p_subject),
      p_description,
      p_category_id,
      l_priority,
      'NEW',
      trim(p_requester_name),
      lower(trim(p_requester_email)),
      l_actor
    )
    returning ticket_id into l_ticket_id;

    return l_ticket_id;
  end create_ticket;

  procedure assign_ticket (
    p_ticket_id         in number,
    p_agent_id          in number,
    p_actor             in varchar2 default null
  ) is
    l_status       sd_tickets.status_code%type;
    l_agent_count  pls_integer;
    l_actor        varchar2(255) := current_actor(p_actor);
  begin
    lock_ticket(p_ticket_id, l_status);

    if l_status in ('RESOLVED', 'CLOSED') then
      raise_application_error(-20008, 'Un ticket resolu ou ferme ne peut plus etre affecte.');
    end if;

    select count(*)
      into l_agent_count
      from sd_agents
     where agent_id = p_agent_id
       and is_active = 'Y';

    if l_agent_count = 0 then
      raise_application_error(-20009, 'L''agent est inexistant ou inactif.');
    end if;

    update sd_tickets
       set assigned_agent_id = p_agent_id,
           status_code = case when status_code = 'NEW' then 'ASSIGNED' else status_code end,
           updated_by = l_actor
     where ticket_id = p_ticket_id;
  end assign_ticket;

  procedure start_ticket (
    p_ticket_id         in number,
    p_actor             in varchar2 default null
  ) is
    l_status sd_tickets.status_code%type;
    l_actor  varchar2(255) := current_actor(p_actor);
  begin
    lock_ticket(p_ticket_id, l_status);
    if l_status <> 'ASSIGNED' then
      raise_application_error(-20010, 'Seul un ticket affecte peut etre demarre.');
    end if;

    update sd_tickets
       set status_code = 'IN_PROGRESS',
           updated_by = l_actor
     where ticket_id = p_ticket_id;
  end start_ticket;

  procedure resolve_ticket (
    p_ticket_id         in number,
    p_resolution_note   in varchar2 default null,
    p_actor             in varchar2 default null
  ) is
    l_status sd_tickets.status_code%type;
    l_actor  varchar2(255) := current_actor(p_actor);
  begin
    lock_ticket(p_ticket_id, l_status);
    if l_status <> 'IN_PROGRESS' then
      raise_application_error(-20011, 'Seul un ticket en cours peut etre resolu.');
    end if;

    update sd_tickets
       set status_code = 'RESOLVED',
           resolved_at = systimestamp,
           updated_by = l_actor
     where ticket_id = p_ticket_id;

    if trim(p_resolution_note) is not null then
      add_comment(
        p_ticket_id    => p_ticket_id,
        p_comment_text => p_resolution_note,
        p_comment_type => 'PUBLIC',
        p_actor        => l_actor
      );
    end if;
  end resolve_ticket;

  procedure close_ticket (
    p_ticket_id         in number,
    p_actor             in varchar2 default null
  ) is
    l_status sd_tickets.status_code%type;
    l_actor  varchar2(255) := current_actor(p_actor);
  begin
    lock_ticket(p_ticket_id, l_status);
    if l_status <> 'RESOLVED' then
      raise_application_error(-20012, 'Seul un ticket resolu peut etre ferme.');
    end if;

    update sd_tickets
       set status_code = 'CLOSED',
           updated_by = l_actor
     where ticket_id = p_ticket_id;
  end close_ticket;

  procedure add_comment (
    p_ticket_id         in number,
    p_comment_text      in clob,
    p_comment_type      in varchar2 default 'PUBLIC',
    p_actor             in varchar2 default null
  ) is
    l_ticket_count pls_integer;
    l_comment_type sd_ticket_comments.comment_type%type := upper(trim(p_comment_type));
    l_actor        varchar2(255) := current_actor(p_actor);
  begin
    if p_comment_text is null or dbms_lob.getlength(p_comment_text) = 0 then
      raise_application_error(-20013, 'Le commentaire ne peut pas etre vide.');
    end if;
    if l_comment_type not in ('PUBLIC', 'INTERNAL') then
      raise_application_error(-20014, 'Type de commentaire invalide.');
    end if;

    select count(*)
      into l_ticket_count
      from sd_tickets
     where ticket_id = p_ticket_id;

    if l_ticket_count = 0 then
      raise_application_error(-20001, 'Ticket introuvable.');
    end if;

    insert into sd_ticket_comments (
      ticket_id,
      comment_text,
      comment_type,
      created_by
    ) values (
      p_ticket_id,
      p_comment_text,
      l_comment_type,
      l_actor
    );
  end add_comment;

end sd_ticket_api;
/

prompt [7/9] Creation de la vue de consultation...

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
  t.assigned_agent_id,
  a.full_name as assigned_agent_name,
  a.email as assigned_agent_email,
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

prompt [8/9] Insertion des donnees de demonstration...

insert into sd_agents (full_name, email, role_code)
values ('Aminata Ndiaye', 'aminata.ndiaye@demo.sn', 'ADMIN');

insert into sd_agents (full_name, email, role_code)
values ('Moussa Fall', 'moussa.fall@demo.sn', 'AGENT');

insert into sd_agents (full_name, email, role_code)
values ('Fatou Diop', 'fatou.diop@demo.sn', 'AGENT');

insert into sd_agents (full_name, email, role_code)
values ('Ibrahima Ba', 'ibrahima.ba@demo.sn', 'AGENT');

insert into sd_agents (full_name, email, role_code, is_active)
values ('Sokhna Gueye', 'sokhna.gueye@demo.sn', 'AGENT', 'N');

insert into sd_categories (category_name, color_code, display_order)
values ('Materiel', '#F59E0B', 10);

insert into sd_categories (category_name, color_code, display_order)
values ('Logiciel', '#2563EB', 20);

insert into sd_categories (category_name, color_code, display_order)
values ('Reseau', '#DC2626', 30);

insert into sd_categories (category_name, color_code, display_order)
values ('Acces et habilitations', '#16A34A', 40);

insert into sd_tickets (
  subject, description, category_id, priority_code, status_code,
  requester_name, requester_email, created_at
) values (
  'Ecran secondaire non detecte',
  'Le deuxieme ecran reste noir apres le demarrage du poste.',
  (select category_id from sd_categories where category_name = 'Materiel'),
  'MEDIUM', 'NEW', 'Cheikh Sarr', 'cheikh.sarr@demo.sn',
  systimestamp - interval '2' hour
);

insert into sd_tickets (
  subject, description, category_id, priority_code, status_code,
  requester_name, requester_email, assigned_agent_id, created_at
) values (
  'Installation de SQL Developer',
  'Installation requise pour le nouvel arrivant de la direction finance.',
  (select category_id from sd_categories where category_name = 'Logiciel'),
  'LOW', 'ASSIGNED', 'Marieme Sow', 'marieme.sow@demo.sn',
  (select agent_id from sd_agents where email = 'moussa.fall@demo.sn'),
  systimestamp - interval '1' day
);

insert into sd_tickets (
  subject, description, category_id, priority_code, status_code,
  requester_name, requester_email, assigned_agent_id, created_at
) values (
  'Coupures Wi-Fi dans la salle de reunion',
  'La connexion Wi-Fi se coupe toutes les cinq minutes pendant les reunions.',
  (select category_id from sd_categories where category_name = 'Reseau'),
  'HIGH', 'IN_PROGRESS', 'Astou Kane', 'astou.kane@demo.sn',
  (select agent_id from sd_agents where email = 'fatou.diop@demo.sn'),
  systimestamp - interval '3' day
);

insert into sd_tickets (
  subject, description, category_id, priority_code, status_code,
  requester_name, requester_email, created_at
) values (
  'Compte messagerie bloque',
  'Le compte est bloque apres plusieurs tentatives de connexion infructueuses.',
  (select category_id from sd_categories where category_name = 'Acces et habilitations'),
  'URGENT', 'NEW', 'Ousmane Diallo', 'ousmane.diallo@demo.sn',
  systimestamp - interval '45' minute
);

insert into sd_tickets (
  subject, description, category_id, priority_code, status_code,
  requester_name, requester_email, assigned_agent_id, created_at
) values (
  'Imprimante du deuxieme etage indisponible',
  'L imprimante affiche un message indiquant que le bac papier est bloque.',
  (select category_id from sd_categories where category_name = 'Materiel'),
  'HIGH', 'ASSIGNED', 'Awa Thiam', 'awa.thiam@demo.sn',
  (select agent_id from sd_agents where email = 'ibrahima.ba@demo.sn'),
  systimestamp - interval '5' hour
);

insert into sd_tickets (
  subject, description, category_id, priority_code, status_code,
  requester_name, requester_email, assigned_agent_id, created_at, resolved_at
) values (
  'Erreur au lancement du logiciel comptable',
  'Le logiciel comptable affichait une erreur de connexion a la base de donnees.',
  (select category_id from sd_categories where category_name = 'Logiciel'),
  'HIGH', 'RESOLVED', 'Babacar Niang', 'babacar.niang@demo.sn',
  (select agent_id from sd_agents where email = 'moussa.fall@demo.sn'),
  systimestamp - interval '4' day, systimestamp - interval '6' hour
);

insert into sd_tickets (
  subject, description, category_id, priority_code, status_code,
  requester_name, requester_email, assigned_agent_id, created_at, resolved_at
) values (
  'Creation acces dossier partage',
  'Un acces en lecture au dossier partage des ressources humaines etait requis.',
  (select category_id from sd_categories where category_name = 'Acces et habilitations'),
  'MEDIUM', 'CLOSED', 'Khady Mbaye', 'khady.mbaye@demo.sn',
  (select agent_id from sd_agents where email = 'fatou.diop@demo.sn'),
  systimestamp - interval '8' day, systimestamp - interval '6' day
);

insert into sd_tickets (
  subject, description, category_id, priority_code, status_code,
  requester_name, requester_email, created_at
) values (
  'Clavier avec plusieurs touches bloquees',
  'Les touches A, Q et la barre espace ne repondent plus correctement.',
  (select category_id from sd_categories where category_name = 'Materiel'),
  'MEDIUM', 'NEW', 'Mamadou Lo', 'mamadou.lo@demo.sn',
  systimestamp - interval '7' hour
);

insert into sd_tickets (
  subject, description, category_id, priority_code, status_code,
  requester_name, requester_email, assigned_agent_id, created_at
) values (
  'VPN inaccessible depuis le domicile',
  'Le client VPN refuse la connexion avec le message serveur indisponible.',
  (select category_id from sd_categories where category_name = 'Reseau'),
  'URGENT', 'IN_PROGRESS', 'Ndeye Faye', 'ndeye.faye@demo.sn',
  (select agent_id from sd_agents where email = 'ibrahima.ba@demo.sn'),
  systimestamp - interval '12' hour
);

insert into sd_tickets (
  subject, description, category_id, priority_code, status_code,
  requester_name, requester_email, assigned_agent_id, created_at
) values (
  'Mise a jour du navigateur',
  'Une version recente du navigateur est requise pour acceder au nouveau portail.',
  (select category_id from sd_categories where category_name = 'Logiciel'),
  'LOW', 'ASSIGNED', 'Alioune Cisse', 'alioune.cisse@demo.sn',
  (select agent_id from sd_agents where email = 'moussa.fall@demo.sn'),
  systimestamp - interval '2' day
);

insert into sd_tickets (
  subject, description, category_id, priority_code, status_code,
  requester_name, requester_email, created_at
) values (
  'Demande acces application RH',
  'Le responsable de service demande un acces de consultation a l application RH.',
  (select category_id from sd_categories where category_name = 'Acces et habilitations'),
  'MEDIUM', 'NEW', 'Adama Sy', 'adama.sy@demo.sn',
  systimestamp - interval '1' day
);

insert into sd_tickets (
  subject, description, category_id, priority_code, status_code,
  requester_name, requester_email, assigned_agent_id, created_at, resolved_at
) values (
  'Telephone IP sans tonalite',
  'Le telephone IP ne permettait plus de passer ou recevoir des appels.',
  (select category_id from sd_categories where category_name = 'Reseau'),
  'HIGH', 'RESOLVED', 'Rokhaya Seck', 'rokhaya.seck@demo.sn',
  (select agent_id from sd_agents where email = 'fatou.diop@demo.sn'),
  systimestamp - interval '5' day, systimestamp - interval '1' day
);

insert into sd_ticket_comments (ticket_id, comment_text, comment_type, created_by, created_at)
select ticket_id,
       'Prise en charge du diagnostic reseau. Des tests sont en cours.',
       'PUBLIC',
       'fatou.diop@demo.sn',
       systimestamp - interval '2' day
  from sd_tickets
 where subject = 'Coupures Wi-Fi dans la salle de reunion';

insert into sd_ticket_comments (ticket_id, comment_text, comment_type, created_by, created_at)
select ticket_id,
       'Verifier le point d acces et les interferences sur le canal utilise.',
       'INTERNAL',
       'fatou.diop@demo.sn',
       systimestamp - interval '1' day
  from sd_tickets
 where subject = 'Coupures Wi-Fi dans la salle de reunion';

insert into sd_ticket_comments (ticket_id, comment_text, comment_type, created_by, created_at)
select ticket_id,
       'Le service de base de donnees a ete redemarre. Le logiciel fonctionne maintenant.',
       'PUBLIC',
       'moussa.fall@demo.sn',
       systimestamp - interval '6' hour
  from sd_tickets
 where subject = 'Erreur au lancement du logiciel comptable';

insert into sd_ticket_comments (ticket_id, comment_text, comment_type, created_by, created_at)
select ticket_id,
       'Le profil VPN a ete regenere. Nous attendons la confirmation de l utilisateur.',
       'PUBLIC',
       'ibrahima.ba@demo.sn',
       systimestamp - interval '2' hour
  from sd_tickets
 where subject = 'VPN inaccessible depuis le domicile';

prompt [9/9] Verification de l installation...

declare
  l_agents      pls_integer;
  l_categories  pls_integer;
  l_tickets     pls_integer;
  l_comments    pls_integer;
  l_invalid     pls_integer;
begin
  select count(*) into l_agents from sd_agents;
  select count(*) into l_categories from sd_categories;
  select count(*) into l_tickets from sd_tickets;
  select count(*) into l_comments from sd_ticket_comments;
  select count(*)
    into l_invalid
    from user_objects
   where object_name in (
     'SD_TICKET_API',
     'SD_AGENTS_BIU',
     'SD_CATEGORIES_BIU',
     'SD_TICKETS_BIU',
     'SD_COMMENTS_BI',
     'SD_COMMENTS_AI',
     'SD_TICKET_OVERVIEW_V'
   )
     and status <> 'VALID';

  dbms_output.put_line('Agents      : ' || l_agents);
  dbms_output.put_line('Categories  : ' || l_categories);
  dbms_output.put_line('Tickets     : ' || l_tickets);
  dbms_output.put_line('Commentaires: ' || l_comments);
  dbms_output.put_line('Objets invalides: ' || l_invalid);

  if l_agents <> 5 or l_categories <> 4 or l_tickets <> 12 or l_comments <> 4 then
    raise_application_error(-20050, 'Le jeu de demonstration est incomplet.');
  end if;

  if l_invalid <> 0 then
    for r in (
      select name, type, line, position, text
        from user_errors
       where name like 'SD_%'
       order by name, sequence
    ) loop
      dbms_output.put_line(
        r.name || ' [' || r.type || '] ligne ' || r.line || ':' ||
        r.position || ' - ' || r.text
      );
    end loop;
    raise_application_error(-20051, 'Un ou plusieurs objets SD_* sont invalides.');
  end if;
end;
/

commit;

prompt Installation Service Desk Lite terminee avec succes.
