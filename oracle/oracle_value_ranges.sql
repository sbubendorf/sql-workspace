-- -----------------------------------------------------------------------------
--  Show value ranges in all columns of a specified table
-- -----------------------------------------------------------------------------
declare
    l_table_name        varchar2(80) := 'bsi_communication';     -- Name of table to be analyzed
    l_max_values        pls_integer := 20;  -- Number of x most values shown per field
    l_value_width       pls_integer := 80;  -- Number of characters of values to be shown
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
            and data_type not in ('CLOB','BLOB')
        order   by  column_id; --column_name;
begin
    dbms_output.put_line(rpad('-',40+l_value_width,'-'));
    dbms_output.put_line(to_char(sysdate, 'yyyy.mm.dd - hh24:mi:ss : ') || 'Value ranges for table ' || l_table_name);
    dbms_output.put_line(rpad('-',40+l_value_width,'-'));
    for rec_column in cur_columns loop
        l_select := 'select count(distinct to_char(' || rec_column.column_name || ')) from ' || l_table_name;
        execute immediate l_select into l_count;
        dbms_output.put_line(lpad(rec_column.column_id,3,'0') || ' - ' || rpad(rec_column.column_name,l_value_width,'.') || ' : ' || lpad(to_char(l_count,'999G999G999G999', 'NLS_NUMERIC_CHARACTERS=''.'''''),15,' ') || '  (' || rec_column.data_type || ')');
        l_select := 'select nvl(replace(to_char(' || rec_column.column_name || '),chr(10),''|''),''<null>''), count(*) as cnt from ' || l_table_name || ' where ' || rec_column.column_name || ' is not null group by to_char(' || rec_column.column_name || ') order by cnt desc';
        execute immediate l_select bulk collect into l_tab_values, l_tab_count;
        for j in 1 .. least(l_tab_values.count,l_max_values) loop
            dbms_output.put_line('      ' || rpad(l_tab_values(j),l_value_width) || ' : ' || lpad(to_char(l_tab_count(j),'999G999G999G999', 'NLS_NUMERIC_CHARACTERS=''.'''''),15,' '));
        end loop;
    end loop;
end;


select  *
from    sys.all_tab_columns

where   table_name = upper('dwh_partner')
    and data_type not in ('CLOB','BLOB')
order   by  column_id; --column_name;



-- -----------------------------------------------------------------------------
--  Show value ranges in all columns of a specific table
--  UID will be translated in this version
-- -----------------------------------------------------------------------------
declare
    l_table_name        varchar2(80) := 'bsi_bookmark';   -- Name of table to be analyzed
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
        if rec_column.data_type in ('CLOB','BLOB') then
            dbms_output.put_line('      Large Object --> No analysis!!');
        else
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
        end if;
    end loop;
end;