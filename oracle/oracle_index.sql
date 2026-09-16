-- -----------------------------------------------------------------------------
--  Show indices
-- -----------------------------------------------------------------------------
select  ix.table_name,
        ix.index_name,
        ix.index_type,
        ix.uniqueness,
      --ix.compression,
        ix.status,
      --ix.last_analyzed,
      --ix.dropped,
      --ix.visibility,
        to_char(ix.num_rows, '999G999G999G999', 'NLS_NUMERIC_CHARACTERS=''.''''') as num_rows,
        ic.column_position,
        ic.column_name
from    sys.all_indexes ix
        inner join  sys.all_ind_columns     ic  on  ic.index_name = ix.index_name
where   1=1
    and ix.table_owner = 'BSI'
    and upper(ix.table_name) like upper('%data%')
order   by  ix.table_name,
            ix.index_name,
            ic.column_position
        





drop index idx_mgr_test

create index idx_mgr_test on BSI_DOCUMENT 
    (
        ITEM_KEY0_NR, 
        ITEM_TYPE_ID, 
        ITEM_KEY1_NR, 
        ITEM_KEY2_NR
    );

create index idx_item_type_test on BSI_DOCUMENT 
    (
        ITEM_TYPE_ID 
    );

create index bsi_communication_test2 on BSI_COMMUNICATION 
    (
        TYPE_UID 
    );





-- Active all disabled function based indices ----------------------------------
declare 
    sql_s varchar2 (500 char); 
    cursor ind
        is 
          select *
          from all_indexes
          where owner = 'HMIDBDBA'
          and index_type = 'FUNCTION-BASED NORMAL'
          and funcidx_status = 'DISABLED'
          ;
begin 
    for ind_rec in ind 
    loop 
        sql_s := 'alter index HMIDBDBA.' || ind_rec.index_name || ' enable'; 
        execute immediate sql_s; 
        dbms_output.put_line('Index ' || ind_rec.index_name || ' updated.'); 
    end loop; 
end; 

