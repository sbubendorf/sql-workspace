-- I1EDB-2003 / INC533700: read-only test data for special denomination.
-- Run as a Finnova user with access to the bank's B2 data (e.g. in SQL*Plus/SQLcl).
-- For a positive case choose a trade with several account types all assigned to
-- KT_ART group 5339/10; for a negative case choose one with an unassigned type.
-- In the Backoffice price allocation of a non-final trading group, compare the
-- resulting lot size against WV/SPEZ_DENOMIN (positive) or the instrument's
-- normal lot size (negative). B2/SPEZ_DENOMIN_ON must be enabled for the bank.
-- VL_EINH_CD is the order unit, NOT the lot size. This script only identifies
-- suitable trades; it does not perform a price allocation or assert its result.


prompt === Mixed account types: positive and negative test candidates ===
select   abr.b2_trade_gnr,
         count(distinct auf.auf_lnr) as num_auf,
         count(distinct kts.kt_art_nr) as num_kt_art,
         count(distinct auf.vl_ref_lnr) as num_vl_ref,
         count(distinct az.kt_art_nr) as num_in_gruppe,
         case when count(distinct kts.kt_art_nr) = count(distinct az.kt_art_nr)
            then 'POSITIV: alle in 5339/10'
            else 'NEGATIV: nicht alle in 5339/10' 
         end as testfall
from     b2_abr abr
         inner join b2_auf          auf   on    auf.auf_lnr = abr.auf_lnr
                                          and   auf.userbk_nr = abr.userbk_nr
         inner join kt_stamm        kts   on    kts.kt_lnr = auf.kt_lnr
                                          and   kts.userbk_nr = auf.userbk_nr
         left join (
               select   distinct 
                        userbk_nr, 
                        kt_art_nr
               from     kt_art_zuo
               where    grp_art = 5339 
                  and   gnr = 10
         )                          az    on    az.userbk_nr = kts.userbk_nr 
                                          and   az.kt_art_nr = kts.kt_art_nr
where    abr.userbk_nr = 949
   and   abr.b2_auf_art_cd in (10, 110)
   and   abr.b2_trade_gnr is not null
group by abr.b2_trade_gnr
having   count(distinct kts.kt_art_nr) > 1
order by case when count(distinct kts.kt_art_nr) = count(distinct az.kt_art_nr)
          then 0 else 1 end,
       num_kt_art desc, num_auf desc
fetch first 100 rows only;

accept trade_gnr number prompt 'B2_TRADE_GNR aus Kandidatenliste: '

prompt === Orders and observed units per account type ===
select   abr.b2_trade_gnr,
         auf.auf_lnr,
         abr.b2_auf_art_cd,
         kts.kt_lnr,
         kts.kt_art_nr,
         art.bez_lang as kt_art_bez,
          case when az.kt_art_nr is not null then 'JA' else 'NEIN' end as in_gruppe_5339_10,
         auf.vl_ref_lnr,
         auf.vl_einh_cd,
         auf.menge_auf
from     b2_abr abr
         inner join b2_auf auf on auf.auf_lnr = abr.auf_lnr
                              and auf.userbk_nr = abr.userbk_nr
         inner join kt_stamm kts on kts.kt_lnr = auf.kt_lnr
                                and kts.userbk_nr = auf.userbk_nr
             left join (select distinct userbk_nr, kt_art_nr
                              from kt_art_zuo
                              where grp_art = 5339 and gnr = 10) az
                on az.userbk_nr = kts.userbk_nr and az.kt_art_nr = kts.kt_art_nr
         left join kt1art art on art.kt_art_nr = kts.kt_art_nr
                             and art.userbk_nr = kts.userbk_nr
                             and art.sprache_cd = 1
where    abr.userbk_nr = 949
   and   abr.b2_trade_gnr = 63990770644026
   and   abr.b2_auf_art_cd in (10, 110)
order by kts.kt_art_nr, auf.auf_lnr;

prompt === Test data classification (not a functional PASS/FAIL) ===
select   count(distinct kts.kt_art_nr) as num_kt_art,
       count(distinct az.kt_art_nr) as num_in_gruppe,
       case when count(distinct kts.kt_art_nr) < 2
          then 'KEIN MEHRFACHFALL'
          when count(distinct kts.kt_art_nr) = count(distinct az.kt_art_nr)
          then 'POSITIV: spezielle Stueckelung pruefen'
          else 'NEGATIV: normale Stueckelung pruefen'
       end as test_data_status
from     b2_abr abr
         inner join b2_auf auf on auf.auf_lnr = abr.auf_lnr
                              and auf.userbk_nr = abr.userbk_nr
         inner join kt_stamm kts on kts.kt_lnr = auf.kt_lnr
                                and kts.userbk_nr = auf.userbk_nr
             left join (select distinct userbk_nr, kt_art_nr
                              from kt_art_zuo
                              where grp_art = 5339 and gnr = 10) az
                on az.userbk_nr = kts.userbk_nr and az.kt_art_nr = kts.kt_art_nr
where    abr.userbk_nr = 949
   and   abr.b2_trade_gnr = 63990770644026
   and   abr.b2_auf_art_cd in (10, 110);






select   abr.b2_trade_gnr,
         count(*)    num_auf,
         count(distinct kts.kt_art_nr) as num_kt_art
