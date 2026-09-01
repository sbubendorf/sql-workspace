-- $Revision$

-- Search for tables -----------------------------------------------------------------------------

select  *
from    all_tables      t
where   1=1
    and t.OWNER         like upper(coalesce(:OwnerName  , 'F2LDATP0'))
    and t.TABLE_NAME    like upper(coalesce(:TableName  , '%'))
order   by  t.OWNER,
            t.TABLE_NAME;



-- Search for a given column name -----------------------------------------------------------------
select  t.owner,
        t.table_name,
        c.column_name,
        c.data_type,
        c.data_length,
        c.data_precision,
        c.data_scale,
        c.nullable,
        c.column_id
from    all_tab_columns             c
        inner join  all_tables      t   on  t.table_name = c.table_name and t.owner = c.owner
where   1=1
    and t.OWNER         like upper(coalesce(:OwnerName  , 'F2LDATP0'))
    and t.TABLE_NAME    like upper(coalesce(:TableName  , '%'))
    and c.COLUMN_NAME   like upper(coalesce(:ColumnName , '%'))
    -- and c.table_name like 'B2%'
order   by  c.owner,
            c.table_name,
            c.COLUMN_ID
;



select  o.OBJECT_TYPE,
        count(*)
from    ALL_OBJECTS     o
group   by  o.OBJECT_TYPE
order   by  o.OBJECT_TYPE
;

select  *
from    all_objects
where   1=1
fetch   first 25 rows only
;

declare
    cursor cur_tables is
        select  *
        from    all_tables
        where   1=1
        order   by  table_name
        ;
    rec_tables cur_tables%rowtype;
    l_count integer := 0;
begin
   open cur_tables;
   loop
       fetch cur_tables into rec_tables;
       exit when cur_tables%notfound;
       l_count := l_count + 1;
       dbms_output.put_line(rec_tables.table_name);
   end loop;
   dbms_output.put_line('Number of tables: ' || l_count);
   close cur_tables;
end;
/

select  to_char(count(*),'999G999G999G999', 'NLS_NUMERIC_CHARACTERS=''.''''') as num_rows
from    all_tables
;



-- -----------------------------------------------------------------------------
--  Lookup database objects
-- -----------------------------------------------------------------------------
select  ob.object_type, ob.owner, ob.object_name, ob.status,
        to_char(case ob.object_type when 'INDEX' then ix.num_rows when 'TABLE' then tb.num_rows else null end, '999G999G999G999', 'NLS_NUMERIC_CHARACTERS=''.''''')  as  num_rows,
        vw.text as view_source,
        so.source_code,
        coalesce(to_clob(vw.text), so.source_code)                       as  source_code,
        to_char(trunc(ob.created),'yyyy.mm.dd')                 as  created,
        to_char(trunc(ob.last_ddl_time),'yyyy.mm.dd')           as  last_ddl,
        to_char(trunc(tb.last_analyzed),'yyyy.mm.dd')           as  analyzed
from    sys.all_objects         ob
        left  join  sys.all_tables  tb  on  tb.owner = ob.owner and tb.table_name = ob.object_name
        left  join  sys.all_views   vw  on  vw.owner = ob.owner and vw.view_name = ob.object_name
        left  join  sys.all_indexes ix  on  ix.owner = ob.owner and ix.index_name = ob.object_name
        left  join  
        (
            select  owner, name, type, xmlagg(xmlelement(e, to_char(line, '000000') || ' : ' ||  text) order by type, line).extract('//text()').getclobval() as source_code
            from all_source
            group by owner, name, type
        )                           so  on  so.owner = ob.owner and so.type = ob.object_type and so.name = ob.object_name
where   ob.object_type in ('TABLE','VIEW', 'FUNCTION','INDEX','PACKAGE','PACKAGE BODY','PROCEDURE','SEQUENCE','TRIGGER')
    and ob.owner like upper('%')
    and ob.object_name like upper('b2%')
order   by  case ob.object_type when 'TABLE' then 1 when 'VIEW' then 2 when 'PACKAGE' then 3 when 'PACKAGE BODY' then 3 else 9 end,
            ob.object_type,
            ob.owner,
            ob.object_name
;




select owner,
       name as package_name,
       listagg(text, '') within group (
         order by decode(type, 'PACKAGE', 1, 'PACKAGE BODY', 2), line
       ) as source_code
from all_source
where type in ('PACKAGE') -- , 'PACKAGE BODY')
    and  name like 'B2%AUF%'
group by owner, name;

select owner,
       name package_name,
       type,
       xmlagg(
         xmlelement(e, to_char(line, '000000') || ' : ' ||  text)
         order by decode(type, 'PACKAGE', 1, 'PACKAGE BODY', 2), line
       ).extract('//text()').getclobval() as source_code
