/* -----------------------------------------------------------------
    File    : i1b-3140-performance-delete-b2-auf.sql
    Purpose : Analyse / Löschung alter Datensätze aus F2LDATP0.B2_AUF
    Author  : <Dein Name>
    Date    : 2026-06-02
    Revision: $Revision$
    Notes   : enthält Test-SELECTs, Count-Abfrage und DELETE-Logik mit ROLLBACK
 ------------------------------------------------------------------ */

SELECT  1, to_char(123, 'FM0000000000000000000000') FROM    dual union
SELECT  2, to_char(123, 'fm0000000000000000000000') FROM    dual union
SELECT  3, to_char(123, '0000000000000000000000') FROM    dual
;

SELECT  F2QLOGIN.F_SetUser('MD1AT', 'berlin08', 949) from dual;


SELECT  to_char(count(*), '999G999G990') AS anzahl
FROM    F2LDATP0.B2_AUF     auf
WHERE   1=1
    and auf.USERBK_NR = f2qlogin.f_ub
    and auf.CREATE_DT < to_date('2026-01-01', 'YYYY-MM-DD')
    -- and auf.OBJ_STAT_CD not in ('800')
    -- and auf.BO_AUF_TYP_CD not in ('E')
;

-- 165'864

SELECT  *
FROM    F2LDATP0.B2_AUF     auf
WHERE   auf.USERBK_NR = f2qlogin.f_ub
    and auf.CREATE_DT < to_date('2026-01-01', 'YYYY-MM-DD')
    -- and auf.OBJ_STAT_CD not in ('800')
    -- and auf.BO_AUF_TYP_CD not in ('E')
ORDER   BY  auf.CREATE_DT DESC
;

rollback;

SET SERVEROUTPUT ON

-- Create profiling tables --------------------------------
BEGIN
    DBMS_HPROF.CREATE_TABLES(force_it => true);
END;
/


declare
    G_HProfDirectory    VARCHAR2(20 CHAR) := 'MANIFEST_DIR';            -- Directory-Objekt für HPROF-Ausgabe
    G_HProfFilename     VARCHAR2(50 CHAR) := 'b2_auf_delete_perf_' || to_char(sysdate,'YYYYMMDDHH24MISS') || '.trc';  -- Dateiname für HPROF-Ausgabe
    G_HProfEnabled      BOOLEAN := FALSE; -- Flag, um HPROF-Teil des Codes zu aktivieren/deaktivieren
    --
    G_LoginReturn       VARCHAR2(30 CHAR); --Variabel für den Return-Wert der Login-Funktion
    G_EvtStartTime      TIMESTAMP; --Variable für die Startzeit der Operation
    G_EvtEndTime        TIMESTAMP; --Variable für die Endzeit der Operation
    G_Result            INTEGER; --Variable für den Return-Wert der Löschungs-Funktion
begin
    G_LoginReturn := F2QLOGIN.F_SetUser('MD1AT', 'berlin08', 949);
    if G_LoginReturn != 'OK' then   
        DBMS_OUTPUT.PUT_LINE('Login fehlgeschlagen: ' || G_LoginReturn);
        return;
    end if;
    DBMS_OUTPUT.PUT_LINE('Login erfolgreich!');
    G_Result := b2qf_bl_annu_auftrag.F_SetLoeschungErlaubt(B2QCNST0.K_TRUE); -- Löschung erlauben für alle Auftrags-Typen und -Stati
    if G_HProfEnabled then
        -- Start profiling and write raw data to a file
        DBMS_HPROF.START_PROFILING(
            location => G_HProfDirectory,   -- Must match directory object name
            filename => G_HProfFilename
        );
        DBMS_OUTPUT.PUT_LINE('Profiling started into file ' || G_HProfFilename);
    end if;
    --
    G_EvtStartTime := SYSTIMESTAMP;
    DELETE F2LDATP0.B2_AUF auf
    WHERE   1=1
        and auf.USERBK_NR = f2qlogin.f_ub
        and auf.CREATE_DT < to_date('2026-01-01', 'YYYY-MM-DD')
        -- and auf.OBJ_STAT_CD not in ('800')
        -- and auf.BO_AUF_TYP_CD not in ('E')
    ;
    G_EvtEndTime := SYSTIMESTAMP;
    --
    -- Stop profiling
    if G_HProfEnabled then
        DBMS_HPROF.STOP_PROFILING;
    end if;
    DBMS_OUTPUT.PUT_LINE('Number of rows deleted: ' || SQL%ROWCOUNT);
    DBMS_OUTPUT.PUT_LINE('Execution time: ' || (G_EvtEndTime - G_EvtStartTime));
    rollback;
