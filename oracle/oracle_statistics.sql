-- Steuerung der automatischen Berechnung von Statistiken mit dem Parameter 'job_queue_processes'
-- Wenn dieser Parameter auf 0 steht, werden automatisch keine Statistiken Berechnet.
-- In diesem Fall müssen diese manuell berechnet werden mit
--          begin
--              dbms_stats.gather_schema_stats('BSI',no_invalidate=>FALSE,options=>'GATHER STALE');
--          end;

select  *
from    v$parameter p
where   1=1
    and p.name = 'job_queue_processes' 
;

with
    function get_row_count(p_owner varchar2, p_table_name varchar2) return number
    is
        l_num_rows number := 0;
    begin
        execute immediate 'select count(*) from ' || p_owner || '.' || p_table_name into l_num_rows;
        return l_num_rows;
    exception
        when others then
            dbms_output.put_line(p_owner || '.' || p_table_name || ' : ' || sqlerrm || '(' || sqlcode || ')');
            return 0;
    end;
select  s.owner,
        s.table_name,
        s.object_type,
        s.partition_name,
        s.num_rows          as  rows_stat,
      --get_row_count(s.owner, s.table_name) as rows_table,
        s.blocks,
        s.avg_row_len,
        s.sample_size,
        s.last_analyzed,
        s.stale_stats
from    dba_tab_statistics      s
where   owner = 'F2LDATP0'
  and table_name like 'B2_%'
/


/*
DBMS_STATS.GATHER_SCHEMA_STATS ( 
   ownname          VARCHAR2, 
   estimate_percent NUMBER   DEFAULT to_estimate_percent_type 
                                                (get_param('ESTIMATE_PERCENT')), 
   block_sample     BOOLEAN  DEFAULT FALSE, 
   method_opt       VARCHAR2 DEFAULT get_param('METHOD_OPT'),
   degree           NUMBER   DEFAULT to_degree_type(get_param('DEGREE')), 
   granularity      VARCHAR2 DEFAULT GET_PARAM('GRANULARITY'), 
   cascade          BOOLEAN  DEFAULT to_cascade_type(get_param('CASCADE')), 
   stattab          VARCHAR2 DEFAULT NULL, 
   statid           VARCHAR2 DEFAULT NULL, 
   options          VARCHAR2 DEFAULT 'GATHER', 
   objlist          OUT      ObjectTab,
   statown          VARCHAR2 DEFAULT NULL, 
   no_invalidate    BOOLEAN  DEFAULT to_no_invalidate_type (
                                     get_param('NO_INVALIDATE')),
  force             BOOLEAN DEFAULT FALSE,
  obj_filter_list  ObjectTab DEFAULT NULL);
*/


begin
    dbms_stats.gather_schema_stats(
        ownname             => 'F2LDATP0',
        estimate_percent    => null,
        cascade             => true
    );
end;
/

declare
    filter_list     dbms_stats.objecttab := dbms_stats.objecttab();
    object_list     dbms_stats.objecttab := dbms_stats.objecttab();
begin
    filter_list.extend(1);
    filter_list(1).ownname := 'F2LDATP0';
    filter_list(1).objname := 'B2_AUF';
    dbms_stats.gather_schema_stats(
        ownname         => 'F2LDATP0',
        objlist         => object_list,
        obj_filter_list => filter_list,
        cascade         => true,
        force           => true
    );
    --
    for i in 1 .. object_list.count
    loop
        dbms_output.put_line(i || ' : ' || object_list(i).ownname || '.' || object_list(i).objname);
    end loop;
end;
/

-- Show all tables with their calculation status -------------------------------
select  tb.table_name, 
        to_char(coalesce(tb.num_rows,0), '999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''.''''') as num_rows,
        tb.last_analyzed,
        case when tb.last_analyzed > sysdate - 1 then '   Done' else null end as calc_status
from    sys.all_tables  tb  
where   tb.owner like upper('f2ldatp0')
  --and tb.table_name like upper('bsi_change%')
  --and ob.object_name like upper('bsi%customer%')
  --and tb.last_analyzed < trunc(sysdate) -1
order   by  table_name
;


-- Show all tables calculated after a certain point in time --------------------
select  tb.table_name, 
        to_char(coalesce(tb.num_rows,0), '999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''.''''') as num_rows,
        tb.last_analyzed
