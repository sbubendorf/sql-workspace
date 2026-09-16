-- --------------------------------------------------------------------------------
--  Abfrage Logging Levels
-- --------------------------------------------------------------------------------

select   ld.USERBK_NR,
         ld.SQL_OBJ_NAME,
         ld.LOG_LEVEL,
         case ld.LOG_LEVEL
            when 8	then 'TRACE'
            when 7 then 'DEBUG'
            when 6 then 'INFO'
            when 5 then 'WARNING'
            when 4 then 'ERROR'
         end || 
         -- Markiere Ausnahmen zum Standard "ERROR" mit Pfeil, um sie leichter zu erkennen
         case when ld.LOG_LEVEL = 4 then '' else ' <----' end 
                                 as LOG_LEVEL_NAME
from     SR_LOG_DEFI    ld
where    ld.USERBK_NR = 949
order by ld.USERBK_NR, 
         ld.SQL_OBJ_NAME
;

-- Show all objects with log level "Debug" -------------
select   ld.sql_obj_name
from     sr_log_defi ld
where    ld.USERBK_NR = 949
  and    ld.LOG_LEVEL = 7
;

select   distinct listagg(distinct ld.sql_obj_name, ' / ' on overflow truncate with count) within group (order by ld.sql_obj_name) over (partition by ld.userbk_nr, ld.log_level) as sql_obj_name_list
from     sr_log_defi ld
where    ld.USERBK_NR = 949
  and    ld.LOG_LEVEL = 7
;

-- --------------------------------------------------------------------------------
--  Setzen von Logging Levels
-- --------------------------------------------------------------------------------

-- Aktuelle Session:

-- Alle B2-Packages auf DEBUG setzen
begin
   SRQLOG00.setup(P_what => 'B2%=DEBUG');
end;
/

-- Alternativ: Nur ein spezifisches Package
begin
   SRQLOG00.setup(P_what => 'B2QDISP0=DEBUG');
   commit;
end;
/

-- Mehrere Packages auf einmal (kommagetrennt)
declare
   G_LoginReturn     varchar2(30 char); --Variabel für den Return-Wert der Login-Funktion
begin
   G_LoginReturn := f2qlogin.F_SetUser('MD1AT', 'berlin08', 949);
   if G_LoginReturn != 'OK' then   
      dbms_output.put_line('Login fehlgeschlagen: ' || G_LoginReturn);
      return;
   end if;
   dbms_output.put_line('Login erfolgreich!');
   --
   SRQLOG00.setup(P_what => 'B2QF_BL_ORDER=ERROR,B2QF_DL_ORDER=ERROR');
   commit;
end;
/

-- Dauerhaftes und globales Setzen der Logging-Levels:
update   sr_log_defi    ld
set      ld.LOG_LEVEL = 7
where    ld.USERBK_NR = 949
   and   ld.SQL_OBJ_NAME = 'B2%'
;

commit;


-- --------------------------------------------------------------------------------
--  Neues Logging-System
-- --------------------------------------------------------------------------------

DECLARE
   L_Logger SRYI_LOGGER_MAIN_1;
BEGIN
  -- Push2Queue erzwingen: Level-Check wird übersprungen
  L_Logger := SRQI_LOGGER_1.F_CreateLogEntry(P_Push2Queue => true);
  L_Logger.PushDebug('Wird immer geschrieben, egal welcher Level');
  L_Logger.PushInfo('Auch diese');
  ROLLBACK;
END;
/


-- Check log entries ---------------------------------------
SELECT   * 
FROM     SRTS_LOG 
ORDER BY log_ts DESC;

-- Show session log parameters ---------------------------------------
SELECT   * 
FROM     SRWI_SESSION_LOG_PARAMS_1
;



