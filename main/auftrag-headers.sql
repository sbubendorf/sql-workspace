declare
   G_HProfDirectory  varchar2(20 char) := 'MANIFEST_DIR';            -- Directory-Objekt für HPROF-Ausgabe
   G_HProfFilename   varchar2(50 char) := 'b2_test_' || to_char(sysdate,'YYYYMMDDHH24MISS') || '.trc';  -- Dateiname für HPROF-Ausgabe
   G_HProfEnabled    boolean := FALSE; -- Flag, um HPROF-Teil des Codes zu aktivieren/deaktivieren
   --
   G_LoginReturn     varchar2(30 char); --Variabel für den Return-Wert der Login-Funktion
   G_EvtStartTime    timestamp; --Variable für die Startzeit der Operation
   G_EvtEndTime      timestamp; --Variable für die Endzeit der Operation
   G_LogLevel        integer := ALQMSG00.F_GetLogLevel('B2%'); -- Log-Level für die Protokollierung
   --
   L_FilterIn        B2YI_AUFTRAGHEADER_FILTER_1 := B2YI_AUFTRAGHEADER_FILTER_1();
   L_FilterBL        B2YF_BL_ORDER_FILTER := B2YF_BL_ORDER_FILTER();
   L_Result          B2YI_AUFTRAGHEADER_RESPONSE_1;
   L_ValorRefs       SRCI_I22_1 := SRCI_I22_1();
   L_OrderStats      SRCI_I3_1 := SRCI_I3_1();
   L_AufEmpfCds      SRCI_C2_1 := SRCI_C2_1();
   L_TlPtnRefs       SRYI_I22_1 := SRYI_I22_1();
   --
   L_PageCursorRet   B2QF_BL_ORDER.T_PAGE_CURSOR_RET       := B2QF_BL_ORDER.T_PAGE_CURSOR_RET();
   --
   procedure P_ReadHeaders(P_TestFilter in B2YI_AUFTRAGHEADER_FILTER_1) is
      L_CountHeaders     integer := 0;
      L_CountPages       integer := 0;
      L_CountText        integer := 0;
      L_RunNr            integer := 0;
      L_RunTime          timestamp := systimestamp;
      L_Filter           B2YI_AUFTRAGHEADER_FILTER_1 := P_TestFilter;
      L_FilterList       varchar2(4000 char);
      L_PageStartTime    timestamp; --Variable für die Startzeit der Operation
   begin
      dbms_output.put_line(rpad('>', 100, '-'));
      dbms_output.put_line('Read headers with the following filter:');
      dbms_output.put_line(' - PAGING_SIZE         :' || P_TestFilter.PAGING_SIZE.F_ToString());
      dbms_output.put_line(' - VL_REF_LNR          :' || ALQI_LOGGING_UTIL_1.F_ToString(P_SrCiI22 => P_TestFilter.VL_REF_LNR));
      dbms_output.put_line(' - TL_PTN_LNR          :' || case when P_TestFilter.TL_PTN_LNR is null then 'NULL' else P_TestFilter.TL_PTN_LNR.F_ToString() end);
      dbms_output.put_line(' - OBJ_STAT_CD         :' || ALQI_LOGGING_UTIL_1.F_ToString(P_SrCiI3 => P_TestFilter.OBJ_STAT_CD));
      select listagg(key_cd, ' / ') within group (order by key_cd) into L_FilterList from table(P_TestFilter.AUF_EMPF_CD);
      dbms_output.put_line(' - AUF_EMPF_CD         :Count: ' || coalesce(cardinality(P_TestFilter.AUF_EMPF_CD),0) || ' -- ' || L_FilterList);
      dbms_output.put_line(' - BO_PLATZ_LNR        :' || ALQI_LOGGING_UTIL_1.F_ToString(P_SrCiI22 => P_TestFilter.BO_PLATZ_LNR));
      dbms_output.put_line(' - HWRG_LNR            :' || ALQI_LOGGING_UTIL_1.F_ToString(P_SrCiI22 => P_TestFilter.HWRG_LNR));
      dbms_output.put_line(' - VALID_VON_DT_FROM   :' || P_TestFilter.VALID_VON_DT_FROM);
      dbms_output.put_line(' - VALID_VON_DT_TO     :' || P_TestFilter.VALID_VON_DT_TO);
      dbms_output.put_line(' - VALID_BIS_DT_FROM   :' || P_TestFilter.VALID_BIS_DT_FROM);
      dbms_output.put_line(' - VALID_BIS_DT_TO     :' || P_TestFilter.VALID_BIS_DT_TO);
      -- Start reading pages of order headers
      loop
         select coalesce(max(run_nr),0) + 1 into L_RunNr from b2_sibu_auf_lnr;
         L_PageStartTime := SYSTIMESTAMP;
         L_Result := b2qi_trading_1.F_ReadBoersenauftragHeaders(P_Filter => L_Filter);
         L_CountPages := L_CountPages + 1;
         DBMS_OUTPUT.PUT_LINE('Page #' || L_CountPages || ' with ' || L_Result.AUFTRAGHEADER_LIST.count || ' headers returned in ' || trim(to_char(PFQH1000.F_StopTimer(P_StartTime => L_PageStartTime, P_Format => 's'),'999G999GB990D000000')) || ' seconds');
         <<header_loop>>
         for i in 1 .. L_Result.AUFTRAGHEADER_LIST.count loop
         -- for i in 1 .. 5 loop
            L_CountHeaders := L_CountHeaders + 1;
            -- DBMS_OUTPUT.PUT_LINE('   - ' || to_char(L_CountHeaders,'000G000') || ': ' || L_Result.AUFTRAGHEADER_LIST(i).F_ToString());
            -- if cardinality(L_Result.AUFTRAGHEADER_LIST(i).OM_TEXTE) > 0 then
            --    for j in 1 .. cardinality(L_Result.AUFTRAGHEADER_LIST(i).OM_TEXTE) loop
            --       DBMS_OUTPUT.PUT_LINE('      - ' || L_Result.AUFTRAGHEADER_LIST(i).OM_TEXTE(j).TEXT_REC);
            --    end loop;
            -- end if;
            --dbms_output.put_line(L_Result.AUFTRAGHEADER_LIST(i).AUF_LNR);
            insert into b2_sibu_auf_lnr (run_nr, run_time, auf_lnr) values (L_RunNr, L_RunTime, L_Result.AUFTRAGHEADER_LIST(i).AUF_LNR);
            L_CountText := L_CountText + coalesce(cardinality(L_Result.AUFTRAGHEADER_LIST(i).OM_TEXTE), 0);
         end loop header_loop;
         exit when L_Result.PAGING_CURSOR is null;
         DBMS_OUTPUT.PUT_LINE('   Cursor : ' || coalesce(L_Result.PAGING_CURSOR, '<<null>>'));
         -- Update the cursor for the next iteration
         L_Filter.PAGING_CURSOR := SRYI_C50_1(L_Result.PAGING_CURSOR);
      end loop;
      -- output counters
      DBMS_OUTPUT.PUT_LINE('Total Order Headers returned: ' || L_CountHeaders);
      DBMS_OUTPUT.PUT_LINE('Total Pages read: ' || L_CountPages);
      DBMS_OUTPUT.PUT_LINE('Total Texts read: ' || L_CountText);
   end P_ReadHeaders;