from    sys.all_tables  tb  
where   tb.owner like upper('f2ldatp0')
    and tb.table_name like upper('%')
  --and ob.object_name like upper('bsi%customer%')
    and tb.num_rows > 100
    and tb.last_analyzed < trunc(sysdate) -1
  --and tb.last_analyzed > to_date('20231018120000','yyyymmddhh24miss')
order   by  tb.last_analyzed desc
;

-- Show all tables not calculated since a certain point in time --------------------
select  tb.table_name, 
        to_char(coalesce(tb.num_rows,0), '999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''.''''') as num_rows,
        tb.last_analyzed
from    sys.all_tables  tb  
where   tb.owner like upper('f2ldatp0')
    and tb.table_name like upper('%')
  --and ob.object_name like upper('bsi%customer%')
    and tb.num_rows > 100
    and tb.last_analyzed < trunc(sysdate) -1
  --and tb.last_analyzed < to_date('20241001000000','yyyymmddhh24miss')
order   by  tb.table_name
;






-- Get current statistics for given table --------------------------------------
declare
    i_owner             varchar2(100)   := 'F2LDATP0';
    i_table_name        varchar2(100)   := 'b2_auf';
    --
    o_num_rows          number;
    o_num_blocks        number;
    o_avg_row_len       number;
begin
    dbms_stats.get_table_stats(
        ownname => upper(i_owner),
        tabname => upper(i_table_name),
        numrows => o_num_rows,
        numblks => o_num_blocks,
        avgrlen => o_avg_row_len
    );
    dbms_output.put_line('Number of rows     : ' || o_num_rows);
    dbms_output.put_line('Number of blocks   : ' || o_num_blocks);
    dbms_output.put_line('Average row length : ' || o_avg_row_len);
end;
/


-- Overwrite current statistics ------------------------------------------------
begin
    dbms_stats.set_table_stats(
        ownname     => 'F2LDATP0',
        tabname     => 'B2_AUF',
        numrows     => 6000,
        numblks     => 1700,
        avgrlen     => 150
    );
end;
/



begin
    sys.dbms_stats.gather_table_stats 
    (
        ownname             => 'F2LDATP0',
        tabname             => 'B2_AUF',
        estimate_percent    => 10,
        method_opt          => 'FOR ALL COLUMNS SIZE 1',
        degree              => 4,
        cascade             => true,
        no_invalidate       => false
    );
end;
/

begin
    sys.dbms_stats.gather_table_stats (
        ownname             => 'F2LDATP0',
        tabname             => 'B2_AUF',
        estimate_percent    => NULL,
        cascade             => true
    );
end;
/


select  tb.table_name, 
        to_char(coalesce(tb.num_rows,0), '999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''.''''') as num_rows,
        tb.last_analyzed,
        '   dbms_stats.gather_table_stats(''BSI'', ''' || ob.object_name || ''');' as gather_stmnt,
        '   analyze table ' || tb.owner || '.' || tb.table_name || ' compute statistics for table;' || lpad('--',50 - length(tb.table_name),' ') || to_char(coalesce(tb.num_rows,0), '999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''.''''') as compute_stmnt
from    sys.all_objects         ob
        left  join  sys.all_tables  tb  on  tb.owner = ob.owner and tb.table_name = ob.object_name
        left  join  sys.all_views   vw  on  vw.owner = ob.owner and vw.view_name = ob.object_name
        left  join  sys.all_indexes ix  on  ix.owner = ob.owner and ix.index_name = ob.object_name
where   ob.object_type in ('TABLE') -- 'FUNCTION','INDEX','PACKAGE','PACKAGE BODY','PROCEDURE','SEQUENCE','TRIGGER')
    and ob.owner like upper('f2ldatp0')
    and ob.object_name like upper('b2_%')
  --and ob.object_name like upper('bsi%customer%')
    and tb.num_rows > 100
  --and tb.last_analyzed < trunc(sysdate) -1
order   by  tb.num_rows desc
;
            






    




