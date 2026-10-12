create or replace procedure SIBU_TEST_AUFTRAG_HEADERS(
   P_TestFilter      in B2YI_AUFTRAGHEADER_FILTER_1,
   P_HProfEnabled    in boolean     default false,
   P_Iterations      in integer     default 1
)
as
   G_HProfDirectory     varchar2(20 char) := 'MANIFEST_DIR';            -- Directory-Objekt für HPROF-Ausgabe
   G_HProfFilename      varchar2(50 char) := 'b2_test_' || to_char(sysdate,'YYYYMMDDHH24MISS') || '.trc';  -- Dateiname für HPROF-Ausgabe
   G_HProfEnabled       boolean := P_HProfEnabled; -- Flag, um HPROF-Teil des Codes zu aktivieren/deaktivieren
   --
   G_LoginReturn        varchar2(30 char); --Variabel für den Return-Wert der Login-Funktion
   G_EvtStartTime       timestamp; --Variable für die Startzeit der Operation
   G_EvtEndTime         timestamp; --Variable für die Endzeit der Operation
   G_EvtDuration        interval day to second;
   G_DebugLoggers       DDCSTRING;
   --
   L_FilterIn           B2YI_AUFTRAGHEADER_FILTER_1 := B2YI_AUFTRAGHEADER_FILTER_1();
   L_FilterBL           B2YF_BL_ORDER_FILTER := B2YF_BL_ORDER_FILTER();
   L_Result             B2YI_AUFTRAGHEADER_RESPONSE_1;
   L_ValorRefs          SRCI_I22_1 := SRCI_I22_1();
   L_OrderStats         SRCI_I3_1 := SRCI_I3_1();
   L_AufEmpfCds         SRCI_C2_1 := SRCI_C2_1();
   L_TlPtnRefs          SRYI_I22_1 := SRYI_I22_1();
   --
   L_PageCursorRet      B2QF_BL_ORDER.T_PAGE_CURSOR_RET       := B2QF_BL_ORDER.T_PAGE_CURSOR_RET();
   --
   L_CountHeaders       integer := 0;
   L_CountPages         integer := 0;
   L_CountText          integer := 0;
   L_RunNr              integer := 0;
   L_RunTime            timestamp := systimestamp;
   L_Filter             B2YI_AUFTRAGHEADER_FILTER_1 := P_TestFilter;
   L_FilterList         varchar2(4000 char);
   L_PageStartTime      timestamp; --Variable für die Startzeit der Operation
   L_SelectExpected     varchar2(4000 char);
   L_CountExpected      integer := 0;
   L_ListAgg            varchar2(4000 char);
