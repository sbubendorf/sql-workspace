/*

Column Type Codes delivered by dbms_sql.desc_tab:

  TYPECODE_VARCHAR         PLS_INTEGER :=   1;
  TYPECODE_NUMBER          PLS_INTEGER :=   2;
  TYPECODE_VARCHAR2        PLS_INTEGER :=   9;
  TYPECODE_DATE            PLS_INTEGER :=  12;
  TYPECODE_OPAQUE          PLS_INTEGER :=  58;
  TYPECODE_RAW             PLS_INTEGER :=  95;
  TYPECODE_CHAR            PLS_INTEGER :=  96;
  TYPECODE_MLSLABEL        PLS_INTEGER := 105;
  TYPECODE_OBJECT          PLS_INTEGER := 108;
  TYPECODE_REF             PLS_INTEGER := 110;
  TYPECODE_CLOB            PLS_INTEGER := 112;
  TYPECODE_BLOB            PLS_INTEGER := 113;
  TYPECODE_BFILE           PLS_INTEGER := 114;
  TYPECODE_CFILE           PLS_INTEGER := 115;
  TYPECODE_NAMEDCOLLECTION PLS_INTEGER := 122;
  TYPECODE_TIMESTAMP       PLS_INTEGER := 187;
  TYPECODE_TIMESTAMP_TZ    PLS_INTEGER := 188;
  TYPECODE_INTERVAL_YM     PLS_INTEGER := 189;
  TYPECODE_INTERVAL_DS     PLS_INTEGER := 190;
  TYPECODE_TIMESTAMP_LTZ   PLS_INTEGER := 232;
  TYPECODE_VARRAY          PLS_INTEGER := 247;
  TYPECODE_TABLE           PLS_INTEGER := 248;
*/




-- -----------------------------------------------------------------------------
--  Lookup database objects
-- -----------------------------------------------------------------------------
select  ob.object_type,
        ob.owner,
        ob.object_name,
        ob.status,
        case ob.object_type
            when 'INDEX' then ix.num_rows
            when 'TABLE' then tb.num_rows
            else null
        end as num_rows,
        vw.text as source
from    sys.all_objects         ob
        left  join  sys.all_tables  tb  on  tb.owner = ob.owner and tb.table_name = ob.object_name
        left  join  sys.all_views   vw  on  vw.owner = ob.owner and vw.view_name = ob.object_name
        left  join  sys.all_indexes ix  on  ix.owner = ob.owner and ix.index_name = ob.object_name
where   ob.object_type in ('TABLE','VIEW') -- 'FUNCTION','INDEX','PACKAGE','PACKAGE BODY','PROCEDURE','SEQUENCE','TRIGGER')
    and ob.owner like upper('bsi')
    and ob.object_name like upper('%%')
order   by  ob.object_type,
            ob.owner,
            ob.object_name
            
select  *
from    bsi_parameter
;            

declare
    l_table         varchar2(100)   := 'bsi_person';
    l_query         varchar2(32767) := 'select person_nr, person_no from bsi_person where rownum < 5';
    l_cursor        integer default dbms_sql.open_cursor;
    l_value         varchar2(4000);
    l_status        integer;
    l_desc_table    dbms_sql.desc_tab;
    l_num_cols      number;
    n number := 0;
  procedure p(msg varchar2) is
    l varchar2(4000) := msg;
  begin
    while length(l) > 0 loop
      dbms_output.put_line(substr(l,1,80));
      l := substr(l,81);
    end loop;
  end;
begin
    execute immediate
    'alter session set nls_date_format=''yyyy.mm.dd hh24:mi:ss'' ';
    l_query := 'select * from ' || l_table;
    dbms_sql.parse(  l_cursor,  l_query, dbms_sql.native );
    dbms_sql.describe_columns( l_cursor, l_num_cols, l_desc_table );
    dbms_output.put_line('Number of columns in the query: ' || l_num_cols);
    for i in 1 .. l_num_cols loop
        dbms_output.put_line(l_desc_table(i).col_name || ' : ' || l_desc_table(i).col_type);
        if l_desc_table(i).col_type in (112,113) then
            dbms_output.put_line('  Large Object : No analysis!');
        else
            l_status := dbms_sql.execute(l_cursor);
        end if;
    end loop;
    /*
    for i in 1 .. l_num_cols loop
        dbms_sql.define_column(l_cursor, i, l_value, 4000);
        dbms_output.put_line(l_value);
    end loop;
    l_status := dbms_sql.execute(l_cursor);
    while ( dbms_sql.fetch_rows(l_cursor) > 0 ) loop
        for i in 1 .. l_num_cols loop
            dbms_sql.column_value( l_cursor, i, l_value );
            p( rpad( l_desc_table(i).col_name, 30 ) || ': ' || l_value );
        end loop;
        dbms_output.put_line( '-----------------' );
        n := n + 1;
    end loop;
    if n = 0 then
      dbms_output.put_line( chr(10)||'No data found '||chr(10) );
    end if;
    */
end;
    

declare
    l_table         varchar2(100)   := 'bsi_person';
    l_query         varchar2(32767) := 'select person_nr, person_no from bsi_person where rownum < 5';
    l_cursor        integer default dbms_sql.open_cursor;
    l_value         varchar2(4000);
    l_status        integer;
    l_desc_table    dbms_sql.desc_tab;
    l_num_cols      number;
    l_col_id        varchar2(128);
    l_col_name      varchar2(128);
    l_col_type      varchar2(128);
begin
    l_query := 'select c.column_id, c.column_name, c.data_type from sys.all_tab_columns c where upper(c.table_name) = ''' || upper(l_table) || ''''; 
    dbms_sql.parse(  l_cursor,  l_query, dbms_sql.native );
    dbms_sql.describe_columns( l_cursor, l_num_cols, l_desc_table );
    dbms_output.put_line('Number of columns in the query: ' || l_num_cols);
    /*
    for i in 1 .. l_num_cols loop
        dbms_sql.define_column(l_cursor, i, l_value, 4000);
        dbms_output.put_line(l_value);
    end loop;
    */
    dbms_sql.define_column(l_cursor, 1, l_col_id, 22);
    dbms_sql.define_column(l_cursor, 2, l_col_name, 128);
    dbms_sql.define_column(l_cursor, 3, l_col_type, 128);
    l_status := dbms_sql.execute(l_cursor);
    while ( dbms_sql.fetch_rows(l_cursor) > 0 ) loop
        /*
        for i in 1 .. l_num_cols loop
            dbms_sql.column_value( l_cursor, i, l_value );
            p( rpad( l_desc_table(i).col_name, 30 ) || ': ' || l_value );
        end loop;
        */
        dbms_sql.column_value( l_cursor, 1, l_col_id );
        dbms_sql.column_value( l_cursor, 2, l_col_name );
        dbms_sql.column_value( l_cursor, 3, l_col_type );
        dbms_output.put_line(lpad(l_col_id,3,'0') || ' : ' || l_col_name || ' (' || l_col_type || ')');
    end loop;
end;



    
