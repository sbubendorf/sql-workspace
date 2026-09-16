-- Show current version of database --------------------------------------------
select  *
from    v$version
;

-- Show patches installed on database ------------------------------------------
select  p.install_id,
        p.patch_id,
        p.patch_type,
        p.status,
        p.action,
        p.action_time,
        p.description,
        p.source_version,
        p.target_version
from    dba_registry_sqlpatch   p 
order   by  action_time desc
;

select * from NLS_DATABASE_PARAMETERS where parameter='NLS_CHARACTERSET';

SELECT VALUE
FROM NLS_DATABASE_PARAMETERS
WHERE PARAMETER = 'NLS_TERRITORY';

SELECT * FROM
V$NLS_VALID_VALUES
WHERE PARAMETER = 'TERRITORY'
ORDER BY VALUE ASC;

select  *
from    nls_session_parameters
where   1=1
;

