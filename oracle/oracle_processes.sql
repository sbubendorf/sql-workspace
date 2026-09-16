-- Show active oracle processes ------------------------------------------------
select  pr.pid,
        pr.spid,
        pr.pname,
        pr.username,
        se.osuser,
        se.status,
        se.machine,
        se.program,
        sa.*
from    v$process                   pr
        inner join  v$session       se  on  se.paddr = pr.addr
        left  join  v$transaction   tr  on  tr.addr = se.taddr
        left  join  v$sqlarea       sa  on  sa.address = se.sql_address
        
;


select  *
from    gv$transaction
;


