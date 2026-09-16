-- =============================================================================
--  Oracle Session Handling
-- =============================================================================

-- Show all sessions from BSI CRM ----------------------------------------------
select  *
from    v$session   s
where   s.user# = 142       -- BSIUSER
order   by  logon_time
;

-- Sessions per BSI CRM server -------------------------------------------------
select  s.machine,
        count(*)        as  total_sessions,
        sum(case when s.status = 'ACTIVE' then 1 else 0 end) as active_sessions
from    v$session   s
where   s.user# = 142       -- BSIUSER
group   by  s.machine
order   by  s.machine
;


-- -----------------------------------------------------------------------------
--  total cursors open, by session
select  s.sid,
        s.serial#, 
        s.username,
        s.osuser, 
        s.machine,
        s.terminal,
        s.program,
        a.value as cursors
from    v$session                   s
        inner join  v$sesstat       a   on  a.sid = s.sid 
        inner join  v$statname      b   on  b.statistic# = a.statistic# 
where   b.name = 'opened cursors current'
    and s.user# = 142       -- BSIUSER
order   by  sid
;

-- -----------------------------------------------------------------------------
--  Oracle Parameters
select  *
from    v$parameter
order   by  name
;

-- -----------------------------------------------------------------------------
--  Oracle Session History
select  u.name,
        s.*
from    sys.wrh$_active_session_history s
        inner join  sys.user$ u on u.user# = s.user_id
where   sample_time > trunc(sysdate)-1
order   by  sample_time   
;


SELECT nvl(ses.username,'ORACLE PROC')||' ('||ses.sid||')' USERNAME,
       SID,   
       MACHINE, 
       REPLACE(SQL.SQL_TEXT,CHR(10),'') STMT, 
      ltrim(to_char(floor(SES.LAST_CALL_ET/3600), '09')) || ':'
       || ltrim(to_char(floor(mod(SES.LAST_CALL_ET, 3600)/60), '09')) || ':'
       || ltrim(to_char(mod(SES.LAST_CALL_ET, 60), '09'))    RUNT 
  FROM V$SESSION SES,   
       V$SQLtext_with_newlines SQL 
 where SES.STATUS = 'ACTIVE'
   and SES.USERNAME is not null
   and SES.SQL_ADDRESS    = SQL.ADDRESS 
   and SES.SQL_HASH_VALUE = SQL.HASH_VALUE 
   and Ses.AUDSID <> userenv('SESSIONID') 
 order by runt desc, 1,sql.piece;


-- Show active sessions with sql statement being executed ----------------------
select  sess.sid,
        sess.serial#,
        sess.username,
        sess.sql_id,
        sess.sql_child_number,
        replace(sess.machine,'.linux.balgroupit.com','') as machine,
        sess.status,
        sess.last_call_et,
        case when sess.status='ACTIVE' then ltrim(to_char(floor(sess.last_call_et/3600), '09')) || ':' || ltrim(to_char(floor(mod(sess.last_call_et, 3600)/60), '09')) || ':' || ltrim(to_char(mod(sess.last_call_et, 60), '09')) else null end as runtime, 
        optimizer_mode,
        hash_value,
        address,
        sql_text
from    v$sqlarea       sqla
        inner join  v$session   sess    on  sess.sql_hash_value = sqla.hash_value and sess.sql_address = sqla.address
where   sess.username       is not null
    and sess.status = 'ACTIVE'