begin
   G_LoginReturn := F2QLOGIN.F_SetUser('MD1AT', 'berlin08', 949);
   if G_LoginReturn != 'OK' then   
      DBMS_OUTPUT.PUT_LINE('Login fehlgeschlagen: ' || G_LoginReturn);
      return;
   end if;
   DBMS_OUTPUT.PUT_LINE('Login erfolgreich!');
   dbms_output.put_line('LogLevel B2: ' || G_LogLevel || ' - ' || case G_LogLevel when 8	then 'TRACE' when 7 then 'DEBUG' when 6 then 'INFO' when 5 then 'WARNING' when 4 then 'ERROR' end);
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
   --
   -- Testfilter #1 : Ohne jegliche Einschränkungen --> Default status 40 (visiert)
   --    Erwartung: Leeres Resultset weil keine Order vorhanden sind mit Status 40 (visiert)
   -- begin
   --    L_FilterIn := B2YI_AUFTRAGHEADER_FILTER_1();    -- Init Filter
   --    L_FilterIn.PAGING_SIZE := SRYI_I14_1(10000); -- Anzahl der Einträge pro Seite
   --    P_ReadHeaders(P_TestFilter => L_FilterIn);
   -- end;
   --                           
   -- Testfilter #2 : Alle Orders im Status 800 (Verbucht)
   --    Erwartung: Total Aufträge im Default-Status E & L : 52'548
   --                Effektiv geliefert                    : 52'526
   --                Differenz                             :    -22
   -- 
   -- Bei deisen 200 Aufträgen können KT_LNR oder KT_LNR_KT nicht gefunden werden im KTWI_STAMM_3!!
   -- Diese werden bewusst ausgefiltert!
   -- Alle diese 22 Aufträge wurden zur selben Zeit am 2026.06.24 15:45:31 angelegt!
   --
   begin
      -- Filter auf Status-Code
      L_FilterIn := B2YI_AUFTRAGHEADER_FILTER_1();    -- Init Filter
      L_FilterIn.OBJ_STAT_CD := SRCI_I3_1(); -- Initialize the status code array
      L_FilterIn.OBJ_STAT_CD.extend; L_FilterIn.OBJ_STAT_CD(L_FilterIn.OBJ_STAT_CD.last) := SRYI_I3_1(800); -- OrderStatus: 800 = Verbucht
      L_FilterIn.PAGING_SIZE := SRYI_I14_1(100000); -- Anzahl der Einträge pro Seite
      P_ReadHeaders(P_TestFilter => L_FilterIn);
   end;
   --                           
   -- Testfilter #3 : Alle Orders im Status 800 (Verbucht) und 5 ausgewählt häufig verwendete Assets
   --    Erwartung: 8'365 
   --    Result   : 8'364 (gleiches Problem wie oben mit fehlendem Konto)
   -- select   count(*)
   -- from     b2_auf            a
   -- where    1=1
   --    and   a.userbk_nr = F2QAPENV.F_UB
   --    and   a.obj_stat_cd in (120,800)
   --    and   a.BO_AUF_TYP_CD in ('E', 'L')
   --    and   a.VL_REF_LNR in 
   --          (
   --             133452055056,   -- IBM Rg
   --             33338337572328, -- Nestle N
   --             176311577225,   -- ABB N
   --             26056108462216, -- Schindler Hldg N
   --             17415196094616  -- Orell Fuessli N
   --          );
   -- begin
   --    L_FilterIn := B2YI_AUFTRAGHEADER_FILTER_1();    -- Init Filter
   --    -- Filter auf Valoren ----------------
   --    L_FilterIn.VL_REF_LNR := SRCI_I22_1(); -- Initialize the Valoren array
   --    L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(133452055056);      -- IBM Rg
   --    L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(33338337572328);    -- Nestle N
   --    L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(176311577225);      -- ABB N
   --    L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(26056108462216);    -- Schindler Hldg N
   --    L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(17415196094616);    -- Orell Fuessli N
   --    -- Filter auf Status-Code
   --    L_FilterIn.OBJ_STAT_CD := SRCI_I3_1(); -- Initialize the status code array
   --    L_FilterIn.OBJ_STAT_CD.extend; L_FilterIn.OBJ_STAT_CD(L_FilterIn.OBJ_STAT_CD.last) := SRYI_I3_1(120); -- OrderStatus: 120 = Ausgeführt
   --    L_FilterIn.OBJ_STAT_CD.extend; L_FilterIn.OBJ_STAT_CD(L_FilterIn.OBJ_STAT_CD.last) := SRYI_I3_1(800); -- OrderStatus: 800 = Verbucht
   --    L_FilterIn.PAGING_SIZE := SRYI_I14_1(10000); -- Anzahl der Einträge pro Seite
   --    P_ReadHeaders(P_TestFilter => L_FilterIn);
   -- end;
   --                           
   -- Testfilter #4 : Alle Orders aus Test #3 zusätzlich gefiltert nach den häufigsten AUF_EMPF_CDs.
   --    Erwartung: 7'989
   --    Result   : 7'988
   -- select   count(*)
   -- from     b2_auf            a
   -- where    1=1
   --    and   a.userbk_nr = F2QAPENV.F_UB
   --    and   a.obj_stat_cd in (120,800)
   --    and   a.BO_AUF_TYP_CD in ('E', 'L')
   --    and   a.VL_REF_LNR in 
   --          (
   --             133452055056,   -- IBM Rg
   --             33338337572328, -- Nestle N
   --             176311577225,   -- ABB N
   --             26056108462216, -- Schindler Hldg N
   --             17415196094616  -- Orell Fuessli N
   --          )
   --    and   a.auf_empf_cd in ('IA', 'TF', 'GO')
   -- ;
   -- begin
   --    L_FilterIn := B2YI_AUFTRAGHEADER_FILTER_1();    -- Init Filter
   --    -- Filter auf Valoren ----------------
   --    L_FilterIn.VL_REF_LNR := SRCI_I22_1(); -- Initialize the Valoren array
   --    L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(133452055056);      -- IBM Rg
   --    L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(33338337572328);    -- Nestle N
   --    L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(176311577225);      -- ABB N
   --    L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(26056108462216);    -- Schindler Hldg N
   --    L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(17415196094616);    -- Orell Fuessli N
   --    -- Filter auf Status-Code
   --    L_FilterIn.OBJ_STAT_CD := SRCI_I3_1(); -- Initialize the status code array
   --    L_FilterIn.OBJ_STAT_CD.extend; L_FilterIn.OBJ_STAT_CD(L_FilterIn.OBJ_STAT_CD.last) := SRYI_I3_1(120); -- OrderStatus: 120 = Ausgeführt
   --    L_FilterIn.OBJ_STAT_CD.extend; L_FilterIn.OBJ_STAT_CD(L_FilterIn.OBJ_STAT_CD.last) := SRYI_I3_1(800); -- OrderStatus: 800 = Verbucht
   --    -- Felter auf Auftragsherkunft ------------------
   --    L_FilterIn.AUF_EMPF_CD := SRCI_C2_1(); -- Initialize the Auftragsherkunft array
   --    L_FilterIn.AUF_EMPF_CD.extend; L_FilterIn.AUF_EMPF_CD(L_FilterIn.AUF_EMPF_CD.last) := SRYI_C2_1('IA');
   --    L_FilterIn.AUF_EMPF_CD.extend; L_FilterIn.AUF_EMPF_CD(L_FilterIn.AUF_EMPF_CD.last) := SRYI_C2_1('TF');
   --    L_FilterIn.AUF_EMPF_CD.extend; L_FilterIn.AUF_EMPF_CD(L_FilterIn.AUF_EMPF_CD.last) := SRYI_C2_1('GO');
   --    -- Filter auf Titellieferungspartner ----------------------------------------------------------------------------------------------
   --    --L_FilterIn.TL_PTN_LNR.extend; L_FilterIn.TL_PTN_LNR(L_FilterIn.TL_PTN_LNR.last) := SRYI_I22_1(27504511242036); -- BGTEST1/910 (ZKB Börsengateway)
   --    L_FilterIn.PAGING_SIZE := SRYI_I14_1(10000); -- Anzahl der Einträge pro Seite
   --    P_ReadHeaders(P_TestFilter => L_FilterIn);
   -- end;
   --                           
   -- Testfilter #4 : Alle Orders aus Test #4 zusätzlich gefiltert nach dem häufigsten Titellieferungs-Partner "Telefonhandel"
   --    Erwartung: 7'827
   --    Result   : 7'988
   -- select   count(*)
   -- from     b2_auf            a
   -- where    1=1
   --    and   a.userbk_nr = F2QAPENV.F_UB
   --    and   a.obj_stat_cd in (120,800)
   --    and   a.BO_AUF_TYP_CD in ('E', 'L')
   --    and   a.VL_REF_LNR in 
   --          (
   --             133452055056,   -- IBM Rg
   --             33338337572328, -- Nestle N
   --             176311577225,   -- ABB N
   --             26056108462216, -- Schindler Hldg N
   --             17415196094616  -- Orell Fuessli N
   --          )
   --    and   a.auf_empf_cd in ('IA', 'TF', 'GO')
   -- ;
   -- begin
   --    L_FilterIn := B2YI_AUFTRAGHEADER_FILTER_1();    -- Init Filter
   --    -- Filter auf Valoren ----------------
   --    L_FilterIn.VL_REF_LNR := SRCI_I22_1(); -- Initialize the Valoren array
   --    L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(133452055056);      -- IBM Rg
   --    L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(33338337572328);    -- Nestle N
   --    L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(176311577225);      -- ABB N
   --    L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(26056108462216);    -- Schindler Hldg N
   --    L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(17415196094616);    -- Orell Fuessli N
   --    -- Filter auf Status-Code
   --    L_FilterIn.OBJ_STAT_CD := SRCI_I3_1(); -- Initialize the status code array
   --    L_FilterIn.OBJ_STAT_CD.extend; L_FilterIn.OBJ_STAT_CD(L_FilterIn.OBJ_STAT_CD.last) := SRYI_I3_1(120); -- OrderStatus: 120 = Ausgeführt
   --    L_FilterIn.OBJ_STAT_CD.extend; L_FilterIn.OBJ_STAT_CD(L_FilterIn.OBJ_STAT_CD.last) := SRYI_I3_1(800); -- OrderStatus: 800 = Verbucht
   --    -- Felter auf Auftragsherkunft ------------------
   --    L_FilterIn.AUF_EMPF_CD := SRCI_C2_1(); -- Initialize the Auftragsherkunft array
   --    L_FilterIn.AUF_EMPF_CD.extend; L_FilterIn.AUF_EMPF_CD(L_FilterIn.AUF_EMPF_CD.last) := SRYI_C2_1('IA');
   --    L_FilterIn.AUF_EMPF_CD.extend; L_FilterIn.AUF_EMPF_CD(L_FilterIn.AUF_EMPF_CD.last) := SRYI_C2_1('TF');
   --    L_FilterIn.AUF_EMPF_CD.extend; L_FilterIn.AUF_EMPF_CD(L_FilterIn.AUF_EMPF_CD.last) := SRYI_C2_1('GO');
   --    -- Filter auf Titellieferungspartner ----------------------------------------------------------------------------------------------
   --    L_FilterIn.TL_PTN_LNR := SRYI_I22_1(22363699169887); -- Telefonhandel
   --    L_FilterIn.PAGING_SIZE := SRYI_I14_1(10000); -- Anzahl der Einträge pro Seite
   --    P_ReadHeaders(P_TestFilter => L_FilterIn);
   -- end;
   --                
   -- --------------------------------------------------------------------------------
   --                       End of your test code
   -- --------------------------------------------------------------------------------
   G_EvtEndTime := SYSTIMESTAMP;
   DBMS_OUTPUT.PUT_LINE('Execution time: ' || (G_EvtEndTime - G_EvtStartTime));
   -- Dump out any messages that were generated during the execution
   --SRQMESS0.DumpMessages();
   --
   -- Stop profiling
   if G_HProfEnabled then
      DBMS_HPROF.STOP_PROFILING;
   end if;
   commit;
   --rollback;
