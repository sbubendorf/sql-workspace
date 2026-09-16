-- Show all tablespaces with free space ----------------------------------------
select  df.tablespace_name                                                                              as  "Tablespace",
        (select instance_name from v$instance)                                                          as  "Instance Name",
        to_char(totalusedspace                      , '999G999G999', 'NLS_NUMERIC_CHARACTERS=''.''''')  as  "Used MB",
        to_char((df.totalspace - tu.totalusedspace) , '999G999G999', 'NLS_NUMERIC_CHARACTERS=''.''''')  as  "Free MB",
        to_char(df.totalspace                       , '999G999G999', 'NLS_NUMERIC_CHARACTERS=''.''''')  as  "Total MB",
        round(100 * ( (df.totalspace - tu.totalusedspace)/ df.totalspace))                              as  "Pct. Free"
from    (
            select  tablespace_name,
                    round(sum(bytes) / 1048576) TotalSpace
            from    dba_data_files
            group   by tablespace_name
        ) df,
        (
            select  tablespace_name,
                    round(sum(bytes)/(1024*1024)) totalusedspace 
            from    dba_segments
            group   by  tablespace_name
        ) tu
where   df.tablespace_name = tu.tablespace_name 
order   by  df.tablespace_name;


select  *
from    v$instance
where   1=1
;