begin
   G_LoginReturn := F2QLOGIN.F_SetUser('MD1AT', 'berlin08', 949);
   if G_LoginReturn != 'OK' then   
      DBMS_OUTPUT.PUT_LINE('Login fehlgeschlagen: ' || G_LoginReturn);
      return;
   end if;
   DBMS_OUTPUT.PUT_LINE('Login erfolgreich!');
   -- Zeige alle PL/SQL-Objekte, welche im Level Debug loggen
   select ld.sql_obj_name bulk collect into G_DebugLoggers from sr_log_defi ld where ld.USERBK_NR = F2QAPENV.F_UB and ld.LOG_LEVEL = 7;
   if G_DebugLoggers is not null and G_DebugLoggers.count > 0 then
      for i in 1 .. G_DebugLoggers.count loop
         DBMS_OUTPUT.PUT_LINE('  - ' || G_DebugLoggers(i));
      end loop;
   else
      dbms_output.put_line('  None!');
   end if;
   if G_HProfEnabled then
      -- Start profiling and write raw data to a file
      DBMS_HPROF.START_PROFILING(
         location => G_HProfDirectory,   -- Must match directory object name
         filename => G_HProfFilename
      );
      DBMS_OUTPUT.PUT_LINE('Profiling started into file ' || G_HProfFilename);
   end if;
   --
   dbms_output.put_line(rpad('>', 100, '-'));
   dbms_output.put_line('Read headers with the following filter:');
   dbms_output.put_line(' - PAGING_SIZE         :' || P_TestFilter.PAGING_SIZE.F_ToString());
   dbms_output.put_line(' - VL_REF_LNR          :' || ALQI_LOGGING_UTIL_1.F_ToString(P_SrCiI22 => P_TestFilter.VL_REF_LNR));
   dbms_output.put_line(' - TL_PTN_LNR          :' || case when P_TestFilter.TL_PTN_LNR is null then '' else P_TestFilter.TL_PTN_LNR.F_ToString() end);
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
   <<iteration_loop>>
   for L_Iteration in 1 .. P_Iterations loop
      G_EvtStartTime := SYSTIMESTAMP;
      <<page_loop>>
      loop
         L_PageStartTime := SYSTIMESTAMP;
         --select coalesce(max(run_nr),0) + 1 into L_RunNr from b2_sibu_auf_lnr;
         L_Result := b2qi_trading_1.F_ReadBoersenauftragHeaders(P_Filter => L_Filter);
         L_CountPages := L_CountPages + 1;
         if L_Iteration = 1 then
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
               --insert into b2_sibu_auf_lnr (run_nr, run_time, auf_lnr) values (L_RunNr, L_RunTime, L_Result.AUFTRAGHEADER_LIST(i).AUF_LNR);
               L_CountText := L_CountText + coalesce(cardinality(L_Result.AUFTRAGHEADER_LIST(i).OM_TEXTE), 0);
            end loop header_loop;
         end if;
         exit when L_Result.PAGING_CURSOR is null;
         DBMS_OUTPUT.PUT_LINE('   Cursor : ' || coalesce(L_Result.PAGING_CURSOR, '<<null>>'));
         -- Update the cursor for the next iteration
         L_Filter.PAGING_CURSOR := SRYI_C50_1(L_Result.PAGING_CURSOR);
      end loop page_loop;
      -- output counters
      if L_Iteration = 1 then
         DBMS_OUTPUT.PUT_LINE('Total Order Headers returned: ' || L_CountHeaders);
         DBMS_OUTPUT.PUT_LINE('Total Pages read: ' || L_CountPages);
         DBMS_OUTPUT.PUT_LINE('Total Texts read: ' || L_CountText);
      end if;
      G_EvtEndTime := SYSTIMESTAMP;
      G_EvtDuration := G_EvtEndTime - G_EvtStartTime;
      DBMS_OUTPUT.PUT_LINE(
         'Execution #' || to_char(L_Iteration, '000') || ' : ' ||
         to_char(G_EvtStartTime, 'hh24:mi:ss.ff3') || ' - ' ||
         to_char(G_EvtEndTime, 'hh24:mi:ss.ff3') || ' (' ||
         to_char(extract(minute from G_EvtDuration), 'FM00') || ':' ||
         to_char(extract(second from G_EvtDuration), 'FM00.000') || ')'
      );
   end loop iteration_loop;
   --
   L_SelectExpected := 
         'select count(*) from b2_auf a where userbk_nr = F2QAPENV.F_UB and bo_auf_typ_cd in (''E'', ''L'') ' ||
         'and a.auf_art_cd in (''10'',''110'') ' ||      -- Nur Kundenaufträge
         'and (a.kt_lnr is null or exists (select null from ktwi_stamm_3 k where k.kt_lnr = a.kt_lnr)) ' ||
         'and (a.kt_lnr_kt is null or exists (select null from ktwi_stamm_3 k where k.kt_lnr = a.kt_lnr_kt))';
   if P_TestFilter.VL_REF_LNR is not null and cardinality(P_TestFilter.VL_REF_LNR) > 0 then
      select listagg(a.key_cd, ',') into L_ListAgg from table(P_TestFilter.VL_REF_LNR) a;
      L_SelectExpected := L_SelectExpected || ' and a.VL_REF_LNR in (' || L_ListAgg || ')';
   end if;
   if P_TestFilter.OBJ_STAT_CD is not null and cardinality(P_TestFilter.OBJ_STAT_CD) > 0 then
      select listagg(a.key_cd, ',') into L_ListAgg from table(P_TestFilter.OBJ_STAT_CD) a;
      L_SelectExpected := L_SelectExpected || ' and a.OBJ_STAT_CD in (' || L_ListAgg || ')';
   else
      L_SelectExpected := L_SelectExpected || ' and a.OBJ_STAT_CD in (40)';
   end if;
   if P_TestFilter.AUF_EMPF_CD is not null and cardinality(P_TestFilter.AUF_EMPF_CD) > 0 then
      select listagg('''' || a.key_cd || '''', ',') into L_ListAgg from table(P_TestFilter.AUF_EMPF_CD) a;
      L_SelectExpected := L_SelectExpected || ' and a.AUF_EMPF_CD in (' || L_ListAgg || ')';
   end if;
   if P_TestFilter.TL_PTN_LNR is not null then
      L_SelectExpected := L_SelectExpected || ' and a.TL_PTN_LNR = ' || P_TestFilter.TL_PTN_LNR.key_cd;
   end if;
   if P_TestFilter.BO_PLATZ_LNR is not null and cardinality(P_TestFilter.BO_PLATZ_LNR) > 0 then
      select listagg(a.key_cd, ',') into L_ListAgg from table(P_TestFilter.BO_PLATZ_LNR) a;
      L_SelectExpected := L_SelectExpected || ' and a.BO_PLATZ_LNR in (' || L_ListAgg || ')';
   end if;
   if P_TestFilter.HWRG_LNR is not null and cardinality(P_TestFilter.HWRG_LNR) > 0 then
      select listagg(a.key_cd, ',') into L_ListAgg from table(P_TestFilter.HWRG_LNR) a;
      L_SelectExpected := L_SelectExpected || ' and a.HWRG_LNR in (' || L_ListAgg || ')';
   end if;
   if P_TestFilter.VALID_VON_DT_FROM is not null then
      L_SelectExpected := L_SelectExpected || ' and a.VALID_VON_DT >= to_date(''' || to_char(P_TestFilter.VALID_VON_DT_FROM, 'YYYY-MM-DD HH24:MI:SS') || ''', ''YYYY-MM-DD HH24:MI:SS'')';
   end if;
   if P_TestFilter.VALID_VON_DT_TO is not null then
      L_SelectExpected := L_SelectExpected || ' and a.VALID_VON_DT <= to_date(''' || to_char(P_TestFilter.VALID_VON_DT_TO, 'YYYY-MM-DD HH24:MI:SS') || ''', ''YYYY-MM-DD HH24:MI:SS'')';
   end if;
   if P_TestFilter.VALID_BIS_DT_FROM is not null then
      L_SelectExpected := L_SelectExpected || ' and a.VALID_BIS_DT >= to_date(''' || to_char(P_TestFilter.VALID_BIS_DT_FROM, 'YYYY-MM-DD HH24:MI:SS') || ''', ''YYYY-MM-DD HH24:MI:SS'')';
   end if;
   if P_TestFilter.VALID_BIS_DT_TO is not null then
      L_SelectExpected := L_SelectExpected || ' and a.VALID_BIS_DT <= to_date(''' || to_char(P_TestFilter.VALID_BIS_DT_TO, 'YYYY-MM-DD HH24:MI:SS') || ''', ''YYYY-MM-DD HH24:MI:SS'')';
   end if;
   dbms_output.put_line('Select statement: ' || L_SelectExpected);
   execute immediate L_SelectExpected into L_CountExpected;
   -- 
   if L_CountHeaders <> L_CountExpected then
      DBMS_OUTPUT.PUT_LINE('Warning: Expected ' || L_CountExpected || ' headers but found ' || L_CountHeaders);
   else
      DBMS_OUTPUT.PUT_LINE('Expected count matches the actual count: ' || L_CountHeaders);
   end if;
   --                           
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
show errors

-- Testfilter #1 : Ohne jegliche Einschränkungen --> Default status 40 (visiert)
--    Erwartung: Leeres Resultset weil keine Order vorhanden sind mit Status 40 (visiert)
--
declare
   L_FilterIn        B2YI_AUFTRAGHEADER_FILTER_1 := B2YI_AUFTRAGHEADER_FILTER_1();
begin
   L_FilterIn := B2YI_AUFTRAGHEADER_FILTER_1();    -- Init Filter
   L_FilterIn.PAGING_SIZE := SRYI_I14_1(10000); -- Anzahl der Einträge pro Seite
   SIBU_TEST_AUFTRAG_HEADERS(
      P_TestFilter => L_FilterIn,
      P_Iterations => 10
   );
end;
/

select count(*) from b2_auf a where userbk_nr = F2QAPENV.F_UB and bo_auf_typ_cd in ('E', 'L') and a.auf_art_cd in ('10','110') and (a.kt_lnr is null or exists (select null from ktwi_stamm_3 k where k.kt_lnr = a.kt_lnr)) and (a.kt_lnr_kt is null or exists (select null from ktwi_stamm_3 k where k.kt_lnr = a.kt_lnr_kt)) and a.OBJ_STAT_CD in (40);



-- Testfilter #2 : Alle Orders im Status 800 (Verbucht)
--    Erwartung: Total Aufträge im Default-Status E & L : 52'548
--                Effektiv geliefert                    : 52'526
--                Differenz                             :    -22
-- 
-- select   count(*)
-- from     b2_auf            a
-- where    1=1
--    and   a.userbk_nr = F2QAPENV.F_UB
--    and   (a.kt_lnr is null or exists (select null from ktwi_stamm_3 k where k.kt_lnr = a.kt_lnr))
--    and   (a.kt_lnr_kt is null or exists (select null from ktwi_stamm_3 k where k.kt_lnr = a.kt_lnr_kt))
--    and   a.obj_stat_cd in (800)
--    and   a.BO_AUF_TYP_CD in ('E', 'L')
--    and   a.AUF_ART_CD in ('10','110')      -- Nur Kundenaufträge
-- ;
--
declare
   L_FilterIn        B2YI_AUFTRAGHEADER_FILTER_1 := B2YI_AUFTRAGHEADER_FILTER_1();
begin
   -- Filter auf Status-Code
   L_FilterIn.OBJ_STAT_CD := SRCI_I3_1(); -- Initialize the status code array
   L_FilterIn.OBJ_STAT_CD.extend; L_FilterIn.OBJ_STAT_CD(L_FilterIn.OBJ_STAT_CD.last) := SRYI_I3_1(800); -- OrderStatus: 800 = Verbucht
   L_FilterIn.PAGING_SIZE := SRYI_I14_1(100000); -- Anzahl der Einträge pro Seite
   SIBU_TEST_AUFTRAG_HEADERS(
      P_TestFilter => L_FilterIn,
      P_Iterations => 10
   );
end;
/

-- Testfilter #3 : Alle Orders im Status 800 (Verbucht) und 5 ausgewählt häufig verwendete Assets
--
-- select   count(*)
-- from     b2_auf            a
-- where    1=1
--    and   a.userbk_nr = F2QAPENV.F_UB
--    and   (a.kt_lnr is null or exists (select null from ktwi_stamm_3 k where k.kt_lnr = a.kt_lnr))
--    and   (a.kt_lnr_kt is null or exists (select null from ktwi_stamm_3 k where k.kt_lnr = a.kt_lnr_kt))
--    and   a.obj_stat_cd in (120,800)
--    and   a.BO_AUF_TYP_CD in ('E', 'L')
--    and   a.AUF_ART_CD in ('10','110')      -- Nur Kundenaufträge
--    and   a.VL_REF_LNR in 
--          (
--             133452055056,   -- IBM Rg
--             33338337572328, -- Nestle N
--             176311577225,   -- ABB N
--             26056108462216, -- Schindler Hldg N
--             17415196094616  -- Orell Fuessli N
--          );
declare
   L_FilterIn        B2YI_AUFTRAGHEADER_FILTER_1 := B2YI_AUFTRAGHEADER_FILTER_1();
begin
   L_FilterIn.VL_REF_LNR := SRCI_I22_1(); -- Initialize the Valoren array
   L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(133452055056);      -- IBM Rg
   L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(33338337572328);    -- Nestle N
   L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(176311577225);      -- ABB N
   L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(26056108462216);    -- Schindler Hldg N
   L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(17415196094616);    -- Orell Fuessli N
   -- Filter auf Status-Code
   L_FilterIn.OBJ_STAT_CD := SRCI_I3_1(); -- Initialize the status code array
   L_FilterIn.OBJ_STAT_CD.extend; L_FilterIn.OBJ_STAT_CD(L_FilterIn.OBJ_STAT_CD.last) := SRYI_I3_1(120); -- OrderStatus: 120 = Ausgeführt
   L_FilterIn.OBJ_STAT_CD.extend; L_FilterIn.OBJ_STAT_CD(L_FilterIn.OBJ_STAT_CD.last) := SRYI_I3_1(800); -- OrderStatus: 800 = Verbucht
   L_FilterIn.PAGING_SIZE := SRYI_I14_1(10000); -- Anzahl der Einträge pro Seite
   SIBU_TEST_AUFTRAG_HEADERS(P_TestFilter => L_FilterIn);
end;
/

--                           
-- Testfilter #4 : Alle Orders aus Test #3 zusätzlich gefiltert nach den häufigsten AUF_EMPF_CDs.
--
-- select   count(*)
-- from     b2_auf            a
-- where    1=1
--    and   a.userbk_nr = F2QAPENV.F_UB
--    and   (a.kt_lnr is null or exists (select null from ktwi_stamm_3 k where k.kt_lnr = a.kt_lnr))
--    and   (a.kt_lnr_kt is null or exists (select null from ktwi_stamm_3 k where k.kt_lnr = a.kt_lnr_kt))
--    and   a.obj_stat_cd in (120,800)
--    and   a.BO_AUF_TYP_CD in ('E', 'L')
--    and   a.AUF_ART_CD in ('10','110')      -- Nur Kundenaufträge
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
declare
   L_FilterIn        B2YI_AUFTRAGHEADER_FILTER_1 := B2YI_AUFTRAGHEADER_FILTER_1();
begin
   L_FilterIn.VL_REF_LNR := SRCI_I22_1(); -- Initialize the Valoren array
   L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(133452055056);      -- IBM Rg
   L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(33338337572328);    -- Nestle N
   L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(176311577225);      -- ABB N
   L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(26056108462216);    -- Schindler Hldg N
   L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(17415196094616);    -- Orell Fuessli N
   -- Filter auf Status-Code
   L_FilterIn.OBJ_STAT_CD := SRCI_I3_1(); -- Initialize the status code array
   L_FilterIn.OBJ_STAT_CD.extend; L_FilterIn.OBJ_STAT_CD(L_FilterIn.OBJ_STAT_CD.last) := SRYI_I3_1(120); -- OrderStatus: 120 = Ausgeführt
   L_FilterIn.OBJ_STAT_CD.extend; L_FilterIn.OBJ_STAT_CD(L_FilterIn.OBJ_STAT_CD.last) := SRYI_I3_1(800); -- OrderStatus: 800 = Verbucht
   -- Felter auf Auftragsherkunft ------------------
   L_FilterIn.AUF_EMPF_CD := SRCI_C2_1(); -- Initialize the Auftragsherkunft array
   L_FilterIn.AUF_EMPF_CD.extend; L_FilterIn.AUF_EMPF_CD(L_FilterIn.AUF_EMPF_CD.last) := SRYI_C2_1('IA');
   L_FilterIn.AUF_EMPF_CD.extend; L_FilterIn.AUF_EMPF_CD(L_FilterIn.AUF_EMPF_CD.last) := SRYI_C2_1('TF');
   L_FilterIn.AUF_EMPF_CD.extend; L_FilterIn.AUF_EMPF_CD(L_FilterIn.AUF_EMPF_CD.last) := SRYI_C2_1('GO');
   L_FilterIn.PAGING_SIZE := SRYI_I14_1(10000); -- Anzahl der Einträge pro Seite
   SIBU_TEST_AUFTRAG_HEADERS(P_TestFilter => L_FilterIn);
end;
/


declare
   G_LoginReturn     varchar2(30 char); --Variabel für den Return-Wert der Login-Funktion
begin
   G_LoginReturn := f2qlogin.F_SetUser('MD1AT', 'berlin08', 949);
   if G_LoginReturn != 'OK' then   
      dbms_output.put_line('Login fehlgeschlagen: ' || G_LoginReturn);
      return;
   end if;
   dbms_output.put_line('Login erfolgreich!');
end;
/

-- Testfilter #5 : Alle Orders aus Test #4 zusätzlich gefiltert nach dem häufigsten Titellieferungs-Partner Telefonhandel
--
-- select   count(*)
-- from     b2_auf            a
-- where    1=1
--    and   a.userbk_nr = F2QAPENV.F_UB
--    and   (a.kt_lnr is null or exists (select null from ktwi_stamm_3 k where k.kt_lnr = a.kt_lnr))
--    and   (a.kt_lnr_kt is null or exists (select null from ktwi_stamm_3 k where k.kt_lnr = a.kt_lnr_kt))
--    and   a.obj_stat_cd in (120,800)
--    and   a.BO_AUF_TYP_CD in ('E', 'L')
--    and   a.AUF_ART_CD in ('10','110')      -- Nur Kundenaufträge
--    and   a.VL_REF_LNR in 
--          (
--             133452055056,   -- IBM Rg
--             33338337572328, -- Nestle N
--             176311577225,   -- ABB N
--             26056108462216, -- Schindler Hldg N
--             17415196094616  -- Orell Fuessli N
--          )
--    and   a.auf_empf_cd in ('IA', 'TF', 'GO')
--    and   a.TL_PTN_LNR = 22363699169887 -- Telefonhandel
-- ;
--
declare
   L_FilterIn        B2YI_AUFTRAGHEADER_FILTER_1 := B2YI_AUFTRAGHEADER_FILTER_1();
begin
   -- Filter auf Valoren ----------------
   L_FilterIn.VL_REF_LNR := SRCI_I22_1(); -- Initialize the Valoren array
   L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(133452055056);      -- IBM Rg
   L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(33338337572328);    -- Nestle N
   L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(176311577225);      -- ABB N
   L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(26056108462216);    -- Schindler Hldg N
   L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(17415196094616);    -- Orell Fuessli N
   -- Filter auf Status-Code
   L_FilterIn.OBJ_STAT_CD := SRCI_I3_1(); -- Initialize the status code array
   L_FilterIn.OBJ_STAT_CD.extend; L_FilterIn.OBJ_STAT_CD(L_FilterIn.OBJ_STAT_CD.last) := SRYI_I3_1(120); -- OrderStatus: 120 = Ausgeführt
   L_FilterIn.OBJ_STAT_CD.extend; L_FilterIn.OBJ_STAT_CD(L_FilterIn.OBJ_STAT_CD.last) := SRYI_I3_1(800); -- OrderStatus: 800 = Verbucht
   -- Felter auf Auftragsherkunft ------------------
   L_FilterIn.AUF_EMPF_CD := SRCI_C2_1(); -- Initialize the Auftragsherkunft array
   L_FilterIn.AUF_EMPF_CD.extend; L_FilterIn.AUF_EMPF_CD(L_FilterIn.AUF_EMPF_CD.last) := SRYI_C2_1('IA');
   L_FilterIn.AUF_EMPF_CD.extend; L_FilterIn.AUF_EMPF_CD(L_FilterIn.AUF_EMPF_CD.last) := SRYI_C2_1('TF');
   L_FilterIn.AUF_EMPF_CD.extend; L_FilterIn.AUF_EMPF_CD(L_FilterIn.AUF_EMPF_CD.last) := SRYI_C2_1('GO');
   -- Filter auf Titellieferungspartner ----------------------------------------------------------------------------------------------
   L_FilterIn.TL_PTN_LNR := SRYI_I22_1(22363699169887); -- Telefonhandel
   L_FilterIn.PAGING_SIZE := SRYI_I14_1(10000); -- Anzahl der Einträge pro Seite
   SIBU_TEST_AUFTRAG_HEADERS(P_TestFilter => L_FilterIn);
end;
/


-- Testfilter #6 : Alle Orders aus Test #5 zusätzlich gefiltert nach Börsenplätzen:
--       4        Swiss Exchange
--       65	      NYSE Euronext
--       380	   SIX Swiss Exchange - Blue Chips Segment
--       5	      BX Swiss AG, BX Listed
--       13	      Deutsche Boerse AG
--       900006	Best Execution
--       21	      Eurex Deutschland
--
-- select   count(*)
-- from     b2_auf            a
-- where    1=1
--    and   a.userbk_nr = F2QAPENV.F_UB
--    and   (a.kt_lnr is null or exists (select null from ktwi_stamm_3 k where k.kt_lnr = a.kt_lnr))
--    and   (a.kt_lnr_kt is null or exists (select null from ktwi_stamm_3 k where k.kt_lnr = a.kt_lnr_kt))
--    and   a.obj_stat_cd in (120,800)
--    and   a.BO_AUF_TYP_CD in ('E', 'L')
--    and   a.AUF_ART_CD in ('10','110')      -- Nur Kundenaufträge
--    and   a.VL_REF_LNR in 
--          (
--             133452055056,   -- IBM Rg
--             33338337572328, -- Nestle N
--             176311577225,   -- ABB N
--             26056108462216, -- Schindler Hldg N
--             17415196094616  -- Orell Fuessli N
--          )
--    and   a.auf_empf_cd in ('IA', 'TF', 'GO')
--    and   a.TL_PTN_LNR = 22363699169887 -- Telefonhandel
--    and   a.bo_platz_lnr in (4, 65, 380, 5, 13, 900006, 21)
-- ;
--
declare
   L_FilterIn        B2YI_AUFTRAGHEADER_FILTER_1 := B2YI_AUFTRAGHEADER_FILTER_1();
begin
   -- Filter auf Valoren ----------------
   L_FilterIn.VL_REF_LNR := SRCI_I22_1(); -- Initialize the Valoren array
   L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(133452055056);      -- IBM Rg
   L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(33338337572328);    -- Nestle N
   L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(176311577225);      -- ABB N
   L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(26056108462216);    -- Schindler Hldg N
   L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(17415196094616);    -- Orell Fuessli N
   -- Filter auf Status-Code
   L_FilterIn.OBJ_STAT_CD := SRCI_I3_1(); -- Initialize the status code array
   L_FilterIn.OBJ_STAT_CD.extend; L_FilterIn.OBJ_STAT_CD(L_FilterIn.OBJ_STAT_CD.last) := SRYI_I3_1(120); -- OrderStatus: 120 = Ausgeführt
   L_FilterIn.OBJ_STAT_CD.extend; L_FilterIn.OBJ_STAT_CD(L_FilterIn.OBJ_STAT_CD.last) := SRYI_I3_1(800); -- OrderStatus: 800 = Verbucht
   -- Felter auf Auftragsherkunft ------------------
   L_FilterIn.AUF_EMPF_CD := SRCI_C2_1(); -- Initialize the Auftragsherkunft array
   L_FilterIn.AUF_EMPF_CD.extend; L_FilterIn.AUF_EMPF_CD(L_FilterIn.AUF_EMPF_CD.last) := SRYI_C2_1('IA');
   L_FilterIn.AUF_EMPF_CD.extend; L_FilterIn.AUF_EMPF_CD(L_FilterIn.AUF_EMPF_CD.last) := SRYI_C2_1('TF');
   L_FilterIn.AUF_EMPF_CD.extend; L_FilterIn.AUF_EMPF_CD(L_FilterIn.AUF_EMPF_CD.last) := SRYI_C2_1('GO');
   -- Filter auf Titellieferungspartner ----------------------------------------------------------------------------------------------
   L_FilterIn.TL_PTN_LNR := SRYI_I22_1(22363699169887); -- Telefonhandel
   -- Filter auf Börsenplatz -----------------------
   L_FilterIn.BO_PLATZ_LNR := SRCI_I22_1(); -- Initialize the Börsenplatz array
   L_FilterIn.BO_PLATZ_LNR.extend; L_FilterIn.BO_PLATZ_LNR(L_FilterIn.BO_PLATZ_LNR.last) := SRYI_I22_1(4);        -- Swiss Exchange
   L_FilterIn.BO_PLATZ_LNR.extend; L_FilterIn.BO_PLATZ_LNR(L_FilterIn.BO_PLATZ_LNR.last) := SRYI_I22_1(65);       -- NYSE Euronext
   L_FilterIn.BO_PLATZ_LNR.extend; L_FilterIn.BO_PLATZ_LNR(L_FilterIn.BO_PLATZ_LNR.last) := SRYI_I22_1(380);      -- SIX Swiss Exchange - Blue Chips Segment
   L_FilterIn.BO_PLATZ_LNR.extend; L_FilterIn.BO_PLATZ_LNR(L_FilterIn.BO_PLATZ_LNR.last) := SRYI_I22_1(5);        -- BX Swiss AG, BX Listed
   L_FilterIn.BO_PLATZ_LNR.extend; L_FilterIn.BO_PLATZ_LNR(L_FilterIn.BO_PLATZ_LNR.last) := SRYI_I22_1(13);       -- Deutsche Boerse AG
   L_FilterIn.BO_PLATZ_LNR.extend; L_FilterIn.BO_PLATZ_LNR(L_FilterIn.BO_PLATZ_LNR.last) := SRYI_I22_1(900006);   -- Best Execution
   L_FilterIn.BO_PLATZ_LNR.extend; L_FilterIn.BO_PLATZ_LNR(L_FilterIn.BO_PLATZ_LNR.last) := SRYI_I22_1(21);       -- Eurex Deutschland
   L_FilterIn.PAGING_SIZE := SRYI_I14_1(10000); -- Anzahl der Einträge pro Seite
   SIBU_TEST_AUFTRAG_HEADERS(P_TestFilter => L_FilterIn);
end;
/

-- Testfilter #7 : Alle Orders aus Test #5 zusätzlich gefiltert nach Währungen CHF und EUR
--
-- select   a.hwrg_lnr,
--          w.bez_lang,
--          count(*) num_auf
-- from     b2_auf            a
--          inner join al1wrg w on w.userbk_nr = a.userbk_nr and w.wrg_lnr = a.hwrg_lnr and w.sprache_cd = 1
-- where    1=1
--    and   a.userbk_nr = F2QAPENV.F_UB
--    and   (a.kt_lnr is null or exists (select null from ktwi_stamm_3 k where k.kt_lnr = a.kt_lnr))
--    and   (a.kt_lnr_kt is null or exists (select null from ktwi_stamm_3 k where k.kt_lnr = a.kt_lnr_kt))
--    and   a.obj_stat_cd in (120,800)
--    and   a.BO_AUF_TYP_CD in ('E', 'L')
--    and   a.AUF_ART_CD in ('10','110')      -- Nur Kundenaufträge
--    and   a.VL_REF_LNR in (133452055056,33338337572328,176311577225,26056108462216,17415196094616)
--    and   a.auf_empf_cd in ('IA', 'TF', 'GO')
--    and   a.TL_PTN_LNR = 22363699169887 -- Telefonhandel
--    and   a.bo_platz_lnr in (4, 65, 380, 5, 13, 900006, 21)
-- group    by a.hwrg_lnr,
--             w.bez_lang
-- order    by num_auf desc
-- ;
--
declare
   L_FilterIn        B2YI_AUFTRAGHEADER_FILTER_1 := B2YI_AUFTRAGHEADER_FILTER_1();
begin
   -- Filter auf Valoren ----------------
   L_FilterIn.VL_REF_LNR := SRCI_I22_1(); -- Initialize the Valoren array
   L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(133452055056);      -- IBM Rg
   L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(33338337572328);    -- Nestle N
   L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(176311577225);      -- ABB N
   L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(26056108462216);    -- Schindler Hldg N
   L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(17415196094616);    -- Orell Fuessli N
   -- Filter auf Status-Code
   L_FilterIn.OBJ_STAT_CD := SRCI_I3_1(); -- Initialize the status code array
   L_FilterIn.OBJ_STAT_CD.extend; L_FilterIn.OBJ_STAT_CD(L_FilterIn.OBJ_STAT_CD.last) := SRYI_I3_1(120); -- OrderStatus: 120 = Ausgeführt
   L_FilterIn.OBJ_STAT_CD.extend; L_FilterIn.OBJ_STAT_CD(L_FilterIn.OBJ_STAT_CD.last) := SRYI_I3_1(800); -- OrderStatus: 800 = Verbucht
   -- Felter auf Auftragsherkunft ------------------
   L_FilterIn.AUF_EMPF_CD := SRCI_C2_1(); -- Initialize the Auftragsherkunft array
   L_FilterIn.AUF_EMPF_CD.extend; L_FilterIn.AUF_EMPF_CD(L_FilterIn.AUF_EMPF_CD.last) := SRYI_C2_1('IA');
   L_FilterIn.AUF_EMPF_CD.extend; L_FilterIn.AUF_EMPF_CD(L_FilterIn.AUF_EMPF_CD.last) := SRYI_C2_1('TF');
   L_FilterIn.AUF_EMPF_CD.extend; L_FilterIn.AUF_EMPF_CD(L_FilterIn.AUF_EMPF_CD.last) := SRYI_C2_1('GO');
   -- Filter auf Titellieferungspartner ----------------------------------------------------------------------------------------------
   L_FilterIn.TL_PTN_LNR := SRYI_I22_1(22363699169887); -- Telefonhandel
   -- Filter auf Börsenplatz -----------------------
   L_FilterIn.BO_PLATZ_LNR := SRCI_I22_1(); -- Initialize the Börsenplatz array
   L_FilterIn.BO_PLATZ_LNR.extend; L_FilterIn.BO_PLATZ_LNR(L_FilterIn.BO_PLATZ_LNR.last) := SRYI_I22_1(4);        -- Swiss Exchange
   L_FilterIn.BO_PLATZ_LNR.extend; L_FilterIn.BO_PLATZ_LNR(L_FilterIn.BO_PLATZ_LNR.last) := SRYI_I22_1(65);       -- NYSE Euronext
   L_FilterIn.BO_PLATZ_LNR.extend; L_FilterIn.BO_PLATZ_LNR(L_FilterIn.BO_PLATZ_LNR.last) := SRYI_I22_1(380);      -- SIX Swiss Exchange - Blue Chips Segment
   L_FilterIn.BO_PLATZ_LNR.extend; L_FilterIn.BO_PLATZ_LNR(L_FilterIn.BO_PLATZ_LNR.last) := SRYI_I22_1(5);        -- BX Swiss AG, BX Listed
   L_FilterIn.BO_PLATZ_LNR.extend; L_FilterIn.BO_PLATZ_LNR(L_FilterIn.BO_PLATZ_LNR.last) := SRYI_I22_1(13);       -- Deutsche Boerse AG
   L_FilterIn.BO_PLATZ_LNR.extend; L_FilterIn.BO_PLATZ_LNR(L_FilterIn.BO_PLATZ_LNR.last) := SRYI_I22_1(900006);   -- Best Execution
   L_FilterIn.BO_PLATZ_LNR.extend; L_FilterIn.BO_PLATZ_LNR(L_FilterIn.BO_PLATZ_LNR.last) := SRYI_I22_1(21);       -- Eurex Deutschland
   -- Filter auf Wähung ----------------------------
   L_FilterIn.HWRG_LNR := SRCI_I22_1(); -- Initialize the Währung array
   L_FilterIn.HWRG_LNR.extend; L_FilterIn.HWRG_LNR(L_FilterIn.HWRG_LNR.last) := SRYI_I22_1(1); -- CHF
   L_FilterIn.HWRG_LNR.extend; L_FilterIn.HWRG_LNR(L_FilterIn.HWRG_LNR.last) := SRYI_I22_1(814); -- EUR
   L_FilterIn.PAGING_SIZE := SRYI_I14_1(10000); -- Anzahl der Einträge pro Seite
   SIBU_TEST_AUFTRAG_HEADERS(P_TestFilter => L_FilterIn);
end;
/

-- Testfilter #8 : Alle Orders mit Status 800 und Datum Gültig von ab 2026-01-20 12:00:00
--
-- select   count(*) num_auf
-- from     b2_auf            a
-- where    1=1
--    and   a.userbk_nr = F2QAPENV.F_UB
--    and   (a.kt_lnr is null or exists (select null from ktwi_stamm_3 k where k.kt_lnr = a.kt_lnr))
--    and   (a.kt_lnr_kt is null or exists (select null from ktwi_stamm_3 k where k.kt_lnr = a.kt_lnr_kt))
--    and   a.obj_stat_cd in (800)
--    and   a.BO_AUF_TYP_CD in ('E', 'L')
--    and   a.AUF_ART_CD in ('10','110')      -- Nur Kundenaufträge
-- ;
--
declare
   L_FilterIn        B2YI_AUFTRAGHEADER_FILTER_1 := B2YI_AUFTRAGHEADER_FILTER_1();
begin
   -- Filter auf Status-Code
   L_FilterIn.OBJ_STAT_CD := SRCI_I3_1(); -- Initialize the status code array
   L_FilterIn.OBJ_STAT_CD.extend; L_FilterIn.OBJ_STAT_CD(L_FilterIn.OBJ_STAT_CD.last) := SRYI_I3_1(800); -- OrderStatus: 800 = Verbucht
   L_FilterIn.VALID_VON_DT_FROM := to_date('2026-01-20 12:00:00', 'YYYY-MM-DD HH24:MI:SS');
   L_FilterIn.PAGING_SIZE := SRYI_I14_1(10000); -- Anzahl der Einträge pro Seite
   SIBU_TEST_AUFTRAG_HEADERS(P_TestFilter => L_FilterIn);
end;
/





select   a.auf_lnr,
         a.valid_von_dt,
         a.valid_bis_dt
from     b2_auf            a
where    1=1
   and   a.userbk_nr = F2QAPENV.F_UB
   and   (a.kt_lnr is null or exists (select null from ktwi_stamm_3 k where k.kt_lnr = a.kt_lnr))
   and   (a.kt_lnr_kt is null or exists (select null from ktwi_stamm_3 k where k.kt_lnr = a.kt_lnr_kt))
   and   a.obj_stat_cd in (120,800)
   and   a.BO_AUF_TYP_CD in ('E', 'L')
   and   a.AUF_ART_CD in ('10','110')      -- Nur Kundenaufträge
   and   a.VL_REF_LNR in (133452055056,33338337572328,176311577225,26056108462216,17415196094616)
   and   a.auf_empf_cd in ('IA', 'TF', 'GO')
   and   a.TL_PTN_LNR = 22363699169887 -- Telefonhandel
   and   a.bo_platz_lnr in (4, 65, 380, 5, 13, 900006, 21)
   and   a.hwrg_lnr in (1, 814) -- CHF, EUR
   and   a.valid_von_dt >= to_date('2026-01-20 12:00:00', 'YYYY-MM-DD HH24:MI:SS')
   -- and   a.VALID_VON_DT between to_date('2023-01-01', 'YYYY-MM-DD') and to_date('2024-01-01', 'YYYY-MM-DD')
   -- and   a.VALID_BIS_DT between to_date('2023-01-01', 'YYYY-MM-DD') and to_date('2024-01-01', 'YYYY-MM-DD')
order by a.valid_von_dt asc
;

-- -----------------------------------------------------------------------------
--  Show value ranges in all columns of a specific table
-- -----------------------------------------------------------------------------
declare
   l_table_name        varchar2(80 char) := 'B2_AUF';   -- Name of table to be analyzed
   l_table_owner       varchar2(80 char) := '__LDAT__';
   l_max_values        pls_integer       := 10;    -- Number of x most values shown per field
   l_value_width       pls_integer       := 80;    -- Number of characters of values to be shown
   l_with_nulls        boolean           := true;
   l_null_text         varchar2(80 char) := '<null>';
   --
   type tab_char       is table of varchar2(4000) index by pls_integer;
   type tab_bin        is table of pls_integer    index by pls_integer;
   l_tab_values        tab_char;
   l_tab_count         tab_bin;
   l_select            varchar2(4000);
   l_count             pls_integer;
   --
   cursor cur_columns is
      select   *
      from     sys.all_tab_columns
      where    table_name = upper(l_table_name)
          and  owner like upper(l_table_owner)
      order by column_id; --column_name;
begin
   dbms_output.put_line(rpad('-',40+l_value_width,'-'));
   dbms_output.put_line(to_char(sysdate, 'yyyy.mm.dd - hh24:mi:ss : ') || 'Value ranges for table ' || upper(l_table_owner) || '.' || upper(l_table_name));
   dbms_output.put_line(rpad('-',40+l_value_width,'-'));
   for rec_column in cur_columns loop
      l_select := 'select count(distinct to_char(' || rec_column.column_name || ')) from ' || l_table_owner || '.' || l_table_name;
      dbms_output.put_line(l_select);
      execute immediate l_select into l_count;
      dbms_output.put_line(rpad(rec_column.column_name,l_value_width+6,'.') || ' : ' || lpad(to_char(l_count,'999G999G999G999', 'NLS_NUMERIC_CHARACTERS=''.'''''),15,' ') || '  (' || rec_column.data_type || ')');
      l_select := 'select coalesce(replace(to_char(' || rec_column.column_name || '),chr(10),''|''),''' || l_null_text || ''') as value, count(*) as cnt from ' || l_table_owner || '.' || l_table_name || case when l_with_nulls then '' else ' where ' || rec_column.column_name || ' is not null' end || ' group by ' || rec_column.column_name|| ' order by case when value = ''' || l_null_text || ''' then 999999999 else cnt end desc fetch first ' || l_max_values || ' rows only';
      execute immediate l_select bulk collect into l_tab_values, l_tab_count;
      for j in 1 .. least(l_tab_values.count,l_max_values) loop
         dbms_output.put_line('      ' || rpad(l_tab_values(j),l_value_width) || ' : ' || lpad(to_char(l_tab_count(j),'999G999G999G999', 'NLS_NUMERIC_CHARACTERS=''.'''''),15,' '));
      end loop;
   end loop;
