create  sequence sbu_counter
    increment by 1
    start with 1000000
    nomaxvalue
    nocycle
    nocache     -- cache 10
;



select  sbu_counter.currval
from    dual
;    
    
-- -----------------------------------------------------------------------------
--  Lookup database objects
-- -----------------------------------------------------------------------------
select  ob.object_type,
        ob.owner,
        ob.object_name,
        ob.status,
        to_char(
            case ob.object_type
                when 'INDEX' then ix.num_rows
                when 'TABLE' then tb.num_rows
                else null
            end 
        , '999G999G999G999', 'NLS_NUMERIC_CHARACTERS=''.''''') as num_rows,
        vw.text as source
from    sys.all_objects         ob
        left  join  sys.all_tables  tb  on  tb.owner = ob.owner and tb.table_name = ob.object_name
        left  join  sys.all_views   vw  on  vw.owner = ob.owner and vw.view_name = ob.object_name
        left  join  sys.all_indexes ix  on  ix.owner = ob.owner and ix.index_name = ob.object_name
where   ob.object_type in ('SEQUENCE')
    and ob.owner like upper('%')
    and ob.object_name like upper('%%')
order   by  ob.object_type,
            ob.owner,
            ob.object_name    
            
select  bsi_seq.nextval
from    dual
;            

