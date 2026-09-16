with w_kunden_tab as (
    select 1 as kunden_id, 1 as field_id, '10001' as value from dual union
    select 1 as kunden_id, 2 as field_id, 'Meier' as value from dual union
    select 1 as kunden_id, 3 as field_id, 'Hans' as value from dual union
    select 2 as kunden_id, 1 as field_id, '10002' as value from dual union
    select 2 as kunden_id, 2 as field_id, 'Müller' as value from dual union
    select 2 as kunden_id, 3 as field_id, 'Peter' as value from dual union
    select 3 as kunden_id, 1 as field_id, '10003' as value from dual union
    select 3 as kunden_id, 2 as field_id, 'Bolika' as value from dual union
    select 3 as kunden_id, 3 as field_id, 'Anna' as value from dual union
    select 4 as kunden_id, 1 as field_id, '10004' as value from dual union
    select 4 as kunden_id, 2 as field_id, 'Hugentobler' as value from dual union
    select 4 as kunden_id, 3 as field_id, 'Siblius' as value from dual
)
select  f1.kunden_id,
        f1.value                    as  kunden_nr,
        f2.value                    as  nachname,
        f3.value                    as  vorname
from    w_kunden_tab                f1
        left  join  w_kunden_tab    f2  on  f2.kunden_id = f1.kunden_id and f2.field_id = 2
        left  join  w_kunden_tab    f3  on  f3.kunden_id = f1.kunden_id and f3.field_id = 3
where   f1.field_id = 1        
order   by  kunden_id