from all_source
where type in ('PACKAGE', 'PACKAGE BODY')
    and  name like 'B2%AUF%'
group by owner, name, type
;


select  to_char(123, '999999'),
        to_char(123, '000000') 
from    dual
;





-- -----------------------------------------------------------------------------
--  Lookup packages with source code
-- -----------------------------------------------------------------------------
select  ob.object_type, ob.owner, ob.object_name, ob.status,
        so.source_code,
        to_char(trunc(ob.created),'yyyy.mm.dd')                 as  created,
        to_char(trunc(ob.last_ddl_time),'yyyy.mm.dd')           as  last_ddl
from    sys.all_objects         ob
        inner join  
        (
            select  owner, name, type, xmlagg(xmlelement(e, regexp_replace(text, '[^[:print:]]', '')) order by type, line).extract('//text()').getclobval() as source_code
            from    all_source
            where   line <= 300000 -- xmlagg can only handle a maximum of 300000 rows. Onyl package VLQSTAMM_BOB is above this limit!
            group by owner, name, type
        )                           so  on  so.owner = ob.owner and so.type = ob.object_type and so.name = ob.object_name
where   ob.owner like upper('F2LDATP0')
    and ob.object_name like upper('b2%auf_br')
order   by  ob.object_type,
            ob.owner,
            ob.object_name
;





