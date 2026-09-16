-- Show columns with histogram type 'HEIGHT BALANCED' --------------------------
select  tabc.owner,
        tabc.table_name,
        tabc.column_name,
        tabc.data_type,
        tabc.num_distinct,
        tabc.last_analyzed,
        tabc.histogram
from    dba_tab_columns     tabc 
where   1=1
    and owner='BSI' 
    and histogram='HEIGHT BALANCED';
    
-- Show all used histogram types -----------------------------------------------
select  taco.histogram,
        count(*)
from    dba_tab_columns         taco
where   1=1
    and taco.owner = 'BSI'
group   by  taco.histogram
order   by  2   desc
;    



            
-- Show status of histogram types (0=disabled / 3=enabled) ---------------------
            
select dbms_stats.get_prefs('ENABLE_HYBRID_HISTOGRAMS') hist_enabled from dual;            

select dbms_stats.get_prefs('ENABLE_TOP_FREQ_HISTOGRAMS') hist_enabled from dual;            

-- Show status on table level --------------------------------------------------

select  tabc.owner,
        tabc.table_name,
        tabc.column_name,
        tabc.data_type,
        tabc.num_distinct,
        tabc.last_analyzed,
        tabc.histogram,
        dbms_stats.get_prefs('ENABLE_HYBRID_HISTOGRAMS', ownname=>tabc.owner, tabname=>tabc.table_name) as hybrid_enabled,
        dbms_stats.get_prefs('ENABLE_TOP_FREQ_HISTOGRAMS', ownname=>tabc.owner, tabname=>tabc.table_name) as top_freq_enabled
from    dba_tab_columns     tabc 
where   owner='BSI' 
  --and histogram='HEIGHT BALANCED'
    and tabc.table_name like 'DWH%'
;


  
select  osop.target, 
        osop.end_time, 
        osop.operation,
        notx.*,
        osop.notes
from    dba_optstat_operations      osop,     
        xmltable(
            '/params' 
            passing xmltype(notes)
            columns 
                block_sample        varchar2(20)    path '//param[@name="block_sample"]/@val',
                estimate_percent    varchar2(10)    path '//param[@name="estimate_percent"]/@val'
        ) notx
where   1=1
    and notx.estimate_percent is not null
    and length(trim(translate(notx.estimate_percent, ' +-.0123456789', ' '))) is null
order   by  notx.estimate_percent
;


exec dbms_stats.gather_table_stats('BSI','DWH_PARTNER_S1',ESTIMATE_PERCENT=>50,options=>'GATHER',method_opt=>'FOR ALL COLUMNS SIZE 1');

exec dbms_stats.gather_table_stats('BSI','DWH_BENEFIT_S1',ESTIMATE_PERCENT=>50,options=>'GATHER',method_opt=>'FOR ALL COLUMNS SIZE 1');

exec dbms_stats.gather_table_stats('BSI','DWH_REPRESENTATIVE_S1',ESTIMATE_PERCENT=>50,options=>'GATHER',method_opt=>'FOR ALL COLUMNS SIZE 1');

exec dbms_stats.gather_table_stats('BSI','DWH_CONTRACT_RELATION_S1',ESTIMATE_PERCENT=>50,options=>'GATHER',method_opt=>'FOR ALL COLUMNS SIZE 1');


declare
    l_db_name varchar2(100);
    cursor c_tables is
        select  tabc.owner,
                tabc.table_name
        from    dba_tab_columns     tabc 
        where   owner='BSI' 
            and histogram='HEIGHT BALANCED';
begin
    select  instance_name
    into    l_db_name
    from    v$instance;
    dbms_output.put_line('Removing histogram type "HEIGHT BALANCED" on databae ' || l_db_name || '...');
    for r_table in c_tables loop
        dbms_output.put_line('  - ' || r_table.owner || '.' || r_table.table_name);
        dbms_stats.gather_table_stats(
            r_table.owner,
            r_table.table_name
          --estimate_percent=>50,
          --options=>'GATHER',
          --method_opt=>'FOR ALL COLUMNS SIZE 1'
        );
    end loop;
    dbms_output.put_line('All table statistics gathered successfully!');
end;



DWH_BENEFIT_S1
DWH_ADDRESS_S1
DWH_ADDRESS_S1
BSI_X_CONTRACT_CUSTOMER
DWH_PARTNER_S1
DWH_CONTRACT_RELATION_S1

exec dbms_stats.gather_table_stats('BSI','DWH_BENEFIT_S1');

exec dbms_stats.gather_table_stats('BSI','DWH_ADDRESS_S1');

exec dbms_stats.gather_table_stats('BSI','BSI_X_CONTRACT_CUSTOMER',ESTIMATE_PERCENT=>50,options=>'GATHER',method_opt=>'FOR ALL COLUMNS SIZE 1');

exec dbms_stats.gather_table_stats('BSI','DWH_PARTNER_S1');

exec dbms_stats.gather_table_stats('BSI','DWH_CONTRACT_RELATION_S1');

