
select  *
from    sys.user$
where   name = 'HMIDB_READ_ONLY'

select  *  
from    dba_profiles 
where   resource_name like 'PASSWORD_REUSE%'


alter   profile DEFAULT_USER limit PASSWORD_REUSE_TIME UNLIMITED

alter   profile DEFAULT_USER limit PASSWORD_REUSE_MAX UNLIMITED

alter   profile DEFAULT limit PASSWORD_REUSE_TIME UNLIMITED

alter   profile DEFAULT limit PASSWORD_REUSE_MAX UNLIMITED

alter user hmidb_read_only identified by HMIDB_READ_ONLY

alter   profile DEFAULT_USER limit PASSWORD_REUSE_TIME 90

alter   profile DEFAULT_USER limit PASSWORD_REUSE_MAX 4

alter   profile DEFAULT limit PASSWORD_REUSE_TIME 90

alter   profile DEFAULT limit PASSWORD_REUSE_MAX 4

commit;