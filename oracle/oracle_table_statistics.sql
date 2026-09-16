select  t.owner,
        t.table_name,
        to_char(t.num_rows, '999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''.''''') as num_rows,
        t.last_analyzed
from    sys.all_tables          t
where   1=1
    and t.table_name like '%COMMUNI%'
order   by  coalesce(last_analyzed, to_date('00010101000000','yyyymmddhh24miss')) desc
;


declare
    cursor c_tables is 
        select  bsi.owner           as  owner,
                bsi.table_name      as  bsi_table,
                his.table_name      as  hist_table,
                cdc.table_name      as  cdc_table
        from    sys.all_tables                  cdc
                left  join  sys.all_tables      bsi on  bsi.table_name = replace(cdc.table_name, 'CDC_', 'BSI_')
                left  join  sys.all_tables      his on  his.table_name = bsi.table_name || '_HIST'
        where   cdc.table_name like '%CDC%' 
            and cdc.owner = 'BSI'
        order   by bsi.table_name; 
begin
    for r_tables in c_tables loop
        dbms_stats.gather_table_stats (
             ownname          => r_tables.owner,
             tabname          => r_tables.bsi_table,
             estimate_percent => dbms_stats.auto_sample_size,
             method_opt       => 'for all columns size auto',
             cascade          => true,
             degree           => 5
        );    
    end loop;
end;


exec dbms_stats.gather_schema_stats('bsi'); 

with
    function get_row_count(p_table varchar2) return number
    is
        l_num_rows number := 0;
    begin
        execute immediate 'select count(*) from bsi.' || p_table into l_num_rows;
        return l_num_rows; 
    end;
select  bsi.table_name      as  bsi_table,
        bsi.num_rows        as  bsi_rows,
        his.table_name      as  hist_table,
        his.num_rows        as  hist_rows,
        cdc.table_name      as  cdc_table,
        cdc.num_rows        as  cdc_rows,
        get_row_count(bsi.table_name) as cdc_rows_current
from    sys.all_tables                  cdc
        left  join  sys.all_tables      bsi on  bsi.table_name = replace(cdc.table_name, 'CDC_', 'BSI_')
        left  join  sys.all_tables      his on  his.table_name = bsi.table_name || '_HIST'
where   cdc.table_name like '%CDC%' 
    and cdc.owner = 'BSI'
order   by bsi.table_name; 