end;
/

drop table b2_sibu_auf_lnr;

-- create a table with run number increasing automatically, run time and order line number
create table b2_sibu_auf_lnr (
   run_nr      number(22,0)   not null,
   run_time    timestamp      not null,
   auf_lnr     number(22,0)
);

select   r.run_nr,
         r.run_time,
         count(*)
from     b2_sibu_auf_lnr r
group by r.run_nr,
         r.run_time;


select   * 
from     b2_sibu_auf_lnr         t
where    run_nr = (select max(run_nr) from b2_sibu_auf_lnr);



select   *
from     b2_auf            a
         left join b2_sibu_auf_lnr r on r.auf_lnr = a.auf_lnr and r.run_nr = (select max(run_nr) from b2_sibu_auf_lnr)
where    1=1
   and   a.userbk_nr = F2QAPENV.F_UB
   and   a.obj_stat_cd in (800)
   and   a.BO_AUF_TYP_CD in ('E', 'L')
   and   a.VL_REF_LNR in 
         (
            133452055056,   -- IBM Rg
            33338337572328, -- Nestle N
            176311577225,   -- ABB N
            26056108462216, -- Schindler Hldg N
            17415196094616  -- Orell Fuessli N
         )
   and   r.auf_lnr is null
;

-- --------------------------------------------------------------------------------
--  Checking the result of the test script
-- --------------------------------------------------------------------------------

