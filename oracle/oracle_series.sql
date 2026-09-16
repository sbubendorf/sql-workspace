-- Get a number serie from 1 to 100 --------------------------------------------
with w_serie (id) as 
( 
    select  1 as id
    from    dual 
    where   1=1
    union   all
    select  s.id + 1 as id
    from    w_serie s
    where   1=1 
        and s.id < 100
)
select  *
from    w_serie;


-- Get all months of the current year or last year in january ------------------
with w_months (month) as 
( 
    select  trunc(sysdate - interval '1' month,'YEAR')   as  month
    from    dual 
    where   1=1
    union   all
    select  m.month + interval '1'  month as month
    from    w_months m
    where   1=1 
        and m.month < trunc(sysdate - interval '1' month,'MONTH')
)
select  *
from    w_months