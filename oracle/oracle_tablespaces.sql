-- Show all tablespaces with free space ----------------------------------------
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


-- Show table space files ------------------------------------------------------
select  df.tablespace_name,
        df.file_id,
        df.file_name,
        df.status,
        to_char(df.bytes, '999G999G999G999G999', 'NLS_NUMERIC_CHARACTERS=''.''''') as bytes,
        df.autoextensible,
        to_char(df.maxbytes, '999G999G999G999G999', 'NLS_NUMERIC_CHARACTERS=''.''''') as max_bytes
from    dba_data_files      df
;

select  *
from    dba_data_files
;

-- Show temporary table space files --------------------------------------------
select  tf.tablespace_name,
        tf.file_id,
        tf.file_name,
        tf.status,
        to_char(tf.bytes, '999G999G999G999', 'NLS_NUMERIC_CHARACTERS=''.''''') as bytes
from    dba_temp_files  tf
;

-- Get usage of temporary tablespace -------------------------------------------
select  ft.tablespace_name,
        to_char(ft.tablespace_size / 1024 / 1024, '999G999G999', 'NLS_NUMERIC_CHARACTERS=''.''''')    as  tablespace_size,
        to_char(ft.allocated_space / 1024 / 1024, '999G999G999', 'NLS_NUMERIC_CHARACTERS=''.''''')    as  allocated_space,
        to_char(ft.free_space      / 1024 / 1024, '999G999G999', 'NLS_NUMERIC_CHARACTERS=''.''''')    as  free_space
from    dba_temp_free_space     ft
;



-- Temporary Tablespace Sort Usage. --------------------------------------------

select  a.tablespace_name tablespace, 
        to_char(d.mb_total, '999G999G999', 'NLS_NUMERIC_CHARACTERS=''.''''') mb_total,
        to_char(sum (a.used_blocks * d.block_size) / 1024 / 1024, '999G999G999', 'NLS_NUMERIC_CHARACTERS=''.''''') mb_used,
        to_char(d.mb_total - sum (a.used_blocks * d.block_size) / 1024 / 1024, '999G999G999', 'NLS_NUMERIC_CHARACTERS=''.''''') mb_free
from    v$sort_segment a
        inner join (
            select  b.name, 
                    c.block_size, 
                    sum (c.bytes) / 1024 / 1024 mb_total
            from    v$tablespace            b 
                    inner join  v$tempfile  c   on  b.ts#= c.ts#
            group   by  b.name, 
                        c.block_size
        )   d   on  d.name = a.tablespace_name
group   by  a.tablespace_name, 
            d.mb_total
            
            
            
select   s.sid || ',' || s.serial# sid_serial, s.username, s.osuser, p.spid, s.module,
          p.program, sum (t.blocks) * tbs.block_size / 1024 / 1024 mb_used, t.tablespace,
          count(*) statements
 from     v$sort_usage t, v$session s, dba_tablespaces tbs, v$process p
 where    t.session_addr = s.saddr
 and      s.paddr = p.addr
 and      t.tablespace = tbs.tablespace_name
 group by s.sid, s.serial#, s.username, s.osuser, p.spid, s.module,
          p.program, tbs.block_size, t.tablespace
 order by sid_serial;
            