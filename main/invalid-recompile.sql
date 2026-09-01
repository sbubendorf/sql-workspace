-- --------------------------------------------------------------------------------
--> Checking and handling invalid objects in the database
-->
-->    --->> Login as SYSADM <<---
-->
--> Source: https://www.oraclerecipes.com/monitoring/find-invalid-objects-and-recompile
-- --------------------------------------------------------------------------------

-- Number of invalids per schema ---------------------------------
select   owner,
         count(*) as invalid_count
from dba_objects
where status = 'INVALID'
group by owner
order by invalid_count;

-- Show all invalid objects for a specific schema ----------------------------
select   owner, 
         object_type, 
         object_name, 
         status
from     dba_objects
where    status = 'INVALID'
   and   owner = 'F2LDATP0'
order by owner, 
         object_name,
         object_type
; 


ALTER PACKAGE B2QF_SL_TRADING COMPILE;

ALTER PACKAGE B2QF_SL_TRADING COMPILE BODY;


-- Recompile all invalid objects ---------------------------------------
EXEC UTL_RECOMP.recomp_serial();


-- Recompile all invalid objects for a specific schema with error reporting ---------------------------------------
begin
   for obj in (
      select   object_type, 
               object_name
      from     dba_objects
      where    status = 'INVALID'
         and   owner = 'F2LDATP0'
      order by decode(object_type, 
                  'PACKAGE',        1, 
                  'PACKAGE BODY',   2,
                  'FUNCTION',       3, 
                  'PROCEDURE',      4, 
                  'VIEW',           5,
                  'TRIGGER',        6, 
                  9
               )
   ) 
   loop
      begin
         if obj.object_type = 'PACKAGE BODY' THEN
            execute immediate 'ALTER PACKAGE ' || obj.object_name || ' COMPILE BODY';
         else
            execute IMMEDIATE 'ALTER ' || obj.object_type || ' ' || obj.object_name || ' COMPILE';
         end if;
         dbms_output.put_line('OK: ' || obj.object_type || ' ' || obj.object_name);
      exception
         when others then
            dbms_output.put_line('FAIL: ' || obj.object_type || ' ' || obj.object_name || ' — ' || SQLERRM);
      end;
   end loop;
end;
