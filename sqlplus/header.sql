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
   L_FilterIn       B2YI_AUFTRAGHEADER_FILTER_1 := B2YI_AUFTRAGHEADER_FILTER_1();
   L_FilterBL       B2YF_BL_ORDER_FILTER := B2YF_BL_ORDER_FILTER();
   L_Result         B2YI_AUFTRAGHEADER_RESPONSE_1;
   L_ValorRefs      SRCI_I22_1 := SRCI_I22_1();
   L_OrderStats     SRCI_I3_1 := SRCI_I3_1();
   --
   L_PageCursorRet    B2QF_BL_ORDER.T_PAGE_CURSOR_RET       := B2QF_BL_ORDER.T_PAGE_CURSOR_RET();
   L_CountHeaders     integer := 0;
   L_CountPages       integer := 0;
   L_CountText        integer := 0;
begin
   dbms_output.put_line('LogLevel B2: ' || G_LogLevel || ' - ' || case G_LogLevel when 8	then 'TRACE' when 7 then 'DEBUG' when 6 then 'INFO' when 5 then 'WARNING' when 4 then 'ERROR' end);
   G_LoginReturn := F2QLOGIN.F_SetUser('MD1AT', 'berlin08', 949);
   if G_LoginReturn != 'OK' then   
      DBMS_OUTPUT.PUT_LINE('Login fehlgeschlagen: ' || G_LoginReturn);
      return;
   end if;
   DBMS_OUTPUT.PUT_LINE('Login erfolgreich!');
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
   -- Init test filter ----------------
   L_ValorRefs.extend; L_ValorRefs(L_ValorRefs.last) := SRYI_I22_1(14829634088459); -- AAPL
   L_ValorRefs.extend; L_ValorRefs(L_ValorRefs.last) := SRYI_I22_1(133452026803); -- Deutsche Bank N
   L_FilterIn.VL_REF_LNR := L_ValorRefs;
   -- L_OrderStats.extend; L_OrderStats(L_OrderStats.last) := SRYI_I3_1(120); -- OrderStatus: 120 = Ausgeführt
   -- L_OrderStats.extend; L_OrderStats(L_OrderStats.last) := SRYI_I3_1(800); -- OrderStatus: 800 = Verbucht
   -- L_OrderStats.extend; L_OrderStats(L_OrderStats.last) := SRYI_I3_1(920); -- OrderStatus: 920 = Abgelaufen
   -- L_OrderStats.extend; L_OrderStats(L_OrderStats.last) := SRYI_I3_1(930); -- OrderStatus: 930 = Storniert
   L_OrderStats.extend; L_OrderStats(L_OrderStats.last) := SRYI_I3_1(930); -- OrderStatus: 930 = Storniert
   L_FilterIn.OBJ_STAT_CD := L_OrderStats;
   L_FilterIn.PAGING_SIZE := SRYI_I14_1(2); -- Anzahl der Einträge pro Seite
   --
   loop
      L_Result := b2qi_trading_1.F_ReadBoersenauftragHeaders(P_Filter => L_FilterIn);
      L_CountPages := L_CountPages + 1;
      DBMS_OUTPUT.PUT_LINE('Page #' || L_CountPages || ' with ' || L_Result.AUFTRAGHEADER_LIST.count || ' headers:');
      <<header_loop>>
      for i in 1 .. L_Result.AUFTRAGHEADER_LIST.count loop
      -- for i in 1 .. 5 loop
         L_CountHeaders := L_CountHeaders + 1;
         DBMS_OUTPUT.PUT_LINE('   - ' || to_char(L_CountHeaders,'000G000') || ': ' || L_Result.AUFTRAGHEADER_LIST(i).F_ToString());
         -- if cardinality(L_Result.AUFTRAGHEADER_LIST(i).OM_TEXTE) > 0 then
         --    for j in 1 .. cardinality(L_Result.AUFTRAGHEADER_LIST(i).OM_TEXTE) loop
         --       DBMS_OUTPUT.PUT_LINE('      - ' || L_Result.AUFTRAGHEADER_LIST(i).OM_TEXTE(j).TEXT_REC);
         --    end loop;
         -- end if;
         L_CountText := L_CountText + coalesce(cardinality(L_Result.AUFTRAGHEADER_LIST(i).OM_TEXTE), 0);
      end loop header_loop;
      exit when L_Result.PAGING_CURSOR is null;
      DBMS_OUTPUT.PUT_LINE('   Cursor : ' || coalesce(L_Result.PAGING_CURSOR, '<<null>>'));
      -- Update the cursor for the next iteration
      L_FilterIn.PAGING_CURSOR := SRYI_C50_1(L_Result.PAGING_CURSOR);
   end loop;
   -- output counters
   DBMS_OUTPUT.PUT_LINE('Total Order Headers returned: ' || L_CountHeaders);
   DBMS_OUTPUT.PUT_LINE('Total Pages read: ' || L_CountPages);
   DBMS_OUTPUT.PUT_LINE('Total Texts read: ' || L_CountText);
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
   --commit;
   rollback;
end;
/