end;
/

      select   *
      from     sys.all_tab_columns
      where    table_name = upper('b2_auf')
        --and  owner like upper('F%') --LDATP0')
      order by column_id; --column_name;


-- --------------------------------------------------------------------------------
--  Protocol table
-- --------------------------------------------------------------------------------

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

--Login
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

/*
OBJ_STAT_CD    BEZ_LANG                    ANZAHL_TOTAL    ANZAHL_E_L                  
20             Nachbearbeiten              65              13                          
40             Visiert                     25              5                           
100            Reserviert bei Händler      7               7                           
105            Platzierung vorgemerkt      10              10                          
110            Platziert                   16              8                           
120            Ausgeführt                  61              9                           
800            Verbucht                    154616          53589                       
910                                        1               1                           
920            Abgelaufen                  3945            1509                        
930            Storniert                   1905            547                         
950            Annulliert                  14773           5165                        
955                                        2               2                           
                                           1               1                           
*/



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

-- Show distinct B2_AUF_ART_CD for userbk_nr = 949 with name and number of orders per type ---------------------------------
select   ba.auf_lnr
from     table( DDQI_DDCLNR22.F_CollStats(DDCLNR22(950), 10000))  filter1
         inner join B2_AUF ba on (filter1.column_value = ba.OBJ_STAT_CD)
