-- Show all BSI users ----------------------------------------------------------
select  u.username,
        c.display_name,
        u.user_id,
        u.account_status,
        u.lock_date,
        u.expiry_date,
        to_char(u.last_login,'yyyy.mm.dd hh24.mi.ss') as last_login,
        u.default_tablespace,
        u.temporary_tablespace,
        u.local_temp_tablespace,
        trunc(u.created)                as  created,
        u.profile,
        u.initial_rsrc_consumer_group,
        u.password_versions,
        u.editions_enabled,
        u.authentication_type,
        u.proxy_only_connect,
        u.common,
        u.oracle_maintained,
        u.inherited,
        u.default_collation,
        u.implicit,
        u.all_shard,
        u.password_change_date
from    sys.dba_users                   u
        left  join  bsi.bsi_user        b   on  b.username = lower(u.username)
        left  join  bsi.bsi_customer    c   on  c.customer_nr = b.user_nr
where   1=1
  --and u.username like 'BSI%'
  --and u.last_login is not null
    and u.account_status = 'OPEN'
order   by  u.username  
;


select  p.profile                   as  profile_name,
        p.resource_name             as  resoure,
        p.limit                     as  limit_current,
        d.limit                     as  limit_default
from    dba_profiles                p
        left  join  dba_profiles    d   on  d.resource_name = p.resource_name
                                        and d.profile = 'DEFAULT'
where   1=1
    and p.profile = 'BAL_SERVICE_PROFILE'
;

select  *
from    dba_profiles        p
where   1=1
    and p.profile = 'DEFAULT'
;




-- Show all non Oracle managed users -------------------------------------------
select  ousr.user_id,
        ousr.username,
        ousr.account_status,
        ousr.lock_date,
        ousr.expiry_date,
        ousr.created,
        ousr.last_login
from    dba_users       ousr
where   ousr.oracle_maintained = 'N'
order   by  ousr.user_id;



-- Show oracle users with names from Comet users -------------------------------
select
        (select name from v$database)   as  database_name,
        ousr.username,
        ousr.user_id,
        cusr.user_nr                    as  comet_user_nr,
        cust.display_name               as  comet_user_name,
        ousr.account_status,
        ousr.lock_date,
        ousr.expiry_date,
        ousr.created,
        ousr.last_login
from    
        dba_users                       ousr
        left  join  bsi.bsi_user        cusr    on  cusr.username = lower(ousr.username)
        left  join  bsi.bsi_customer    cust    on  cust.customer_nr = cusr.user_nr    
where   
        ousr.oracle_maintained = 'N'
    and ousr.username like 'B______'
    and length(trim(translate(substr(ousr.username,2,5), ' +-.0123456789', ' '))) is null
order   by  
        ousr.username;
        

        





