-- Check the database size physical consume on disk.

select  to_char(sum(bytes)/1024/1024, '999G999G999G999', 'NLS_NUMERIC_CHARACTERS=''.''''') size_in_mb 
from    dba_data_files;

-- Check the total space used by data.

select  to_char(sum(bytes)/1024/1024, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS=''.''''') size_in_mb 
from    dba_segments;

-- Check the size of User or Schema in Oracle.

select  owner, 
        to_char(sum(bytes)/1024/1024, '999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') Size_MB 
from    dba_segments 
group   by owner;

-- Check free space and used space in database.

select  topic,
        to_char(value/(1024*1024*1024), '999G999G999G999', 'NLS_NUMERIC_CHARACTERS=''.''''') as size_gb
from    (
            select  1 as pos,
                    'Reserved' as topic,
                    (select sum(bytes) from dba_data_files) as value
            from    dual 
            union
            select  
                    2 as pos,
                    'Used' as topic,
                    (select sum(bytes) from dba_data_files) - (select sum(bytes) from dba_free_space) as value
            from    dual 
            union
            select  3 as pos,
                    'Free' as topic,
                    (select sum(bytes) from dba_free_space) as value
            from    dual 
        )
order   by  pos        

-- Tabelspace overview ---------------------------------------------------------

select  df.tablespace_name "Tablespace",
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
where   df.tablespace_name = tu.tablespace_name ;
