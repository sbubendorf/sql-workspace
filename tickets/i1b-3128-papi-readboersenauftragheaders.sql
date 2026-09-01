/*

    Fragen an Herbert:

    - b2qi_trading_1_types.sql

        - Warning CID?
        - Keine enum für B2_HAND_INSTR_CD       --> B2W_lookup_view

    - b2qi_trading_1.sql

        - Limit und Cursor im Type übergeben oder separat?
        - BL-Function im b2qf_bl_trade oder b2qf_bl_order?


*/



select  *
from    b2_auf
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
    and ob.object_name like upper('b2y%')
    and upper(so.source_code) like upper('%b2_hand_instr_cd%')
order   by  ob.object_type,
            ob.owner,
            ob.object_name
;

-- Show all colums of a given table with comments ------------------------------
select  tcol.owner,
        tcol.table_name,
        tcol.column_id      as  col_id,
        tcol.column_name,
        tcol.data_type,
        tcol.data_length,
        tcol.data_precision,
        tcol.data_scale,
        tcol.nullable,
        tcol.num_distinct,
        comm.comments
from    (
            select  '%DAT%'     as  owner_name,
                    'b2_auf%'        as  table_name,
                    'tl_ptn%'        as  column_name
            from    dual
        )                                   sett
        inner join  sys.all_tab_columns     tcol    on  tcol.owner          like upper(sett.owner_name)
                                                    and tcol.table_name     like upper(sett.table_name)
                                                    and tcol.column_name    like upper(sett.column_name)
        left  join  sys.all_col_comments    comm    on  comm.owner          = tcol.owner
                                                    and comm.table_name     = tcol.table_name
                                                    and comm.column_name    = tcol.column_name
order   by  tcol.owner,
            tcol.table_name,
            tcol.column_id;


select  *
from    b21hand_instr
where   rownum < 10
;


select  ob.object_type, ob.owner, ob.object_name, ob.status,
        to_char(trunc(ob.created),'yyyy.mm.dd')                 as  created,
        to_char(trunc(ob.last_ddl_time),'yyyy.mm.dd')           as  last_ddl
from    sys.all_objects         ob
where   ob.owner like upper('F2LDATP0')
    and ob.object_name like upper('b2qe%')
order   by  ob.object_type,
            ob.owner,
            ob.object_name
;





declare
   G_HProfDirectory  VARCHAR2(20 CHAR) := 'MANIFEST_DIR';            -- Directory-Objekt für HPROF-Ausgabe
   G_HProfFilename   VARCHAR2(50 CHAR) := 'b2_test_' || to_char(sysdate,'YYYYMMDDHH24MISS') || '.trc';  -- Dateiname für HPROF-Ausgabe
   G_HProfEnabled    BOOLEAN := FALSE; -- Flag, um HPROF-Teil des Codes zu aktivieren/deaktivieren
    --
    G_LoginReturn    VARCHAR2(30 CHAR); --Variabel für den Return-Wert der Login-Funktion
    G_EvtStartTime   TIMESTAMP; --Variable für die Startzeit der Operation
    G_EvtEndTime     TIMESTAMP; --Variable für die Endzeit der Operation
    G_Result         INTEGER; --Variable für den Return-Wert der Löschungs-Funktion
    --
    L_Filter         B2YI_AUFTRAGHEADER_FILTER_1;
    L_Headers        B2YI_AUFTRAGHEADER_1;
    L_ValorRefs      SRCI_I22_1 := SRCI_I22_1();
    L_OrderStats     SRCI_I3_1 := SRCI_I3_1();
