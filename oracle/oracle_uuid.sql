select  sys_guid()  as guid,
        lower(regexp_replace(rawtohex(sys_guid()), '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5')) as guid_nice
from    dual;                
                


select  new_uuid
from    dual;


create or replace function new_uuid return varchar2 as
    l_seed          binary_integer;
    l_random_num    number(5);
    l_date          varchar2(25);
    l_random        varchar2(4);
    l_ip_address    varchar2(12);
    l_uuid          varchar2(36);
begin
    l_seed := to_number(to_char(sysdate,'YYYYDDMMSS'));
    dbms_random.initialize (val => l_seed);
    l_random_num := trunc(dbms_random.value(low => 1, high => 65535));
    dbms_random.terminate;
    --
    l_date       := conversion_api.to_hex(to_number(to_char(systimestamp,'FFSSMIHH24DDMMYYYY')));
    l_random     := rpad(conversion_api.to_hex(l_random_num), 4, '0');
    l_ip_address := conversion_api.to_hex(to_number(replace(nvl(sys_context('USERENV','IP_ADDRESS'), '123.123.123.123'), '.', '')));
    --
    l_uuid :=
        substr(l_date, 1, 8)                     || '-' ||
        substr(l_date, 9, 4)                     || '-' ||
        substr(l_date, 13, 4)                    || '-' ||
        rpad(substr(l_date, 17), 4, '0')         || '-' ||
        rpad(l_random || l_ip_address, 12, '0');
    --
    return lower(l_uuid);
end;



create or replace package conversion_api as
    function to_base(p_dec   in  number,
                     p_base  in  number) return varchar2;
    function to_dec (p_str        in  varchar2,
                     p_from_base  in  number default 16) return number;
    function to_hex(p_dec  in  number) return varchar2;
    function to_bin(p_dec  in  number) return varchar2;
    function to_oct(p_dec  in  number) return varchar2;
end conversion_api;

create or replace package body conversion_api as
    function to_base(p_dec   in  number,
                     p_base  in  number) return varchar2 is
        l_str	varchar2(255) default null;
        l_num	number	      default p_dec;
        l_hex	varchar2(16)  default '0123456789ABCDEF';
    begin
        if (trunc(p_dec) <> p_dec or p_dec < 0) then
            raise program_error;
        end if;
        loop
            l_str := substr(l_hex, mod(l_num,p_base)+1, 1) || l_str;
            l_num := trunc(l_num/p_base);
            exit when (l_num = 0);
        end loop;
        return l_str;
    end to_base;
    -- ----------------------------------------------------------------------------
    function to_dec (p_str        in  varchar2,
                     p_from_base  in  number default 16) return number is
        l_num   number       default 0;
        l_hex   varchar2(16) default '0123456789ABCDEF';
    begin
        for i in 1 .. length(p_str) loop
            l_num := l_num * p_from_base + instr(l_hex,upper(substr(p_str,i,1)))-1;
        end loop;
        return l_num;
    end to_dec;
    -- ----------------------------------------------------------------------------
    function to_hex(p_dec  in  number) return varchar2 is
    begin
        return to_base(p_dec, 16);
    end to_hex;
    -- ----------------------------------------------------------------------------
    function to_bin(p_dec  in  number) return varchar2 is
    begin
        return to_base(p_dec, 2);
    end to_bin;
    -- ----------------------------------------------------------------------------
    function to_oct(p_dec  in  number) return varchar2 is
    begin
        return to_base(p_dec, 8);
    end to_oct;
end conversion_api;

