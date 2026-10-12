create or replace package b2helper
as
   function resolve(
      P_FieldName       in    varchar2,
      P_FieldValue      in    varchar2
   ) return varchar2;
end b2helper;
/

create or replace package body b2helper
as
   function resolve(
      P_FieldName       in    varchar2,
      P_FieldValue      in    varchar2
   ) return varchar2
   is
      L_TableName          varchar2(100 char);
      L_KeyColumn          varchar2(100 char);
   begin
      case P_FieldName
         when 'TableName' then
            L_TableName := P_FieldValue;
         when 'KeyColumn' then
            L_KeyColumn := P_FieldValue;
      end case;
      dbms_output.put_line('FieldName=' || P_FieldName || ', FieldValue=' || P_FieldValue);
      return 'FieldName=' || P_FieldName || ', FieldValue=' || P_FieldValue;
   end resolve;
end b2helper;
/


select b2helper.resolve('FieldNameExample', 'FieldValueExample') from dual;





select   *
from     all_source        s
where    1=1
   and   s.owner like 'F2%'
   and   upper(s.text) like '%%'
   and   upper(s.text) like '%%'
;