declare
   G_LoginReturn     varchar2(30 char);
begin
   G_LoginReturn :=  f2qlogin.F_SetUser(
                                 P_ID => 'MD1AT', 
                                 P_PW => 'berlin08',
                                 P_UB => 949,
                                 P_SP => 1
                     );
   if G_LoginReturn != 'OK' then   
      dbms_output.put_line('Login fehlgeschlagen: ' || G_LoginReturn);
      return;
   end if;
   dbms_output.put_line('Login erfolgreich!');
   dbms_output.put_line('Current UserId   : ' || F2QAPENV.F_UserId());
   dbms_output.put_line('Current userbk   : ' || F2QAPENV.F_UB);
   dbms_output.put_line('Current rz       : ' || F2QAPENV.F_RZ);
   dbms_output.put_line('Current Mode     : ' || F2QAPENV.F_MODE);
   dbms_output.put_line('Current OraSchema: ' || F2QAPENV.F_GetOraSchm());
   dbms_output.put_line('Current VPD      : ' || F2QAPENV.F_CheckVpdSec());
end;
/


-- Nicht gelieferte Aufträge

-- L_OrderStats.extend; L_OrderStats(L_OrderStats.last) := SRYI_I3_1(950); -- OrderStatus: 950 = Annuliert
-- L_FilterIn.PAGING_SIZE := SRYI_I14_1(10000); -- Anzahl der Einträge pro Seite
-- Total Order Headers returned: 5086
-- Total Pages read: 1

