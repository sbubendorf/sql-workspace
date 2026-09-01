-- -----------------------------------------------------------------------------
--  Get all type declarations without function F_ToString
-- -----------------------------------------------------------------------------
select  ob.object_type, ob.owner, ob.object_name, ob.status, 
        so.num_lines,
        so.source_code,
        to_char(trunc(ob.created),'yyyy.mm.dd')                 as  created,
        to_char(trunc(ob.last_ddl_time),'yyyy.mm.dd')           as  last_ddl
from    sys.all_objects         ob
        inner join
        (
            select  owner, name, type, xmlagg(xmlelement(e, regexp_replace(text, '[^[:print:]' || CHR(10) || CHR(13) || ']', '')) order by type, line).extract('//text()').getclobval() as source_code, count(*) as num_lines       
            from    all_source
            where   line <= 300000 -- xmlagg can only handle a maximum of 300000 rows. Onyl package VLQSTAMM_BOB is above this limit!
            group by owner, name, type
        )                           so  on  so.owner = ob.owner and so.type = ob.object_type and so.name = ob.object_name
where   ob.owner like upper('F2LDATP0')
    and ob.object_name like upper('B2Y%')
    and ob.OBJECT_TYPE like 'TYPE'
    and so.source_code not like '%F_ToString%'
order   by  ob.owner,
            ob.object_name,
            ob.object_type
;

-- only with first code line -----------------------------------------
select  ob.object_type, ob.owner, ob.object_name, ob.status, 
        upper(so.text) as source_code,
        to_char(trunc(ob.created),'yyyy.mm.dd')                 as  created,
        to_char(trunc(ob.last_ddl_time),'yyyy.mm.dd')           as  last_ddl
from    sys.all_objects             ob
        inner join  sys.all_source  so  on  so.owner = ob.owner and so.type = ob.object_type and so.name = ob.object_name and so.line = 1
where   ob.owner like upper('F2LDATP0')
    and ob.object_name like upper('B2Y%')
    and ob.OBJECT_TYPE like 'TYPE'
    and not exists 
        (
            select  null
            from    all_source  s
            where   s.owner = so.owner 
                and s.type = so.type 
                and s.name = so.name
                and s.text like '%F_ToString%'
        )
order   by  ob.owner,
            ob.object_name,
            ob.object_type
;




SELECT  s.owner,
        s.name,
        s.type,
        upper(TRIM(SUBSTR(s.text, 1, case when instr(s.text,' ') > 0 then instr(s.text, ' ') - 1 else length(s.text) end))) as first_word
FROM    ALL_SOURCE          s
where   s.owner like upper('F2LDATP0')
    and s.name like upper('B2%')
    and s.line = 1
    and upper(TRIM(SUBSTR(s.text, 1, case when instr(s.text,' ') > 0 then instr(s.text, ' ') - 1 else length(s.text) end))) = 'TYPE'
    and s.name not like 'B2Y%'
    and s.name not like 'B2C%'
;



SELECT  *
FROM    sys.ALL_SOURCE          s
WHERE   s.name = 'B2YF_B2IR_INPUT_PARAMS'
order   by  s.line;