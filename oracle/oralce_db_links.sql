-- --------------------------------------------------------------------------------
--   Test DB-Links
-- --------------------------------------------------------------------------------

select  *
from    sys.all_db_links
where   1=1
;

select  *
from    sys.all_tables@ados_ods.balgroupit.com  t
where   1=1
    and t.owner like 'ADOS%'
order   by  t.owner,
            t.table_name;

select  *
from    sys.all_tables@ldwh.balgroupit.com  t
where   1=1
    and t.owner like 'DWH%'
order   by  t.owner,
            t.table_name;
            
select  *
from    sys.all_tables@edwh.balgroupit.com  t
where   1=1
    and t.owner like 'EDWH%'
order   by  t.owner,
            t.table_name;
            
            