where    ba.userbk_nr    = F2QAPENV.F_UB
order by ba.AUF_LNR asc
;

-- Return numbers from 1 to 1000
with w_numbers as
(
   select level as number_value
   from   dual
   connect by level <= 1000
)
select   * 
from  w_numbers
where number_value between 10 and 20;





select   to_char(a.valid_von_dt,'hh24:mi:ss')   as valid_von_time,
         max(a.valid_von_dt)                    as valid_von_max,
         to_char(a.valid_bis_dt,'hh24:mi:ss')   as valid_bis_time,
         max(a.valid_bis_dt)                    as valid_bis_max,
         count(*) num_orders
from     b2_auf            a
where    to_char(a.valid_bis_dt,'hh24:mi:ss') <> '23:59:59'
group by to_char(a.valid_von_dt,'hh24:mi:ss'),
         to_char(a.valid_bis_dt,'hh24:mi:ss')
order by num_orders desc
;




/*

Auftrag aus Abnahmetest:

Typ      KD
GF       Kauf
Menge    34
Einheit  Stück
HWrg     CHF
Valor    52875158 VZ HOlding N
Auftrag  AUF261005-1....
Status   Visiert
Dest     TEL
Art      L

*/


select   vs.vl_nr,
         vs.tk_sym,
         vs.isin_nr,
         vr.vl_ref_lnr,
         vr.vl_ref_text
