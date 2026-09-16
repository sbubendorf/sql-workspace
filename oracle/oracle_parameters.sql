select  p.num,
        p.name,
        case p.type 
            when 1 then 'Boolean' 
            when 2 then 'String' 
            when 3 then 'Integer' 
            when 4 then 'Parameter file' 
            when 5 then 'Reserved' 
            when 6 then 'Big integer' 
            else to_char(p.type) || ' - Unknown' 
        end as type,
        p.value,                    -- Parameter value for the session (if modified within the session); otherwise, the instance-wide parameter value
        p.display_value,            -- Parameter value in a user-friendly format
        p.default_value,            -- The default value for this parameter. This is the value of the parameter if a value is not explicitly specified for the parameter
        p.isdefault,                -- Indicates whether the parameter is set to the default value (TRUE) or the parameter value was specified in the parameter file (FALSE). The database sets the value of the ISDEFAULT column to TRUE for parameters that are not specified in the init.ora or server parameter file (SPFILE).
        p.isses_modifiable,         -- Indicates whether the parameter can be changed with ALTER SESSION (TRUE) or not (FALSE)
        p.issys_modifiable,         -- Indicates whether the parameter can be changed with ALTER SYSTEM and when the change takes effect: IMMEDIATE - Parameter can be changed with ALTER SYSTEM regardless of the type of parameter file used to start the instance. The change takes effect immediately. / DEFERRED - Parameter can be changed with ALTER SYSTEM regardless of the type of parameter file used to start the instance. The change takes effect in subsequent sessions. / FALSE - Parameter cannot be changed with ALTER SYSTEM unless a server parameter file was used to start the instance. The change takes effect in subsequent instances.
        p.ispdb_modifiable,         -- Indicates whether the parameter can be modified inside a PDB (TRUE) or not (FALSE)
        p.isinstance_modifiable,    -- For parameters that can be changed with ALTER SYSTEM, indicates whether the value of the parameter can be different for every instance (TRUE) or whether the parameter must have the same value for all Real Application Clusters instances (FALSE). If the ISSYS_MODIFIABLE column is FALSE, then this column is always FALSE.
        p.ismodified,               -- Indicates whether the parameter has been modified after instance startup: MODIFIED - Parameter has been modified with ALTER SESSION / SYSTEM_MOD - Parameter has been modified with ALTER SYSTEM (which causes all the currently logged in sessions' values to be modified) / FALSE - Parameter has not been modified after instance startup
        p.isadjusted,               -- Indicates whether Oracle adjusted the input value to a more suitable value (for example, the parameter value should be prime, but the user input a non-prime number, so Oracle adjusted the value to the next prime number)
        p.isdeprecated,             -- Indicates whether the parameter has been deprecated (TRUE) or not (FALSE)
        p.isbasic,                  -- Indicates whether the parameter is a basic parameter (TRUE) or not (FALSE)
        p.description,              -- Description of the parameter
        p.update_comment,           -- Comments associated with the most recent update
        p.hash,                     -- Hash value for the parameter name
        p.con_id                    -- The ID of the container to which the data pertains. Possible values include: 0: This value is used for rows containing data that pertain to the entire CDB. This value is also used for rows in non-CDBs. / 1: This value is used for rows containing data that pertain to only the root / n: Where n is the applicable container ID for the rows containing data
from    v$parameter     p
where   1=1
    and p.name like 'undo%'
order   by  p.name
;

select  *
from    sys.gv_$parameter       p
where   1=1
;