-- L_FilterIn.PAGING_SIZE := SRYI_I14_1(100); -- Anzahl der Einträge pro Seite
-- Total Order Headers returned: 5091
-- Total Pages read: 51


select   count(*) as num_orders
from     b2_auf a
where    1=1
   and   a.userbk_nr = F2QAPENV.F_UB
   and   a.obj_stat_cd in (930)
   and   a.BO_AUF_TYP_CD in ('E', 'L')
;

-- Aufträge mit OM-Texten --------------------------------------
select   a.AUF_LNR,
         a.AUF_ID,
         a.OM_TEXT_LNR,
         t.OM_TEXT_TYP_CD,
         t.TEXT_REC
from     b2_auf a
         inner join om_text     t on    t.userbk_nr = a.userbk_nr
                              and   t.om_text_lnr = a.om_text_lnr
                              and   t.OM_TEXT_TYP_CD = 15
where    1=1
   and   a.userbk_nr = F2QAPENV.F_UB
   and   a.obj_stat_cd in (930)
   and   a.BO_AUF_TYP_CD in ('E', 'L')
   and   a.om_text_lnr is not null
order by a.auf_lnr desc
;


-- Show order status counts for userbk_nr = 949 ---------------------------------
select   a.obj_stat_cd,
         b.bez_lang,
         count(*) as anzahl_total,
         sum(case when a.bo_auf_typ_cd in ('E', 'L') then 1 else 0 end) as anzahl_e_l
from     b2_auf a
         left  join  om1obj_typ_stat b    on    b.userbk_nr = a.userbk_nr
                                          and   b.obj_typ_stat_cd - 1200000 = a.obj_stat_cd
                                          and   b.sprache_cd = 1
where    a.userbk_nr = F2QAPENV.F_UB
group by a.obj_stat_cd,
         b.bez_lang
order by a.obj_stat_cd
;


-- Show distinct BO_AUF_TYP_CD for userbk_nr = 949 with name and number of orders per type ---------------------------------
select   a.bo_auf_typ_cd,
         b.bez_lang,
         count(*) as anzahl_auftraege
from     b2_auf a
         left  join  bo1auf_typ   b       on    b.userbk_nr = a.userbk_nr
                                          and   b.BO_AUF_TYP_CD = a.BO_AUF_TYP_CD
                                          and   b.sprache_cd = 1
