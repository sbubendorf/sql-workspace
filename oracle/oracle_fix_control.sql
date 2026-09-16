-- Show all fixes --------------------------------------------------------------
select  * 
from    v$system_fix_control   fc
order   by  fc.bugno
;



-- Show and alter fix control for current session only -------------------------
select  *
from    v$session_fix_control   fc
where   1=1
    and fc.session_id = (select distinct sid from v$mystat)
    and bugno = 28173995
;
    
alter session set "_fix_control"='28173995:ON';

-- Show and alter fix control system wide --------------------------------------
select  * 
from    v$system_fix_control   fc
where   1=1
    and bugno = 28173995
;
    
alter system set "_fix_control"='28173995:ON';    






select name, sql_text, created, last_modified, status from dba_sql_patches;

select name, sql_text, created, last_modified, status from dba_sql_profiles;

