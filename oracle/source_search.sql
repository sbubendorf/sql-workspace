-- -----------------------------------------------------------------------------
--  Search in Source-Codes
-- -----------------------------------------------------------------------------

declare
    lv_search   varchar2(100) := lower('portfolio');
    is_search_in_packages_allowed   number := 1;
    is_search_in_views_allowed      number := 1;
    is_search_in_triggers_allowed   number := 1;
    --
    ln_count    number;
    ln_occurs   number;
    cursor cur_src(pv_search in varchar2) is
        select  *
        from    all_source t
        where   lower(t.text) like '%' || pv_search || '%';
    lrow_src cur_src%rowtype;
    cursor cur_views is
        select  * 
        from    all_views t;
    lrow_views cur_views%rowtype;
    lv_line     varchar2(4000);
    cursor cur_trg is
        select  * 
        from    all_triggers t;
    lrow_trg cur_trg%rowtype;
begin
    dbms_output.put_line('------------------------------------------------');
    dbms_output.put_line('Search for : ' || lv_search);
    dbms_output.put_line('------------------------------------------------');
    ------------search in all_source ----------------------------
    if is_search_in_packages_allowed = 1 then
        dbms_output.put_line('Packages / Procedures:');
        open cur_src(lv_search);
        loop
            fetch cur_src into lrow_src;
            exit when cur_src%notfound;
            dbms_output.put_line('  - ' || lrow_src.owner || '.' || lrow_src.name || ' : ' || lrow_src.line);
        end loop;
        ln_count := cur_src%rowcount;
        dbms_output.put_line('');
        dbms_output.put_line('    ' || ln_count || ' record(s) found in ALL_SOURCE table.');
        close cur_src;
     end if;
    --         
    ------------search in all_views----------------------------
    if is_search_in_views_allowed = 1 then
        dbms_output.put_line('Views:');
        ln_count := 0;
        open cur_views;
        loop
            fetch cur_views into lrow_views;
            exit when cur_views%notfound;
            -- convert long to varchar2
            lv_line := substr(lrow_views.text, 1, 4000);
            if lv_line like '%' || lv_search || '%' then
                dbms_output.put_line('  - ' || lrow_views.owner || '.' || lrow_views.view_name);
                ln_count := ln_count + 1;
            end if;
        end loop;
        dbms_output.put_line('    ' || ln_count || ' record(s) found in ALL_VIEWS table.');
        close cur_views;
    end if;
    ------------search in all_triggers ----------------------------
     if is_search_in_triggers_allowed = 1 then
        dbms_output.put_line('Triggers:');
        ln_count := 0;
        open cur_trg;
        loop
            fetch cur_trg into lrow_trg;
            exit when cur_trg%notfound;
            lv_line := substr(lrow_trg.description,1,4000);
            if lv_line like '%' || lv_search || '%'
            then
                dbms_output.put('  - ' || lrow_trg.owner || '.' || lrow_trg.trigger_name);
                ln_count := ln_count + 1;
            end if;
        end loop;
        dbms_output.put_line('    ' || ln_count || ' record(s) found in all_triggers table.');
        close cur_trg;
    end if;
end;


select  *
from    all_source