from     b2_abr                  abr
         inner join  b2_auf      auf   on    auf.auf_lnr = abr.auf_lnr
                                       and   auf.userbk_nr = abr.userbk_nr
         inner join  ktwi_stamm_nods_3 kts   on kts.kt_lnr = auf.kt_lnr
where    1=1
   and   abr.b2_auf_art_cd in (10, 110)   -- nur Depotart von den Kundendepots lesen
   and   abr.userbk_nr = 949
group by abr.b2_trade_gnr
order by num_auf desc
;


select   abr.b2_trade_gnr,
         count(*)    num_auf,
         count(distinct kts.kt_art_nr) as num_kt_art,
         count(distinct SRQUTIL0.F_GRPGetGnr(null, null, 5339, kts.kt_art_nr)) as num_grp
from     b2_abr                  abr
         inner join  b2_auf      auf   on    auf.auf_lnr = abr.auf_lnr
                                       and   auf.userbk_nr = abr.userbk_nr
         inner join  ktwi_stamm_nods_3 kts   on kts.kt_lnr = auf.kt_lnr
where    1=1
   and   abr.b2_auf_art_cd in (10, 110)   -- nur Depotart von den Kundendepots lesen
   and   abr.userbk_nr = 949
group by abr.b2_trade_gnr
order by num_auf desc
;

select   abr.b2_trade_gnr,
         auf.auf_lnr,
         auf.auf_id,
         auf.obj_stat_cd,
         kts.kt_art_nr,
         SRQUTIL0.F_GRPGetGnr(null, null, 5339, kts.kt_art_nr) as grp
from     b2_abr                  abr
         inner join  b2_auf      auf   on    auf.auf_lnr = abr.auf_lnr
                                       and   auf.userbk_nr = abr.userbk_nr
         inner join  ktwi_stamm_nods_3 kts   on kts.kt_lnr = auf.kt_lnr
where    1=1
   and   abr.b2_auf_art_cd in (10, 110)   -- nur Depotart von den Kundendepots lesen
   and   abr.userbk_nr = 949
   and   abr.b2_trade_gnr = 78126266627569
order by auf.auf_lnr;


select   *
from     OM1OBJ_TYP_STAT         sta
where    sta.userbk_nr = 949
   and   sta.sprache_cd = 1
order by sta.obj_typ_stat_cd
;


select   *
from     al_div      div
where    div.userbk_nr = 949
   and   div.key_cd = '800'
order by div.key_cd
;



declare
   G_HProfDirectory  varchar2(20 char) := 'MANIFEST_DIR'; -- Directory-Objekt für HPROF-Ausgabe
   G_HProfFilename   varchar2(50 char) := 'b2_test_' || to_char(sysdate,'YYYYMMDDHH24MISS') || '.trc';  -- Dateiname für HPROF-Ausgabe
   G_HProfEnabled    boolean := FALSE; -- Flag, um das Heap-Profiling für diesen Code zu aktivieren/deaktivieren
   --
   G_LogLevel        integer := ALQMSG00.F_GetLogLevel('B2%'); -- Log-Level für die Protokollierung
   G_LoginReturn     varchar2(30 char); --Variabel für den Return-Wert der Login-Funktion
   G_EvtStartTime    timestamp; --Variable für die Startzeit der Operation
   G_EvtEndTime      timestamp; --Variable für die Endzeit der Operation
   --
   L_ZuteilungCd     integer;
begin
   G_LoginReturn := F2QLOGIN.F_SetUser('MD1AT', 'berlin08', 949);
   if G_LoginReturn != 'OK' then   
      DBMS_OUTPUT.PUT_LINE('Login fehlgeschlagen: ' || G_LoginReturn);
      return;
   end if;
   DBMS_OUTPUT.PUT_LINE('Login erfolgreich!');
   dbms_output.put_line('LogLevel B2: ' || G_LogLevel || ' - ' || case G_LogLevel when 8 then 'TRACE' when 7 then 'DEBUG' when 6 then 'INFO' when 5 then 'WARNING' when 4 then 'ERROR' end);
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
   -- --------------------------------------------------------------------------------
   --                      Start of your test code
   -- --------------------------------------------------------------------------------
   b2qapri0.P_PreisZuteilung (
          P_B2TradeGnr        => 63990770644026    -- B2_TRADE.B2_TRADE_GNR%type
         ,P_FromCd            => 3                 -- integer 1=GUI, 2=FIX, 3=WF, 4=End of day, 5=extern
         ,P_NoChange          => 1                 -- number 1=Kursstellung unterdrücken, sonst=Kursstellen, falls nötig
         ,P_CalcTarifCd       => 1                 -- integer default 1
         ,P_ZuteilungCd       => L_ZuteilungCd     -- out   integer
         ,P_CalcTarifOnlyCd   => 0                 -- integer default 1
         ,P_FixTaskTypCd      => null              -- in BG_FIX_TASK_TYP.bg_fix_task_typ_cd%type default null
   );
   dbms_output.put_line('Zuteilung: ' || L_ZuteilungCd);
   -- --------------------------------------------------------------------------------
   --                       End of your test code
   -- --------------------------------------------------------------------------------
   G_EvtEndTime := SYSTIMESTAMP;
   --
   -- Stop profiling
   if G_HProfEnabled then
      DBMS_HPROF.STOP_PROFILING;
   end if;
   DBMS_OUTPUT.PUT_LINE('Execution time: ' || (G_EvtEndTime - G_EvtStartTime));
   SRQMESS0.DumpMessages();     -- Dump out log messages
   --commit;
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



