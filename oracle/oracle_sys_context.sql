select 'Current Schema'     as name, sys_context('USERENV', 'CURRENT_SCHEMA'    ) as value from dual union all
select 'Current Schema ID'  as name, sys_context('USERENV', 'CURRENT_SCHEMAID'  ) as value from dual union all
select 'DB Domain'          as name, sys_context('USERENV', 'DB_DOMAIN'         ) as value from dual union all
select 'DB Name'            as name, sys_context('USERENV', 'DB_NAME'           ) as value from dual union all
select 'DB Unique Name'     as name, sys_context('USERENV', 'DB_UNIQUE_NAME'    ) as value from dual union all
select 'Host'               as name, sys_context('USERENV', 'HOST'              ) as value from dual union all
select 'Client IP'          as name, sys_context('USERENV', 'IP_ADDRESS'        ) as value from dual union all
select 'Is DBA'             as name, sys_context('USERENV', 'ISDBA'             ) as value from dual union all
select 'OS User'            as name, sys_context('USERENV', 'OS_USER'           ) as value from dual union all
select 'Session User'       as name, sys_context('USERENV', 'SESSION_USER'      ) as value from dual union all
select 'Session User ID'    as name, sys_context('USERENV', 'SESSION_USERID'    ) as value from dual union all
select 'Session ID'         as name, sys_context('USERENV', 'SESSIONID'         ) as value from dual union all
select 'Session Number'     as name, sys_context('USERENV', 'SID'               ) as value from dual union all
select 'Terminal'           as name, sys_context('USERENV', 'TERMINAL'          ) as value from dual


