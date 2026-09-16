-- Examples see
--  http://stevenfeuersteinonplsql.blogspot.com/2018/10/how-to-pick-bulk-collect-limit.html

--------------------------------------------------------------------------------
-- Clean up news feeds
--------------------------------------------------------------------------------
declare
    type t_id_tab is table of bsi_newsfeed_responsible.newsfeed_nr%type;
    l_id_tab    t_id_tab    := t_id_tab();
    l_rows      number      := 0;
    --
    c_limit     constant    number      := 1000000;
    --
    cursor  c_resp is
        select  newsfeed_nr
        from    bsi.bsi_newsfeed
        where   item_type_id = 318596 -- Customer
            and evt_change < to_date('20210101','yyyymmdd')
            and change_uid = 75967;
begin
    dbms_output.put_line(concat(to_char(sysdate,'yyyy.mm.dd hh24:mi_ss - '), 'Start delete job for newsfeed responsibles...'));
    open c_resp;
    loop
        fetch c_resp bulk collect into l_id_tab limit c_limit;
        exit when l_id_tab.count = 0; 
        forall i in l_id_tab.first .. l_id_tab.last
            delete  from bsi_newsfeed_responsible
            where   newsfeed_nr = l_id_tab(i);
        l_rows := l_rows + sql%rowcount;
        commit;
        dbms_output.put_line(concat(to_char(sysdate,'yyyy.mm.dd hh24:mi_ss - '), 'Rows delete : ' || l_rows));
    end loop;
    dbms_output.put_line(concat(to_char(sysdate,'yyyy.mm.dd hh24:mi_ss - '), 'Delete job successfully completed!'));
end;