begin
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
   --
   dbms_output.put_line('Start reading BoersenauftragHeaders...');
   L_Filter := B2YI_AUFTRAGHEADER_FILTER_1();
   L_ValorRefs.extend(1);
   L_ValorRefs(1) := SRYI_I22_1(14829634088459); -- AAPL
   L_Filter.VL_REF_LNR := L_ValorRefs;
   L_OrderStats.extend(3);
   L_OrderStats(1) := SRYI_I3_1(950); -- OrderStatus: 950 = Order in Bearbeitung
   L_OrderStats(2) := SRYI_I3_1(960); -- OrderStatus: 930 
   L_OrderStats(3) := SRYI_I3_1(970); -- OrderStatus: 920 
   L_Filter.OBJ_STAT_CD := L_OrderStats;
   L_Headers := B2QI_TRADING_1.F_ReadBoersenauftragHeaders(
      P_Filters => L_Filter,
      P_Limit   => 10000,
      P_Cursor  => NULL
   );
   dbms_output.put_line('Finished reading BoersenauftragHeaders. Found ' || L_Headers.count || ' headers.');
   --
   G_EvtEndTime := SYSTIMESTAMP;
   --
   -- Stop profiling
   if G_HProfEnabled then
      DBMS_HPROF.STOP_PROFILING;
   end if;
   DBMS_OUTPUT.PUT_LINE('Execution time: ' || (G_EvtEndTime - G_EvtStartTime));
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




declare
    L_Filter         B2YI_AUFTRAGHEADER_FILTER_1;
    L_Headers        B2YI_AUFTRAGHEADER_1;
    L_ValorRefs      SRCI_I22_1 := SRCI_I22_1();
    L_OrderStats     SRCI_I3_1 := SRCI_I3_1();
begin
   dbms_output.put_line('Start reading BoersenauftragHeaders...');
   L_Filter := B2YI_AUFTRAGHEADER_FILTER_1();
   L_ValorRefs.extend(1);
   L_ValorRefs(1) := 14829634088459; -- AAPL
   L_Filter.VL_REF_LNR := L_ValorRefs;
   L_OrderStats.extend(3);
   L_OrderStats(1) := 950; -- OrderStatus: 950 = Order in Bearbeitung
   L_OrderStats(2) := 960; -- OrderStatus: 930 
   L_OrderStats(3) := 970; -- OrderStatus: 920 
   L_Filter.OBJ_STAT_CD := L_OrderStats;
   --commit;
   rollback;
end;
/

declare
    L_ValorRefs      SRCI_I22_1 := SRCI_I22_1();
begin
   L_ValorRefs.extend(1);
   L_ValorRefs(1) := SRYI_I22_1(123); -- AAPL
end;
/




select   a.OBJ_STAT_CD, count(*) as ANZ
from     b2_auf   a
where    1=1  
   and   a.USERBK_NR = 949
   and   a.VL_REF_LNR in (14829634088459)
group by a.OBJ_STAT_CD
order by a.OBJ_STAT_CD;


select   *
from     om1obj_typ_stat
where    obj_typ_stat_cd like '%800'
;




declare
      P_OrderFilter     B2YI_AUFTRAGHEADER_FILTER_1 := B2YI_AUFTRAGHEADER_FILTER_1();
      L_OrderFilter     B2YF_BL_ORDER_FILTER := B2YF_BL_ORDER_FILTER();
begin
   L_OrderFilter.VL_REF_LNR_TBL := F_KonvertiereZumDDCLNR22(P_OrderFilter.VL_REF_LNR);
end;
/


-- --------------------------------------------------------------------------------
--  Testing B2QF_BL_ORDER.F_ReadPages
-- --------------------------------------------------------------------------------

declare
   G_LoginReturn       VARCHAR2(30 CHAR); --Variabel für den Return-Wert der Login-Funktion
   G_EvtStartTime      TIMESTAMP; --Variable für die Startzeit der Operation
   G_EvtEndTime        TIMESTAMP; --Variable für die Endzeit der Operation
   G_Result            INTEGER; --Variable für den Return-Wert der Löschungs-Funktion
   --
   L_FilterIn          B2YF_BL_ORDER_FILTER := B2YF_BL_ORDER_FILTER();
   L_ValorRefs         DDCLNR22 := DDCLNR22();
   L_OrderStats        DDCNUMBER := DDCNUMBER();
   L_HeadersPage       B2YF_BL_ORDER.T_PAGE_CURSOR_RET := B2YF_BL_ORDER.T_PAGE_CURSOR_RET();
