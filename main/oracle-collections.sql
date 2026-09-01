DECLARE
    l_table     ddcstring := ddcstring();
    l_id        varchar2(4000);
    l_count     number;
    cursor c_reader is select * from table(l_table);
BEGIN
    l_table.extend();
    l_table(l_table.LAST) := '11111';
    l_table.extend();
    l_table(l_table.LAST) := '22222';
    l_table.extend();
    l_table(l_table.LAST) := '33333';
    --
    l_count := coalesce(cardinality(l_table), l_table.count, l_table.last, -1);
    DBMS_OUTPUT.PUT_LINE('Number of elements in collection: ' || l_count);
    open c_reader;
    loop
        fetch c_reader into l_id;
        exit when c_reader%NOTFOUND;
        dbms_output.put_line(l_id);
    end loop;
end;