where    a.userbk_nr = F2QAPENV.F_UB
 --and   a.OBJ_STAT_CD = 930
group by a.bo_auf_typ_cd,
         b.bez_lang
order by a.bo_auf_typ_cd
;

-- Show distinct B2_AUF_ART_CD for userbk_nr = 949 with name and number of orders per type ---------------------------------
select   a.b2_auf_art_cd,
         b.bez_lang,
         count(*) as anzahl_auftraege
from     b2_auf a
         left  join  b21auf_art     b     on    b.userbk_nr = a.userbk_nr
                                          and   b.B2_AUF_ART_CD = a.B2_AUF_ART_CD
                                          and   b.sprache_cd = 1
where    a.userbk_nr = F2QAPENV.F_UB
group by a.b2_auf_art_cd,
         b.bez_lang
order by a.b2_auf_art_cd
;

-- Show order counts grouped by VL_REF_LNR, TK_SYM, ISIN_NR, and VL_REF_TEXT for userbk_nr = 949 with OBJ_STAT_CD = 930 ---------------------------------
select   r.vl_ref_lnr,
         v.tk_sym,
         v.isin_nr,
         r.vl_ref_text,
         count(*) as anzahl
from     b2_auf               a
         inner join  vl_ref   r  on r.userbk_nr = a.userbk_nr and r.VL_REF_LNR = a.VL_REF_LNR
         inner join  vl_stamm v  on v.userbk_nr = r.userbk_nr and v.VL_LNR = r.VL_LNR
where    a.userbk_nr = F2QAPENV.F_UB
   and   a.OBJ_STAT_CD = 800
   and   a.TL_PTN_LNR = 27504511242036
group by v.vl_lnr,
         r.vl_ref_lnr,
         v.tk_sym,
         v.isin_nr,
         r.vl_ref_text
order by r.vl_ref_lnr
;



-- Show detailed order information  ---------------------------------
select   a.tl_ptn_lnr,
         a.obj_stat_cd,
         count(*) as anzahl
from     b2_auf               a
where    a.userbk_nr = F2QAPENV.F_UB
   --and   a.OBJ_STAT_CD = 930
group by a.tl_ptn_lnr,
         a.obj_stat_cd
order by a.tl_ptn_lnr,
         a.obj_stat_cd
;


select   ba.auf_lnr
from     table( DDQI_DDCLNR22.F_CollStats(DDCLNR22(950), 10000))  filter1
         inner join B2_AUF ba on (filter1.column_value = ba.OBJ_STAT_CD)
where    ba.userbk_nr    = F2QAPENV.F_UB
order by ba.AUF_LNR asc;



declare
   L_LOG_LEVEL  integer;
begin
   L_LOG_LEVEL := ALQMSG00.F_GetLogLevel('B2');
   dbms_output.put_line('LogLevel: ' || L_LOG_LEVEL || ' - ' || case L_LOG_LEVEL when 8	then 'TRACE' when 7 then 'DEBUG' when 6 then 'INFO' when 5 then 'WARNING' when 4 then 'ERROR' end);
   ALQMSG00.MSG_DEBUG('Test', 'Papperlapapp', 'PackageName', L_LOG_LEVEL);
end;
/


-- -----------------------------------------------------------------------------
--  Lookup packages with source code
-- -----------------------------------------------------------------------------
select  ob.object_type, ob.owner, ob.object_name, ob.status, code_lines, 
        so.source_code,
        to_char(trunc(ob.created),'yyyy.mm.dd')                 as  created,
        to_char(trunc(ob.last_ddl_time),'yyyy.mm.dd')           as  last_ddl
from    sys.all_objects         ob
        inner join
        (
            select  owner, name, type, xmlagg(xmlelement(e, regexp_replace(text, '[^[:print:]' || CHR(10) || CHR(13) || ']', '')) order by type, line).extract('//text()').getclobval() as source_code, count(*) as code_lines
            from    all_source
            where   line <= 300000 -- xmlagg can only handle a maximum of 300000 rows. Onyl package VLQSTAMM_BOB is above this limit!
            group by owner, name, type
        )                           so  on  so.owner = ob.owner and so.type = ob.object_type and so.name = ob.object_name
where   ob.owner like upper('F2LDATP0')
    and ob.object_name like upper('srqlog00')
order   by  ob.object_type,
            ob.owner,
            ob.object_name
;





select   a.AUF_LNR,
         a.AUF_ID,
         a.OM_TEXT_LNR,
         t.*
from     b2_auf      a
         left  join  om_text     t on    t.userbk_nr = a.userbk_nr
                              and   t.om_text_lnr = a.om_text_lnr
where    a.om_text_lnr is not null
   and   a.OM_TEXT_LNR = 47533466843866
order by a.AUF_LNR desc
fetch first 100 rows only
;

select   t.OM_TEXT_LNR, count(*) as count_text
from     om_text     t
group by t.OM_TEXT_LNR
having   count(*) > 1
order by count_text desc
;