exception
    when others then
        if G_HProfEnabled then
            DBMS_HPROF.STOP_PROFILING;
        end if;
        DBMS_OUTPUT.PUT_LINE('sqlerrm = '|| sqlerrm);
        SRQMESS0.DumpMessages(); --Finnova spezifisches Log ausgeben
end;
/


-- Generate Profiling HTML Report --------------------------------
SELECT DBMS_HPROF.ANALYZE(
           location => 'MANIFEST_DIR',
           filename => 'b2_auf_delete_perf_20260608113343.trc'
       )
FROM dual;




SELECT  trigger_name, 
        --trigger_type, 
        --triggering_event, 
        status
FROM    all_triggers
WHERE   table_name = 'B2_AUF'
ORDER   BY trigger_name;

ALTER TRIGGER b2_auf_ar DISABLE;
ALTER TRIGGER b2_auf_br DISABLE;
ALTER TRIGGER b2_auf_as DISABLE;
ALTER TRIGGER b2_auf_bs DISABLE;

ALTER TRIGGER b2_auf_ar ENABLE;
ALTER TRIGGER b2_auf_br ENABLE;
ALTER TRIGGER b2_auf_as ENABLE;
ALTER TRIGGER b2_auf_bs ENABLE;








/*

3. Test mit Profiling beim ersten Versuch und allen Triggern Enabled am 8.6.2026
--------------------------------------------------------------------------------

Login erfolgreich!
Profiling started into file b2_auf_delete_perf_20260608113343.trc
Number of rows deleted: 165864
Execution time: +000000000 00:09:57.503756000






2. Test auf neuer AWS am 5.6.2026
---------------------------------

- Laufzeit ohne Anpassungen                                     : 00:03:45
        Rerun                                                   : 00:02:58
- Flush                                                         : 00:03:43
        Rerun                                                   : 00:02:53
        Rerun                                                   : 00:02:54
- Flush                                                         : 00:03:48
-- Ab hier Flushing vor jeder Ausführung
- Disable BR-Trigger                                            : 00:00:46      Ohne BR-Trigger noch rund 1/4 der Laufzeit
        Rerun                                                   : 00:00:45
        Rerun                                                   : 00:00:36
        Rerun                                                   : 00:00:37
- Disable AR-Trigger                                            : 00:00:21
        Rerun                                                   : 00:00:11
        Rerun                                                   : 00:00:12
- Mit Profiling und allen Triggern Enabled                      : 00:04:13






B2_AUF_AR	DISABLED
B2_AUF_AS	DISABLED
B2_AUF_BR	DISABLED
B2_AUF_BS	DISABLED
Execution time: 00:00:01.453771000

B2_AUF_AR	ENABLED
B2_AUF_AS	DISABLED
B2_AUF_BR	DISABLED
B2_AUF_BS	DISABLED
Execution time: 00:00:03.639512000

B2_AUF_AR	DISABLED
B2_AUF_AS	DISABLED
B2_AUF_BR	ENABLED
B2_AUF_BS	DISABLED
Execution time: 00:03:15.902550000      <<----- deutlich langsamer, da Trigger BR aktiviert

B2_AUF_AR	DISABLED
B2_AUF_AS	ENABLED
B2_AUF_BR	DISABLED
B2_AUF_BS	DISABLED
Execution time: 00:00:01.091344000

B2_AUF_AR	DISABLED
B2_AUF_AS	DISABLED
B2_AUF_BR	DISABLED
B2_AUF_BS	ENABLED
Execution time: 00:00:01.223653000

Testing with changes made to B2_AUF_BR:
 - Without changes                                                              : 00:03:15.902550000
 - Comment   B2QDISP0.DeleteAllDispAndPreAutonomous (:old.AUF_LNR);             : 00:00:57.917016000
 - Uncomment B2QDISP0.DeleteAllDispAndPreAutonomous (:old.AUF_LNR);             : 00:05:32.627099000
 - Comment   delete OM_AUF_REGU                                                 : 00:03:22.972775000
                                                                                  00:03:20.761934000
 - Uncomment delete OM_AUF_REGU                                                 : 00:03:33.089679000
                                                                                  00:03:28.635014000
 - Commet    delete OM_AUF                                                      : 00:03:15.716246000
                                                                                  00:03:14.409162000
 - Uncommet  delete OM_AUF                                                      : 00:03:22.794897000
 - Comment   B2QDISP0.DeleteAllDispAndPreAutonomous (:old.AUF_LNR);             : 00:00:10.676274000
                                                                                  00:00:15.469338000
                                                                                  00:00:15.170876000
                                                                                  00:00:15.781425000
                                                                                  00:00:14.550291000
 - Uncomment B2QDISP0.DeleteAllDispAndPreAutonomous (:old.AUF_LNR);             : 00:05:53.690810000
 - Use DeleteAllDispAndPre instead of DeleteAllDispAndPreAutonomous             : 00:05:51.412227000
 
 3.6.2026
 
 - Back to previous                                                             : 00:00:15.746651000
                                                                                  00:00:15.906552000
                                                                                  00:00:15.228270000
                                                                                  00:00:15.195658000


Löschungen mit 165'864 Aufträgen

 - Ausgangslage                                                                 : 00:03:59.138506000
 - Without Cursor C_AufKtDisp                                                   : 00:03:20.393916000
 - Without Cursor C_AufKtPre                                                    : 00:02:58.136314000
 - Without Cursor C_AufDpDisp                                                   : 00:02:53.368736000
 - Without Cursor C_AufDpPre                                                    : 00:02:42.016331000





 - 
*/




