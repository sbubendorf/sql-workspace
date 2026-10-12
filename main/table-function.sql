declare 
   coll           B2QF_ORDER_TYPE.C_KT_ART_NR := B2QF_ORDER_TYPE.C_KT_ART_NR();
   la             VARCHAR2(4000);
begin
   coll.extend; coll(coll.last) := 100;
   coll.extend; coll(coll.last) := 101;
   coll.extend; coll(coll.last) := 102;
   coll.extend; coll(coll.last) := 102;
   coll.extend; coll(coll.last) := 102;
   coll.extend; coll(coll.last) := 103;
   coll.extend; coll(coll.last) := 103;
   coll.extend; coll(coll.last) := 104;
   select   listagg(distinct column_value,',' on overflow truncate '...') within group (order by rownum) 
   into     la 
   from     table(coll);
   dbms_output.put_line(la);
end;
