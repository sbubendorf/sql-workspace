-- =============================================================================
--  XML handling / parsing
-- =============================================================================

begin
    k.session#.open_session(
        i_oracle_user   =>  null, --'BUSI',
        i_bu_id         =>  null,
        i_is_batch      =>  null,
        i_is_intf       =>  false,
        i_is_read_only  =>  false
    );
    execute immediate 'alter session set current_schema = k';
end;

select  *
from    msg_extl_in
where   netw_id = 85
    and timestamp > trunc(sysdate)-1
    
    
declare
    l_msg       clob;
    i           number;
    l_pos_num   number;
    l_pos_type  number;
    l_num       varchar2(10);
    l_type      varchar2(10);
begin
    select  text
    into    l_msg
    from    msg_extl_in
    where   id = 85431199;
    --dbms_output.put_line(l_msg);
    i := 0;
    while true loop
        i := i + 1;
        l_pos_num := instr(l_msg,'intl_id="ref_number"',1,i);
        if l_pos_num = 0 then
            dbms_output.put_line('Number of occurences found : ' || (i - 1));
            exit;
        end if;
        dbms_output.put_line('Pos number : ' || l_pos_num);
        l_pos_type := instr(l_msg,'intl_id="ref_number_type"',l_pos_num+1,1);
        dbms_output.put_line('Pos type   : ' || l_pos_type);
        --
        l_pos_num := instr(l_msg,'value="',l_pos_num,1)+7;
        l_num := substr(l_msg,l_pos_num,instr(l_msg,'"',l_pos_num,1)-l_pos_num);
        dbms_output.put_line(l_num);
        --
        l_pos_type := instr(l_msg,'value="',l_pos_type,1)+7;
        l_type := substr(l_msg,l_pos_type,instr(l_msg,'"',l_pos_type,1)-l_pos_type);
        dbms_output.put_line(l_type);
        --
    end loop;
end;    



select  *
from    co_messages m,
        xmltable(
            '/Opening' 
            passing xmltype(message)
            columns 
                obj_sub_type    varchar2(20)    path '@obj_sub_type',
                obj_type        varchar2(20)    path '@obj_type_intl_id',
                opening_type    varchar2(50)    path 'gen-field-list/gen[@intl_id = "opening_type"]/@value',
                customer_type   varchar2(20)    path 'bp-list/bp[@obj_sub_type="MainApplicant"]/classif-list/classif[@intl_id="bp_custr_type"]/@value_intl_id',
                num_bp          number          path 'count(bp-list/bp)',
                num_addr        number          path 'count(addr-list/addr)',
                num_cont        number          path 'count(cont-list/cont)',
                num_macc        number          path 'count(macc-list/macc)',
                num_strat       number          path 'count(strategy-list/strategy)',
                num_docm        number          path 'count(docm-list/docm)'
        ) o
where   m.orun_id = 80011
    and m.state = 'SENT'
    and m.message like '%<strategy-list>%'
    and m.dc > trunc(sysdate) - 7
order   by  m.opening_id desc;



/* Sample XML:

<params>
    <param name="block_sample" val="FALSE"/>
    <param name="cascade" val="TRUE"/>
    <param name="concurrent" val="FALSE"/>
    <param name="degree" val=""/>
    <param name="estimate_percent" val="DBMS_STATS.AUTO_SAMPLE_SIZE"/>
    <param name="force" val="FALSE"/>
    <param name="granularity" val="AUTO"/>
    <param name="method_opt" val="FOR ALL COLUMNS SIZE AUTO"/>
    <param name="no_invalidate" val="FALSE"/>
    <param name="ownname" val=""/>
    <param name="partname" val=""/>
    <param name="reporting_mode" val="FALSE"/>
    <param name="statid" val=""/>
    <param name="statown" val=""/>
    <param name="stattab" val=""/>
    <param name="stattype" val="DATA"/>
    <param name="tabname" val="BSI_X_CONTRACT"/>
</params>

the below statement extracts the "val" attribute

*/


select  osop.target, 
        osop.end_time, 
        osop.operation,
        osop.notes,
        notx.*
from    dba_optstat_operations      osop,     
        xmltable(
            '/params' 
            passing xmltype(notes)
            columns 
                block_sample        varchar2(20)    path '//param[@name="block_sample"]/@val',
                estimate_percent    varchar2(10)    path '//param[@name="estimate_percent"]/@val'
        ) notx
where   1=1
;



