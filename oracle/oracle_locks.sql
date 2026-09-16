/*
    Check out this link for help on blocked sessions:
        https://support.dbagenesis.com/oracle-database/lock-conflict-in-oracle#google_vignette
*/


select  a.SID       "Blocking Session", 
        b.SID       "Blocked Session"  
from    v$lock              a 
        inner join  v$lock  b   on  a.SID != b.SID 
                                and a.ID1 = b.ID1  
                                and a.ID2 = b.ID2 
where   b.request > 0 
    and a.block = 1
;


select  lo.session_id,
        se.machine,
        se.event,
        se.sql_exec_start,
        lo.oracle_username,
        lo.os_user_name,
        lo.process,
        do.object_name,
        do.owner,
        decode(
            lo.locked_mode,
            0, 'None',
            1, 'Null',
            2, 'Row Share (SS)',
            3, 'Row Excl (SX)',
            4, 'Share',
            5, 'Share Row Excl (SSX)',
            6, 'Exclusive',
            to_char(lo.locked_mode)
        ) mode_held
from    gv$locked_object            lo 
        inner join  dba_objects     do  on  do.object_id = lo.object_id
        inner join  gv$session      se  on  se.sid = lo.session_id
where   1=1
    and do.object_name = 'BSI_CUSTOMER'
order   by 1
;



select  nvl(s.username,'Internal')                                              username, 
        nvl(s.terminal,'None')                                                  terminal, 
        'alter system kill session ''' || l.sid || ',' || s.serial# || ''';'    kill_command, 
        u.name || '.' || substr(t.name,1,20)                                    table_name, 
        decode(l.lmode,
            1, 'No Lock', 
            2, 'Row Share', 
            3, 'Row Exclusive', 
            4, 'Share', 
            5, 'Share Row Exclusive', 
            6, 'Exclusive',
            null)                                                               lock_mode, 
       decode(l.request,
            1 , 'No Lock', 
            2 , 'Row Share', 
            3 , 'Row Exclusive', 
            4 , 'Share', 
            5 , 'Share Row Exclusive', 
            6 , 'Exclusive',
            null)                                                               request 
from    v$lock                  l  
        inner join  v$session   s   on  s.sid = l.sid 
        inner join  sys.obj$    t   on  t.obj# = decode(l.id2,0,l.id1,l.id2)
        inner join  sys.user$   u   on  u.user# = t.owner#  
where   s.type != 'BACKGROUND'
    and u.name not in ('SYS') 
order by 1,2,5 
;

select * from sys.OBJ$;



select  sessions_current "Users logged on"
from    v$license;

select  count(*) "Users running"
from    v$session_wait
where   wait_time != 0
;
 
select  substr(w.sid,1,5) "Sid",
        substr(s.username,1,15) "User",
        substr(s.event,1,40) "Event",
        s.seconds_in_wait "Wait [s]"
from    v$session_wait          w 
        inner join  v$session   s   on  s.sid = w.sid
where   s.state = 'WAITING'
    and s.event not like 'SQL*Net%'
    and s.event != 'client message'
    and s.event not like '%mon timer'
    and s.event != 'rdbms ipc message'
    and s.event != 'Null Event'
;    
    
select  count(*) "Users waiting for locks"
from    v$session
where   lockwait is not null;