-- -----------------------------------------------------------------------------
--  Lookup packages with source code
-- -----------------------------------------------------------------------------
select  ob.object_type, ob.owner, ob.object_name, ob.status, code_lines, 
        so.source_code,
        to_char(trunc(ob.created),'yyyy.mm.dd')                 as  created,
        to_char(trunc(ob.last_ddl_time),'yyyy.mm.dd')           as  last_ddl
from    sys.all_objects         ob
        inner join
        (
            select  owner, name, type, xmlagg(xmlelement(e, regexp_replace(text, '[^[:print:]' || CHR(10) || CHR(13) || ']', '')) order by type, line).extract('//text()').getclobval() as source_code, count(*) as code_lines
            from    all_source
            where   line <= 300000 -- xmlagg can only handle a maximum of 300000 rows. Onyl package VLQSTAMM_BOB is above this limit!
            group by owner, name, type
        )                           so  on  so.owner = ob.owner and so.type = ob.object_type and so.name = ob.object_name
where   ob.owner like upper('F2LDATP0')
    and ob.object_name like upper('package_name_pattern')
order   by  ob.object_type,
            ob.owner,
            ob.object_name
;


select   *
from     all_source     s
where    s.owner like upper('F2LDATP0')
   and   s.text like '%OM_TEXT_TYP_CD_TBL%'
order by s.owner, s.name, s.type, s.line
;








declare
   L_Headers B2CF_DL_ORDER_HEADER := B2CF_DL_ORDER_HEADER();
   L_AufKeys B2CF_DL_AUF_KEY := B2CF_DL_AUF_KEY();
begin
   L_Headers.extend;
   L_Headers(L_Headers.last) := B2YF_DL_ORDER_HEADER(AUF_LNR  => 12345678901234);
   -- Get all AUF_LNR values from the headers and collect them into L_Aufs
   for i in 1 .. L_Headers.count loop
      L_AufKeys.extend;
      L_AufKeys(L_AufKeys.last) := B2YF_DL_AUF_KEY(L_Headers(i).AUF_LNR, L_Headers(i).REF_IDX);
   end loop;
end;
/


declare
   OH_DL B2CF_DL_ORDER_HEADER := B2CF_DL_ORDER_HEADER();
   OH_SL B2CI_AUFTRAGHEADER_1 := B2CI_AUFTRAGHEADER_1();
begin
   OH_DL.extend;    
   OH_DL(OH_DL.last) := B2YF_DL_ORDER_HEADER(AUF_LNR  => 12345678901234);
   OH_DL(OH_DL.last).OM_TEXTE := B2CF_DL_ORDER_OM_TEXT(
                                    B2YF_DL_ORDER_OM_TEXT(SPRACHE_CD => 1, OM_TEXT_TYP_CD => 15, TEXT_REC => 'Testtext 1'),
                                    B2YF_DL_ORDER_OM_TEXT(SPRACHE_CD => 1, OM_TEXT_TYP_CD => 12, TEXT_REC => 'Testtext 2')
                                 );
   OH_DL.extend;    
   OH_DL(OH_DL.last) := B2YF_DL_ORDER_HEADER(AUF_LNR  => 12345034978374);
   OH_DL(OH_DL.last).OM_TEXTE := B2CF_DL_ORDER_OM_TEXT(
                                    B2YF_DL_ORDER_OM_TEXT(SPRACHE_CD => 2, OM_TEXT_TYP_CD => 15, TEXT_REC => 'Testtext 2')
                                 );
   -- Convert the DL to SL
   select   B2YI_AUFTRAGHEADER_1(
               auf_lnr => dl.auf_lnr,
               om_texte => cast(
                              multiset(
                                 select   B2YI_ORDER_TEXT_2(
                                             TEXT_TYP_CD => t.OM_TEXT_TYP_CD,
                                             SPRACHE_CD  => t.SPRACHE_CD,
                                             TEXT_REC    => t.TEXT_REC
                                          )
                                 from table(dl.om_texte) t
                              ) as B2CI_ORDER_TEXT_2
                           )
            )
   bulk collect into OH_SL
   from     table(OH_DL)      dl;
   --
   -- Output the converted SL
   for i in 1 .. OH_SL.count loop
      dbms_output.put_line('AUF_LNR: ' || OH_SL(i).auf_lnr);
      if cardinality(OH_SL(i).om_texte) > 0 then
         for j in 1 .. cardinality(OH_SL(i).om_texte) loop
            dbms_output.put_line('   Text ' || j || ': ' || OH_SL(i).om_texte(j).F_ToString());
         end loop;
      else
         dbms_output.put_line('   No texts available.');
      end if;
   end loop;
end;
/


-- -----------------------------------------------------------------------------
--  Show all indices for a given table
-- -----------------------------------------------------------------------------
select  distinct
        ix.table_owner, ix.table_name,
        ix.owner,       ix.index_name,
        ix.uniqueness,
        ix.num_rows,    ix.distinct_keys,
        ix.status,      ix.visibility,
        listagg(ic.column_name, ' / ') within group (order by ic.column_position) over (partition by ic.index_owner, ic.index_name) as listagg
