-- -----------------------------------------------------------------------------
-- Show value range of a given table
-- -----------------------------------------------------------------------------
declare
    l_table         varchar2(128)   := 'bsi_bookmark';          -- <-- Insert name of table to be analyized
    l_num_values    number          := 6;                      -- <-- Insert number of most stored distinct values to be shown (0 = all)
    --
    l_col_name_len  number          := 0;
    l_num_cols      number          := 0;
    l_query         varchar2(32767);
    l_cursor        integer default dbms_sql.open_cursor;
    l_value         varchar2(4000);
    l_status        integer;
    l_desc_table    dbms_sql.desc_tab;
    l_val_count     varchar2(128);
    l_row_num       number;
    l_total_values  varchar2(20);
    l_total_rows    varchar2(20);
    n number;
    --
    function num_format(i_value in varchar2) return varchar2 is
    begin
        return to_char(i_value,'9G999G999G999', q'[NLS_NUMERIC_CHARACTERS='.''']');
    end;
begin
    dbms_output.put_line(' ');
    dbms_output.put_line('Analyzing table ' || upper(l_table));
    dbms_output.put_line(rpad('-',16+length(l_table),'-'));
    dbms_output.put_line(' ');
    --
    l_query := 'select count(*) as num_rows from ' || l_table;
    dbms_sql.parse(  l_cursor,  l_query, dbms_sql.native );
    dbms_sql.describe_columns( l_cursor, l_num_cols, l_desc_table );
    dbms_sql.define_column(l_cursor, 1, l_total_rows, 20);
    l_status := dbms_sql.execute(l_cursor);
    n := dbms_sql.fetch_rows(l_cursor);
    dbms_sql.column_value( l_cursor, 1, l_total_rows );
    dbms_output.put_line('Total number of rows : ' || num_format(l_total_rows));
    dbms_output.put_line(' ');
    --
    select max(length(c.column_name)) into l_col_name_len from sys.all_tab_columns c where upper(c.table_name) = upper(l_table);
    for r in (select c.column_id, c.column_name, c.data_type, c.data_length from sys.all_tab_columns c where upper(c.table_name) = upper(l_table)) loop
        dbms_output.put_line(lpad(r.column_id,3,'0') || ' : ' || rpad(r.column_name, l_col_name_len, ' ') || ' (' || r.data_type || ')');
        if r.data_type in ('CLOB','BLOB') then
            dbms_output.put_line('      Large Object --> No analysis!!');
            dbms_output.put_line(' ');
        else
            l_query := 'select count(distinct(' || r.column_name || ')) as num_vals from ' || l_table;
            dbms_sql.parse(  l_cursor,  l_query, dbms_sql.native );
            dbms_sql.describe_columns( l_cursor, l_num_cols, l_desc_table );
            dbms_sql.define_column(l_cursor, 1, l_total_values, 20);
            l_status := dbms_sql.execute(l_cursor);
            n := dbms_sql.fetch_rows(l_cursor);
            dbms_sql.column_value( l_cursor, 1, l_total_values );
            l_query := 'select * from (select coalesce(to_char(' || r.column_name || '),''<null>'') as value, count(*) as num_distinct from ' || l_table || ' group by ' || r.column_name || ' order by 2 desc) where rownum <= ' || (l_num_values + 1); 
            dbms_sql.parse(  l_cursor,  l_query, dbms_sql.native );
            dbms_sql.describe_columns( l_cursor, l_num_cols, l_desc_table );
            dbms_sql.define_column(l_cursor, 1, l_value, 4000);
            dbms_sql.define_column(l_cursor, 2, l_val_count, 20);
            l_status := dbms_sql.execute(l_cursor);
            l_row_num := 0;
            while ( dbms_sql.fetch_rows(l_cursor) > 0 ) loop
                l_row_num := l_row_num + 1;
                if l_row_num <= l_num_values then
                    dbms_sql.column_value( l_cursor, 1, l_value );
                    dbms_sql.column_value( l_cursor, 2, l_val_count );
                    dbms_output.put_line('      ' || lpad(num_format(l_val_count),8,' ') || ' : ' || l_value);
                else
                    dbms_output.put_line('                 ...');
                end if;
            end loop;
            dbms_output.put_line('                 (' || num_format(l_total_values) || ')');
            dbms_output.put_line(' ');
        end if;
    end loop;
end;