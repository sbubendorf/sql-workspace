-- --------------------------------------------------------------------------------
--  Logging Levels
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