SELECT owner,
       object_type,
       object_name,
       status
FROM   dba_objects
WHERE  object_name like 'B2QDISP%'
ORDER BY owner, object_type, object_name;


SELECT  *
FROM    V$SQL           sql
WHERE   sql.SQL_ID = 'bjugygfszbdpp'
;


DELETE OM_AUF WHERE AUF_LNR = :B2 AND USERBK_NR = :B1
;


SELECT  *
FROM    OM_AUF                  
;


SELECT  b2auf.AUF_LNR,
        count(*)
FROM    F2LDATP0.B2_AUF                 b2auf
        INNER JOIN  F2LDATP0.OM_AUF     omauf   ON  omauf.AUF_LNR = b2auf.AUF_LNR
WHERE   b2auf.USERBK_NR = f2qlogin.f_ub
    and b2auf.CREATE_DT < to_date('2026-01-01', 'YYYY-MM-DD')
    -- and b2auf.OBJ_STAT_CD not in ('800')
    -- and b2auf.BO_AUF_TYP_CD not in ('E')
group by b2auf.AUF_LNR
;


SELECT  *
FROM    OM_AUF
;



SELECT  count(*)
FROM    OM_AUF              omauf
WHERE   not exists 
        (
            select  null 
            from    b2_auf a 
            where   a.auf_lnr = omauf.auf_lnr 
                and a.userbk_nr = omauf.userbk_nr
        )
    and omauf.om_ber = 'B2'
;

select  b.om_ber,
        b.BEZ_KURZ,
        b.BEZ_MITTEL,
        b.BEZ_LANG
from    om1ber                      b
where   b.USERBK_NR = 949
    and b.SPRACHE_CD = 1
order   by  b.OM_BER
;