from     vl_stamm             vs
         inner join  vl_ref   vr    on       vs.vl_nr = vr.vl_nr
                                       and   vr.userbk_nr = vs.userbk_nr   
         inner join  b2_auf   au    on       au.vl_ref_lnr = vr.vl_ref_lnr
                                       and   au.userbk_nr = vs.userbk_nr
where    1=1
   and   vs.userbk_nr = F2QAPENV.F_UB
   and   vs.vl_nr = '52875158'
   and   au.MENGE_AUF = 34


;



declare
   L_FilterIn        B2YI_AUFTRAGHEADER_FILTER_1 := B2YI_AUFTRAGHEADER_FILTER_1();
begin
   L_FilterIn.VL_REF_LNR := SRCI_I22_1(); -- Initialize the Valoren array
   L_FilterIn.VL_REF_LNR.extend; L_FilterIn.VL_REF_LNR(L_FilterIn.VL_REF_LNR.last) := SRYI_I22_1(70566700633005);      -- VZ Holding N
   --
   L_FilterIn.OBJ_STAT_CD := SRCI_I3_1(); -- Initialize the status code array
   L_FilterIn.OBJ_STAT_CD.extend; L_FilterIn.OBJ_STAT_CD(L_FilterIn.OBJ_STAT_CD.last) := SRYI_I3_1(920); -- OrderStatus: 920 = Abgelaufen
   --
   L_FilterIn.VALID_VON_DT_FROM := to_date('2026-10-06', 'YYYY-MM-DD');
   L_FilterIn.VALID_BIS_DT_TO := to_date('2026-10-15', 'YYYY-MM-DD');
   --
   L_FilterIn.PAGING_SIZE := SRYI_I14_1(10000); -- Anzahl der Einträge pro Seite
   --
   SIBU_TEST_AUFTRAG_HEADERS(P_TestFilter => L_FilterIn);
end;
/


select   *
from     b2_auf a 
where    userbk_nr = F2QAPENV.F_UB 
   and   bo_auf_typ_cd in ('E', 'L') 
   and   a.auf_art_cd in ('10','110') 
   and   (a.kt_lnr is null or exists (select null from ktwi_stamm_3 k where k.kt_lnr = a.kt_lnr)) 
   and   (a.kt_lnr_kt is null or exists (select null from ktwi_stamm_3 k where k.kt_lnr = a.kt_lnr_kt)) 
   and   a.VL_REF_LNR in (70566700633005) 
   and   a.OBJ_STAT_CD in (920);


select count(*) from b2_auf a where userbk_nr = F2QAPENV.F_UB and bo_auf_typ_cd in ('E', 'L') and a.auf_art_cd in ('10','110') and (a.kt_lnr is null or exists (select null from ktwi_stamm_3 k where k.kt_lnr = a.kt_lnr)) and (a.kt_lnr_kt is null or exists (select null from ktwi_stamm_3 k where k.kt_lnr = a.kt_lnr_kt)) and a.VL_REF_LNR in (52875158) and a.OBJ_STAT_CD in (920)