select  ob.owner, 
        to_char(count(*),'999G999G999G999', 'NLS_NUMERIC_CHARACTERS=''.''''') as row_count
from    sys.all_objects         ob
        inner join  all_source  so on  so.owner = ob.owner and so.type = ob.object_type and so.name = ob.object_name and line = 1
group   by  ob.owner
order   by  ob.owner

;



select  owner, name, type, xmlagg(xmlelement(e, regexp_replace(text, '[^[:print:]]', '')) order by type, line).extract('//text()').getclobval() as source_code
from all_source
where line <= 300000 and owner like 'F2%'
group by owner, name, type
;

SELECT RTRIM(
         XMLAGG(
           XMLELEMENT(e, 'PREFIX_' || col_value || CHR(10))  -- Add prefix + newline
           ORDER BY id
         ).EXTRACT('//text()').getClobVal(),
         CHR(10)  -- Remove trailing newline
       ) AS aggregated_text
FROM your_table;



select  owner, name, type, 
        xmlagg(xmlelement(e, regexp_replace(text, '[^[:print:]]', '')) order by type, line).extract('//text()').getclobval() as source_code
from all_source
where line <= 300000
group by owner, name, type
;



select  *
from    all_source      s
where   length(s.text) > 3990
    and owner like 'F2%'
;

select  s.line,
        length(s.text),
        s.text
from    all_source      s
where   name = 'B2Y_BCK_ABR_1M'
;



-- Find biggest source codes -----------------------------------------------------------
select  s.type,
        s.owner,
        s.name,
        to_char(count(*),'999G999G999G999', 'NLS_NUMERIC_CHARACTERS=''.''''') as row_count,
        to_char(sum(length(s.text)),'999G999G999G999', 'NLS_NUMERIC_CHARACTERS=''.''''') as num_chars
from    all_source              s
group   by  s.type,
            s.owner,
            s.name
order   by  row_count desc
fetch first 20 rows only
;

/*

TYPE                        OWNER                       NAME                        ROW_COUNT                   NUM_CHARS                   
PACKAGE BODY                F2LDATP0                    VLQSTAMM_BOB                         425'643                  18'886'845            
PACKAGE BODY                F2LDATP0                    BWQABSA0                              53'638                   3'451'069            
PACKAGE BODY                F2LDATP0                    CAQ_EVENT_BOB                         40'475                   1'836'554            
PACKAGE BODY                F2LDATP0                    VLQKURS_BOB                           37'355                   1'555'697            
PACKAGE BODY                F2LDATP0                    VLQVVIS0                              36'901                   1'631'662            
PACKAGE BODY                F2LDATP0                    ZVQF_GEN_SIC_COMMON_TYPE              29'606                   1'195'141            
PACKAGE BODY                F2LDATP0                    VLQVIZW0                              23'453                   1'042'182            
PACKAGE BODY                F2LDATP0                    VLQGTAB0                              21'257                   1'214'177            
PACKAGE BODY                F2LDATP0                    CAQPRIN0                              20'659                   1'043'595            
PACKAGE BODY                F2LDATP0                    LIQKORR0                              20'500                   1'134'190            
PACKAGE BODY                F2LDATP0                    MFQSTDA0                              20'250                     983'131            
PACKAGE BODY                F2LDATP0                    KDQZPZT0                              19'543                     900'451            
PACKAGE BODY                F2LDATP0                    KDQ_STAMM_BOB                         18'492                     699'081            
PACKAGE BODY                F2LDATP0                    CAQBUCH0                              17'634                     880'665            
PACKAGE BODY                F2LDATP0                    VLQUTIL0                              17'014                     733'652            
PACKAGE BODY                F2LDATP0                    TXQSTAU0                              16'808                     845'525            
PACKAGE BODY                F2LDATP0                    CAQJABR0                              16'594                     894'519            
PACKAGE BODY                F2LDATP0                    ZVQF_GEN_CAMT_COMMON_TYPE             16'534                     641'298            
PACKAGE BODY                F2LDATP0                    PFQRES10                              15'997                     838'433            
PACKAGE BODY                V0LDATM2                    VLQUTIL0                              15'816                     681'293            

*/





-- -----------------------------------------------------------------------------
--  Show value ranges in all columns of a specific table
-- -----------------------------------------------------------------------------
declare
    l_table_name        varchar2(80) := 'dual';   -- Name of table to be analyzed
    l_max_values        pls_integer := 10;    -- Number of x most values shown per field
    l_value_width       pls_integer := 80;    -- Number of characters of values to be shown
    --
    type tab_char       is table of varchar2(4000) index by pls_integer;
    type tab_bin        is table of pls_integer  index by pls_integer;
    l_tab_values        tab_char;
    l_tab_count         tab_bin;
    l_select            varchar2(4000);
    l_count             pls_integer;
    --
    cursor cur_columns is
        select  *
        from    sys.all_tab_columns
        where   table_name = upper(l_table_name)
        order   by  column_id; --column_name;
begin
    dbms_output.put_line(rpad('-',40+l_value_width,'-'));
    dbms_output.put_line(to_char(sysdate, 'yyyy.mm.dd - hh24:mi:ss : ') || 'Value ranges for table ' || l_table_name);
    dbms_output.put_line(rpad('-',40+l_value_width,'-'));
    for rec_column in cur_columns loop
        l_select := 'select count(distinct to_char(' || rec_column.column_name || ')) from ' || l_table_name;
        execute immediate l_select into l_count;
        dbms_output.put_line(lpad(rec_column.column_id,3,'0') || ' - ' || rpad(rec_column.column_name,l_value_width,'.') || ' : ' || lpad(to_char(l_count,'999G999G999G999', 'NLS_NUMERIC_CHARACTERS=''.'''''),15,' ') || '  (' || rec_column.data_type || ')');
        if rec_column.data_type = 'NUMBER' then
            l_select := 'select ' || rec_column.column_name;
            if rec_column.column_name like '%_UID' then
                l_select := l_select || ' || '' - '' || bsiutl_uctext(' || rec_column.column_name || ',246)';
            end if; 
        else  
            l_select := 'select nvl(replace(to_char(' || rec_column.column_name || '),chr(10),''|''),''<null>'')'; 
        end if;
        l_select := l_select || ', count(*) as cnt from ' || l_table_name || ' where ' || rec_column.column_name || ' is not null ';
        if rec_column.data_type = 'NUMBER' then
            l_select := l_select || ' group by ' || rec_column.column_name;
        else
            l_select := l_select || ' group by to_char(' || rec_column.column_name || ')';
        end if;
        l_select := l_select || ' order by cnt desc';
        execute immediate l_select bulk collect into l_tab_values, l_tab_count;
        for j in 1 .. least(l_tab_values.count,l_max_values) loop
            dbms_output.put_line('      ' || rpad(l_tab_values(j),l_value_width) || ' : ' || lpad(to_char(l_tab_count(j),'999G999G999G999', 'NLS_NUMERIC_CHARACTERS=''.'''''),15,' '));
        end loop;
    end loop;
end;
/





-- -----------------------------------------------------------------------------
--  Show all indices for a given table
-- -----------------------------------------------------------------------------
select  distinct
        ix.table_owner, ix.table_name,
        ix.owner,       ix.index_name,
        ix.uniqueness,
        ix.num_rows,    ix.distinct_keys,
        ix.status,      ix.visibility,
        listagg(ic.column_name, ' / ') within group (order by ic.column_position) over (partition by ic.index_owner, ic.index_name) as listagg
from    sys.all_indexes ix
        inner join  sys.all_ind_columns ic  on  ic.index_owner = ix.owner
                                            and ic.index_name = ix.index_name
where   lower(ix.table_name) like 'b2_auf'
order   by  ix.table_owner,
            ix.table_name,
            ix.index_name
;

