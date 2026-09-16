with    w_tab as
(
    select 1 as id, 'aaa,bbb,ccc,ddd,eee' as text from dual
)
select  id, 
        regexp_substr(text,'[^,]+',1,1) as part1,
        regexp_substr(text,'[^,]+',1,2) as part2,
        regexp_substr(text,'[^,]+',1,3) as part3,
        regexp_substr(text,'[^,]+',1,4) as part4,
        regexp_substr(text,'[^,]+',1,5) as part5,
        regexp_substr(text,'[^,]+',1,6) as part6
from    w_tab
;
