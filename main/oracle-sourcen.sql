-- -----------------------------------------------------------------------------
--  Lookup packages with source code
-- -----------------------------------------------------------------------------
select   ob.object_type, 
         ob.owner, 
         ob.object_name, 
         ob.status, 
         so.code_lines, 
         so.source_code,
         to_char(trunc(ob.created),'yyyy.mm.dd')         as  created,
         to_char(trunc(ob.last_ddl_time),'yyyy.mm.dd')   as  last_ddl
from     sys.all_objects         ob
         inner join
         (
            select   s.owner, 
                     s.name, 
                     s.type, 
                     xmlagg(
                        xmlelement(
                           e, regexp_replace(
                              s.text, 
                              '[^[:print:]' || CHR(10) || CHR(13) || ']', ''
                           )
                        ) order by type, 
                        line
                     ).extract('//text()').getclobval() as source_code, 
                     count(*) as code_lines
            from     all_source        s
            where    s.line <= 300000 -- xmlagg can only handle a maximum of 300000 rows. Onyl package VLQSTAMM_BOB is above this limit!
            group by s.owner, 
                     s.name, 
                     s.type
        )   so    on    so.owner = ob.owner 
                  and   so.type = ob.object_type 
                  and   so.name = ob.object_name
where    ob.owner like upper('F2LDATP0')
   and   ob.object_name like upper('b2%')
   and   so.code_lines > 1000
order   by  ob.object_type,
            ob.owner,
            ob.object_name
;






select   s.text
from     all_source        s
where    s.owner  like upper('F2LDATP0')
    and s.name    like upper('%b2_auf_br%')
order   by  s.owner,
            s.type,
            s.name,
            s.line
;



with function f_cleanup(pi_source in clob) return clob is
   l_source    clob := pi_source;
begin
   -- Von xmlagg umgewandelte Sonderzeichen wiederherstellen
   l_source := replace(l_source, chr(38) || 'gt;','>');
   l_source := replace(l_source, chr(38) || 'lt;','<');
   l_source := replace(l_source, chr(38) || 'apos;','''');
   l_source := replace(l_source, chr(38) || 'quot;','"');
   -- l_source := replace(l_source, chr(10) ,'');
   -- l_source := replace(l_source, chr(13) ,'');
   return l_source;
end f_cleanup;
w_xmlagg as
(
   select   s.owner, 
            s.name, 
            s.type, 
            max(s.line),
            sum(length(s.text)) as total_length,
            f_cleanup(
               xmlagg(
                  xmlelement(
                     e, regexp_replace(
                        s.text, 
                        '[^[:print:]' || CHR(10) || CHR(13) || ']', ''
                     )
                  ) order by s.type, s.line
               ).extract('//text()').getclobval())
            as source_code, 
            count(*) as code_lines
   from     all_source        s
   where    s.owner  like upper('F2LDATP0')
      and s.name    like upper('B2%')
   group by s.owner, 
            s.name, 
            s.type
)
select   s.name,
         s.type,
         s.total_length,
         length(s.source_code) as source_length,
         regexp_substr(s.source_code, '[^'||chr(10)||chr(13)||']+$') as last_line,
         dbms_lob.getlength(s.source_code) as lob_length,
         s.source_code
from     w_xmlagg    s
;


