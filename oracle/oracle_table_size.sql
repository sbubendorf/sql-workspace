alter session set current_schema = bsi;


select  topic, to_char(value/(1024*1024*1024), '999G999G999G999', 'NLS_NUMERIC_CHARACTERS=''.''''') as size_gb
        from (
            select 1 as pos, 'Reserved' as topic, (select sum(bytes) from dba_data_files) as value from dual union
            select 2 as pos, 'Used' as topic, (select sum(bytes) from dba_data_files) - (select sum(bytes) from dba_free_space) as value from dual union
            select 3 as pos, 'Free'     as topic, (select sum(bytes) from dba_free_space) as value from dual
        )
order by pos
;


-- Get number of rows for every table ------------------------------------------
with
    function get_row_count(p_table varchar2) return number
    is
        l_num_rows number := 0;
    begin
        execute immediate 'select count(*) from bsi.' || p_table into l_num_rows;
        return l_num_rows; 
    end;
select  table_name,
        get_row_count(table_name) as num_rows
from    sys.all_tables  t
where   t.owner = 'BSI'
order   by  t.table_name;


select  *
from    dba_segments
where   1=1
;



-- Get physical size of tables -------------------------------------------------
with
    function get_row_count(p_table varchar2) return number
    is
        l_num_rows number := 0;
    begin
        execute immediate 'select count(*) from bsi.' || p_table into l_num_rows;
        return l_num_rows;
    exception
        when others then
            dbms_output.put_line(p_table || ' : ' || sqlerrm || '(' || sqlcode || ')');
            return 0;
    end;
select  owner, 
        table_name, 
        balutl_number(get_row_count(table_name),2,12) as num_rows,
        balutl_number(sum(bytes)/1024/1024,2,12) as size_mb,
        balutl_number(sum(bytes),0,15) as size_bytes,
        balutl_number(round( ratio_to_report( sum(bytes) ) over () * 100,2),2) percent
from    (
            select  s.segment_name table_name, s.owner, s.segment_type, s.bytes
            from    dba_segments                s
            where   s.segment_type in ('TABLE', 'TABLE PARTITION', 'TABLE SUBPARTITION')
            union all
            select  i.table_name, i.owner, s.segment_type, s.bytes
            from    dba_indexes                 i   
                    inner join  dba_segments    s   on  s.segment_name = i.index_name and s.owner = i.owner
            where   s.segment_type in ('INDEX', 'INDEX PARTITION', 'INDEX SUBPARTITION')
            union all
            select  l.table_name, l.owner, s.segment_type, s.bytes
            from    dba_lobs                    l
                    inner join  dba_segments    s   on  s.segment_name = l.segment_name and s.owner = l.owner  
            where   s.segment_type in ('LOBSEGMENT', 'LOB PARTITION')
            union all
            select  l.table_name, l.owner, s.segment_type, s.bytes
            from    dba_lobs                    l
                    inner join  dba_segments    s   on  s.segment_name = l.index_name and s.owner = l.owner  
            where   s.segment_type = 'LOBINDEX'
        )
where   1 = 1
    and owner in upper('BSI')
    and table_name like 'BSI_DOCUMENT_%'
group   by  table_name, 
            owner
--having  sum(bytes)/1024/1024 > 10  /* Ignore really small tables */
order   by  table_name --sum(bytes) desc
;


select  *
from    bsi.bsi_x_contract_custo_change
where   1=1
;

-- Show all BSI CRM Lobs -------------------------------------------------------
select  tabs.owner,
        tabs.table_name,
        tabs.tablespace_name,
        tabs.status,
        to_char(tabs.num_rows, '999G999G999G999', 'NLS_NUMERIC_CHARACTERS=''.''''') as num_rows,
        lobs.column_name,
        lobs.segment_name,
        lobs.index_name,
        to_char(segt.bytes / 1024 / 1024, '999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''')    as  mb_table,
        to_char(segl.bytes / 1024 / 1024, '999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''')    as  mb_lobseg
from    dba_tables                  tabs
        inner join  dba_segments    segt    on  segt.owner = tabs.owner and segt.segment_name = tabs.table_name and segt.segment_type = 'TABLE'
        inner join  dba_lobs        lobs    on  lobs.owner = tabs.owner and lobs.table_name = tabs.table_name
        inner join  dba_segments    segl    on  segl.owner = lobs.owner and segl.segment_name = lobs.segment_name
where   1=1
    and tabs.owner = 'BSI'
    and tabs.table_name like 'BSI_%_CHANGE'
order   by  segt.bytes desc,
            tabs.owner,
            tabs.table_name,
            lobs.column_name;
            

