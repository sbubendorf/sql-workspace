declare
    l_statement clob;
    l_row       clob;
    l_index     number := 0;
    l_offset    number := 1;
    l_line_size number := 10000;
    l_in_count  number := 4000;
    l_rows      number := 0;
    l_rule_uid  number := 1089906612; -- Rule "Wiedervorlage von Erneuerungen im Status Beendet ohne Erfolg" 
    l_cursor    integer default dbms_sql.open_cursor;
    --
    cursor      c_items is 
                    select  rupp.item_type_id,
                            rupp.item_key0_nr
                    from    bsi.bsi_rule_run            ruru
                            inner join  bsi.bsi_rule_pending_processing rupp    on  rupp.rule_run_nr = ruru.rule_run_nr
                    where   1=1
                        and ruru.rule_uid = l_rule_uid
                    ; 
begin
    l_statement := 'SELECT table_0_.ITEM_TYPE_ID AS col_0_, table_0_.ITEM_KEY0_NR AS col_0__1 FROM BSI_RULE_EXECUTION_COMPLETED table_0_ WHERE table_0_.RULE_UID=:rule_uid AND ((table_0_.ITEM_TYPE_ID, table_0_.ITEM_KEY0_NR) in (';
    for r_item in c_items
    loop
        dbms_lob.append(l_statement, '(' || r_item.item_type_id || ',' || r_item.item_key0_nr || ')');
        l_index := l_index + 1;
        if (mod(l_index,l_in_count) = 0) then 
            dbms_lob.append(l_statement, ') OR (table_0_.ITEM_TYPE_ID, table_0_.ITEM_KEY0_NR) in (');
        else
            dbms_lob.append(l_statement, ',');
        end if;
    end loop;
    if (substr(l_statement,-1) = ',') then
        l_statement := substr(l_statement,1,length(l_statement)-1);
    else
        l_statement := substr(l_statement,1,length(l_statement)-56);
    end if;
    dbms_lob.append(l_statement, '))');
    dbms_output.put_line('Number of rows : ' || l_index);
    --
    loop 
        exit when l_offset > dbms_lob.getlength(l_statement);
        l_row := dbms_lob.substr( l_statement, l_line_size, l_offset);
        dbms_output.put_line (l_row);
        l_offset := l_offset + l_line_size;
    end loop;
    dbms_output.new_line;
    dbms_sql.parse(
        c               =>  l_cursor,
        statement       =>  l_statement,
        language_flag   =>  dbms_sql.native 
    );
    dbms_sql.bind_variable(
        c               =>  l_cursor,
        name            =>  'rule_uid',
        "value"           =>  l_rule_uid
    );
    l_rows := dbms_sql.execute(l_cursor);
  --dbms_sql.define_column(l_cursor, 1, item_type_id number);
  --dbms_sql.define_column(l_cursor, 2, item_key_nr  number);
    --
    loop
      rows_fetched := dbms_sql.fetch_rows(cursor_id);
      exit when rows_fetched = 0;
      
      -- Process fetched rows here
      -- For example, fetch column values using DBMS_SQL.COLUMN_VALUE procedure
    end loop;
    dbms_output.put_line('Number of rows ins resultset: ' || l_rows);
    dbms_sql.close_cursor( l_cursor );
end;
/




declare
    l_statement     clob;
    l_rows_result   number := 0;
    l_rows_fetched	number := 0;
    l_cursor        integer default dbms_sql.open_cursor;
begin
    l_statement := 'select dummy from dual where 1 = :param';
    dbms_sql.parse(l_cursor, l_statement, dbms_sql.native);
    dbms_sql.bind_variable(l_cursor, 'param', 1);
    l_rows_result := dbms_sql.execute(l_cursor);
    dbms_sql.define_column(l_cursor, 1, cast(null as varchar2));
    l_rows_result := dbms_sql.execute(l_cursor);
    while (dbms_sql.fetch_rows(l_cursor) > 0) 
    loop
        
    end loop;
    dbms_sql.close_cursor( l_cursor );
end;
/