begin
   G_LoginReturn := F2QLOGIN.F_SetUser('MD1AT', 'berlin08', 949);
   if G_LoginReturn != 'OK' then   
      DBMS_OUTPUT.PUT_LINE('Login fehlgeschlagen: ' || G_LoginReturn);
      return;
   end if;
   DBMS_OUTPUT.PUT_LINE('Login erfolgreich!');
   --
   G_EvtStartTime := SYSTIMESTAMP;
   --
   L_ValorRefs.extend(1);
   L_ValorRefs(1) := SRYI_I22_1(14829634088459); -- AAPL
   L_Filter.VL_REF_LNR := L_ValorRefs;
   L_OrderStats.extend(3);
   L_OrderStats(1) := SRYI_I3_1(950); -- OrderStatus: 950 = Order in Bearbeitung
   L_OrderStats(2) := SRYI_I3_1(960); -- OrderStatus: 930 
   L_OrderStats(3) := SRYI_I3_1(970); -- OrderStatus: 920 
   L_Filter.OBJ_STAT_CD := L_OrderStats;
   --
   L_HeadersPage := B2QF_BL_ORDER.F_ReadPages(
      P_Filters => L_Filter,
      P_Limit   => 10,
      P_Cursor  => NULL
   );
   --
   dbms_output.put_line('Finished reading BoersenauftragHeaders. Found ' || L_HeadersPage.EINTRAEGE.count || ' headers.');
   --
   G_EvtEndTime := SYSTIMESTAMP;
   --
   DBMS_OUTPUT.PUT_LINE('Execution time: ' || (G_EvtEndTime - G_EvtStartTime));
   --commit;
   rollback;
exception
   when others then
      DBMS_OUTPUT.PUT_LINE('sqlerrm = '|| sqlerrm);
      SRQMESS0.DumpMessages(); --Finnova spezifisches Log ausgeben
end;
/

-- genereate a test table with 100 random numbers using dual and connect by level
select  trunc(dbms_random.value(1, 1000)) as random_number
from    dual
connect by level <= 100;

-- genarate a table with 100 random real person names using dual and connect by level
select  dbms_random.string('U', 5) || ' ' || dbms_random.string('U', 7) as random_name
from    dual
connect by level <= 100;



declare
   G_HProfDirectory  varchar2(20 char) := 'MANIFEST_DIR';            -- Directory-Objekt für HPROF-Ausgabe
   G_HProfFilename   varchar2(50 char) := 'b2_test_' || to_char(sysdate,'YYYYMMDDHH24MISS') || '.trc';  -- Dateiname für HPROF-Ausgabe
   G_HProfEnabled    boolean := FALSE; -- Flag, um HPROF-Teil des Codes zu aktivieren/deaktivieren
   --
   G_LoginReturn     varchar2(30 char); --Variabel für den Return-Wert der Login-Funktion
   G_EvtStartTime    timestamp; --Variable für die Startzeit der Operation
   G_EvtEndTime      timestamp; --Variable für die Endzeit der Operation
   --
   L_FilterIn       B2YI_AUFTRAGHEADER_FILTER_1;
   L_Result         B2YI_AUFTRAGHEADER_RESPONSE_1;
   L_ValorRefs      SRCI_I22_1 := SRCI_I22_1();
   L_OrderStats     SRCI_I3_1 := SRCI_I3_1();
begin
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
   L_ValorRefs.extend(1);
   L_ValorRefs(1) := SRYI_I22_1(14829634088459); -- AAPL
   L_FilterIn.VL_REF_LNR := L_ValorRefs;
   L_OrderStats.extend(3);
   L_OrderStats(1) := SRYI_I3_1(950); -- OrderStatus: 950 = Order in Bearbeitung
   L_OrderStats(2) := SRYI_I3_1(960); -- OrderStatus: 930 
   L_OrderStats(3) := SRYI_I3_1(970); -- OrderStatus: 920 
   L_FilterIn.OBJ_STAT_CD := L_OrderStats;
   --
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
   --commit;
   rollback;
-- exception
--    when others then
--       if G_HProfEnabled then
--          DBMS_HPROF.STOP_PROFILING;
--       end if;
--       DBMS_OUTPUT.PUT_LINE('sqlerrm = '|| sqlerrm);
--       SRQMESS0.DumpMessages(); --Finnova spezifisches Log ausgeben
end;
/