from    sys.all_indexes ix
        inner join  sys.all_ind_columns ic  on  ic.index_owner = ix.owner
                                            and ic.index_name = ix.index_name
where   lower(ix.table_name)   like lower('b2_auf')
    and lower(ix.owner)        like lower('F2LDATP0')
order   by  ix.table_owner,
            ix.table_name,
            ix.index_name
;

select   a.B2_POOL_LNR,
         count(*) as cnt
from     b2_auf      a
group by a.B2_POOL_LNR
order by cnt desc;


-- -----------------------------------------------------------------------------
--  Lookup packages with source code
-- -----------------------------------------------------------------------------
select  ob.object_type, ob.owner, ob.object_name, ob.status, code_lines, 
        so.source_code,
        to_char(trunc(ob.created),'yyyy.mm.dd')                 as  created,
        to_char(trunc(ob.last_ddl_time),'yyyy.mm.dd')           as  last_ddl
from    sys.all_objects         ob
        inner join
        (
            select  owner, name, type, xmlagg(xmlelement(e, regexp_replace(text, '[^[:print:]' || CHR(10) || CHR(13) || ']', '')) order by type, line).extract('//text()').getclobval() as source_code, count(*) as code_lines
            from    all_source
            where   line <= 300000 -- xmlagg can only handle a maximum of 300000 rows. Onyl package VLQSTAMM_BOB is above this limit!
            group by owner, name, type
        )                           so  on  so.owner = ob.owner and so.type = ob.object_type and so.name = ob.object_name
where   ob.owner like upper('F2LDATP0')
    and ob.object_name like upper('B2YI_ORDER_TEXT_2')
order   by  ob.object_type,
            ob.owner,
            ob.object_name
;










select   a.auf_lnr,
         a.B2_GNR,
         a.bo_auf_typ_cd
from     b2_auf         a
where    1=1
   and   a.userbk_nr = F2QAPENV.F_UB
   and   a.obj_stat_cd in (800)
   and   a.BO_AUF_TYP_CD in ('E', 'L')
   and   a.auf_lnr = a.b2_gnr
;

select   count(*)                                                 as num_total,
         count(distinct auf_lnr)                                  as num_auf_lnr,
         count(distinct b2_gnr)                                   as num_b2_gnr,
         sum(case when a.auf_lnr <> a.b2_gnr then 1 else 0 end)   as num_mismatched,
         sum(case when a.auf_lnr =  a.b2_gnr then 1 else 0 end)   as num_matched
from     b2_auf         a
where    1=1
   and   a.userbk_nr = F2QAPENV.F_UB
   and   a.obj_stat_cd in (800)
   and   a.BO_AUF_TYP_CD in ('E', 'L')
;

select   *
from     kd_stamm       kd
where    kd.kd_lnr = 901
;


select   *
from     KTWI_STAMM_3
;


select   a.VL_REF_LNR,
       --v.ISIN_NR,
         v.VL_REF_TEXT,
         count(*) as cnt
from     b2_auf         a
         inner join VL_REF    v  on v.VL_REF_LNR = a.VL_REF_LNR and v.USERBK_NR = a.USERBK_NR
where    1=1
   and   a.userbk_nr = F2QAPENV.F_UB
   and   a.obj_stat_cd in (800)
   and   a.BO_AUF_TYP_CD in ('E', 'L')
group by a.VL_REF_LNR, v.VL_REF_TEXT
order by cnt desc
;

select   count(*)
from     b2_auf            a
where    1=1
   and   a.userbk_nr = F2QAPENV.F_UB
   and   a.obj_stat_cd in (120,800)
   and   a.BO_AUF_TYP_CD in ('E', 'L')
   and   a.VL_REF_LNR in 
         (
            133452055056,   -- IBM Rg
            33338337572328, -- Nestle N
            176311577225,   -- ABB N
            26056108462216, -- Schindler Hldg N
            17415196094616  -- Orell Fuessli N
         )
   and   a.auf_empf_cd in ('IA', 'TF', 'GO')
   and   a.tl_ptn_lnr = 22363699169887
;

select   a.tl_ptn_lnr,
         count(*) as cnt
from     b2_auf            a
where    1=1
   and   a.userbk_nr = F2QAPENV.F_UB
   and   a.obj_stat_cd in (120,800)
   and   a.BO_AUF_TYP_CD in ('E', 'L')
   and   a.VL_REF_LNR in 
         (
            133452055056,   -- IBM Rg
            33338337572328, -- Nestle N
            176311577225,   -- ABB N
            26056108462216, -- Schindler Hldg N
            17415196094616  -- Orell Fuessli N
         )
   and   a.auf_empf_cd in ('IA', 'TF', 'GO')
group by a.tl_ptn_lnr
order by cnt desc
;

select   *
from     tl_ptn      p
where    p.tl_ptn_lnr = 22363699169887
;