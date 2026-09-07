set serveroutput on
set pagesize 200
set linesize 220

column metric format a16
column actual_value format a20
column expected_value format a20
column result format a8

prompt Etat synthetique de l installation

select metric,
       actual_value,
       expected_value,
       case when actual_value = expected_value then 'OK' else 'ECHEC' end as result
  from (
    select 1 as sort_order,
           'Utilisateur' as metric,
           user as actual_value,
           'TESTCL' as expected_value
      from dual
    union all
    select 2,
           'Tables',
           to_char(count(*)),
           '4'
      from user_tables
     where table_name in (
       'SD_AGENTS', 'SD_CATEGORIES', 'SD_TICKETS', 'SD_TICKET_COMMENTS'
     )
    union all
    select 3,
           'Sequences',
           to_char(count(*)),
           '5'
      from user_sequences
     where sequence_name in (
       'SD_AGENT_SEQ', 'SD_CATEGORY_SEQ', 'SD_TICKET_SEQ',
       'SD_TICKET_NUMBER_SEQ', 'SD_COMMENT_SEQ'
     )
    union all
    select 4,
           'Packages',
           to_char(count(*)),
           '2'
      from user_objects
     where object_type = 'PACKAGE'
       and object_name in ('SD_TICKET_API', 'SD_WORKFLOW_API')
    union all
    select 5,
           'Vues',
           to_char(count(*)),
           '1'
      from user_views
     where view_name = 'SD_TICKET_OVERVIEW_V'
    union all
    select 6,
           'Invalides',
           to_char(count(*)),
           '0'
      from user_objects
     where object_name like 'SD\_%' escape '\'
       and status <> 'VALID'
  )
 order by sort_order;

prompt Objets SD invalides

select object_type,
       object_name,
       status
  from user_objects
 where object_name like 'SD\_%' escape '\'
   and status <> 'VALID'
 order by object_type, object_name;

prompt Erreurs de compilation SD

select name,
       type,
       line,
       position,
       text
  from user_errors
 where name like 'SD\_%' escape '\'
 order by name, sequence;

declare
  l_tables       pls_integer;
  l_sequences    pls_integer;
  l_packages     pls_integer;
  l_views        pls_integer;
  l_invalid      pls_integer;
begin
  select count(*)
    into l_tables
    from user_tables
   where table_name in (
     'SD_AGENTS',
     'SD_CATEGORIES',
     'SD_TICKETS',
     'SD_TICKET_COMMENTS'
   );

  select count(*)
    into l_sequences
    from user_sequences
   where sequence_name in (
     'SD_AGENT_SEQ',
     'SD_CATEGORY_SEQ',
     'SD_TICKET_SEQ',
     'SD_TICKET_NUMBER_SEQ',
     'SD_COMMENT_SEQ'
   );

  select count(*)
    into l_packages
    from user_objects
   where object_type = 'PACKAGE'
     and object_name in ('SD_TICKET_API', 'SD_WORKFLOW_API');

  select count(*)
    into l_views
    from user_views
   where view_name = 'SD_TICKET_OVERVIEW_V';

  select count(*)
    into l_invalid
    from user_objects
   where object_name like 'SD\_%' escape '\'
     and status <> 'VALID';

  dbms_output.put_line('Utilisateur : ' || user);
  dbms_output.put_line('Tables      : ' || l_tables || '/4');
  dbms_output.put_line('Sequences   : ' || l_sequences || '/5');
  dbms_output.put_line('Packages    : ' || l_packages || '/2');
  dbms_output.put_line('Vues        : ' || l_views || '/1');
  dbms_output.put_line('Invalides   : ' || l_invalid);

  if user <> 'TESTCL'
     or l_tables <> 4
     or l_sequences <> 5
     or l_packages <> 2
     or l_views <> 1
     or l_invalid <> 0
  then
    raise_application_error(
      -20003,
      'Verification TESTCL en echec: user=' || user ||
      ', tables=' || l_tables || '/4' ||
      ', sequences=' || l_sequences || '/5' ||
      ', packages=' || l_packages || '/2' ||
      ', vues=' || l_views || '/1' ||
      ', invalides=' || l_invalid || '/0.'
    );
  end if;
end;
/

select object_type,
       object_name,
       status
  from user_objects
 where object_name like 'SD\_%' escape '\'
 order by object_type, object_name;