declare
    curid        integer;
    v_cnt        number;
    v_tab        dbms_sql.desc_tab2;
    fdb          number;
    v_row        clob;
    v_sql        clob := 'select * from bsi.bsi_customer c where rownum <= :num_rows';
    --
    type r_type is record
    ( 
        v2_column    varchar2(32767), 
        num_column   number, 
        date_column  date, 
        clob_column  clob, 
        ids_column   interval day to second, 
        iym_column   interval year to month, 
        ts_column    timestamp, 
        tstz_column  timestamp with time zone, 
        tsltz_column timestamp with local time zone
    );
    rec r_type;
begin
    curid := dbms_sql.open_cursor;
    dbms_sql.parse(curid, v_sql, dbms_sql.native);
    DBMS_SQL.BIND_VARIABLE(curid, 'num_rows', 2);
    dbms_sql.describe_columns2(curid, v_cnt, v_tab);
    for i in 1 .. v_cnt
    loop
        case 
            when v_tab(i).col_type in (1, 96, 11, 208)  then    dbms_sql.define_column(curid, i, cast(null as varchar2), 32767);                --VARCHAR2, CHAR, ROWID, UROWID
            when v_tab(i).col_type = 2                  then    dbms_sql.define_column(curid, i, cast(null as number));                         --NUMBER
            when v_tab(i).col_type = 12                 then    dbms_sql.define_column(curid, i, cast(null as date));                           --DATE
            when v_tab(i).col_type = 112                then    dbms_sql.define_column(curid, i, cast(null as clob));                           --CLOB             
            when v_tab(i).col_type = 180                then    dbms_sql.define_column(curid, i, cast(null as timestamp));                      --TIMESTAMP
            when v_tab(i).col_type = 181                then    dbms_sql.define_column(curid, i, cast(null as timestamp with time zone));       --TIMESTAMP WITH TIME ZONE
            when v_tab(i).col_type = 182                then    dbms_sql.define_column(curid, i, cast(null as interval year to month));         --INTERVAL YEAR TO MONTH
            when v_tab(i).col_type = 183                then    dbms_sql.define_column(curid, i, cast(null as interval day to second));         --INTERVAL DAY TO SECOND
            when v_tab(i).col_type = 231                then    dbms_sql.define_column(curid, i, cast(null as timestamp with local time zone)); --TIMESTAMP WITH LOCAL TIME ZONE
            else                                                dbms_sql.define_column(curid, i, cast(null as varchar2), 4000);
        end case; 
    end loop;
    fdb := dbms_sql.execute (curid);
    while (dbms_sql.fetch_rows(curid) > 0) loop 
        for j in 1..v_cnt 
        loop
            case
                when v_tab(j).col_type in (1, 96, 11, 208)  then    dbms_sql.column_value(curid, j, rec.v2_column);
                when v_tab(j).col_type = 2                  then    dbms_sql.column_value(curid, j, rec.num_column);
                when v_tab(j).col_type = 12                 then    dbms_sql.column_value(curid, j, rec.date_column);
                when v_tab(j).col_type = 112                then    dbms_sql.column_value(curid, j, rec.clob_column);              
                when v_tab(j).col_type = 180                then    dbms_sql.column_value(curid, j, rec.ts_column);
                when v_tab(j).col_type = 181                then    dbms_sql.column_value(curid, j, rec.tstz_column);
                when v_tab(j).col_type = 182                then    dbms_sql.column_value(curid, j, rec.iym_column);
                when v_tab(j).col_type = 183                then    dbms_sql.column_value(curid, j, rec.ids_column);
                when v_tab(j).col_type = 231                then    dbms_sql.column_value(curid, j, rec.tsltz_column);
                else                                                dbms_sql.column_value(curid, j, rec.v2_column);
            end case;
            v_row := v_row || 
            case
                when rec.v2_column      is not null then rec.v2_column 
                when rec.num_column     is not null then to_char(rec.num_column)
                when rec.clob_column    is not null then rec.clob_column
                when rec.date_column    is not null then to_char(rec.date_column)
                when rec.ts_column      is not null then to_char(rec.ts_column)
                when rec.tstz_column    is not null then to_char(rec.tstz_column)
                when rec.iym_column     is not null then to_char(rec.iym_column)
                when rec.ids_column     is not null then to_char(rec.ids_column)
                when rec.tsltz_column   is not null then to_char(rec.tsltz_column)
            end ||' ';
            rec := null;
        end loop;
        dbms_output.put_line(v_row);
        v_row := null;
    end loop;
    dbms_sql.close_cursor(curid);
end;



