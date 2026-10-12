declare
   G_LoginReturn     varchar2(30 char); --Variabel für den Return-Wert der Login-Funktion
begin
   G_LoginReturn :=  f2qlogin.F_SetUser(
                        P_ID => 'MD1AT',        -- User identification
                        P_PW => 'berlin08',     -- User password
                        P_UB => 949,                 -- Login Bank
                        P_SP => 1                    -- GUI Language 1=D 2=F 3=I 4=R 5=E
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

DECLARE
   G_LoginReturn     varchar2(30 char); --Variabel für den Return-Wert der Login-Funktion
   PROCEDURE TestProc(
       PI_VlRefLnr IN NUMBER
      ,PI_KtArtNr  IN B2QF_ORDER_TYPE.C_KT_ART_NR
   ) AS
      L_KtArtList             varchar2(4000 char);
      L_KtArtNrDistinct       B2QF_ORDER_TYPE.C_KT_ART_NR;
   BEGIN
         select distinct column_value bulk collect into L_KtArtNrDistinct from table(PI_KtArtNr) where column_value is not null;
         dbms_output.put_line('Distinct KtArtNr: ' || cardinality(L_KtArtNrDistinct));
         select listagg(distinct column_value,',' on overflow truncate '...') within group (order by rownum) into L_KtArtList from table(PI_KtArtNr);
         dbms_output.put_line('Distinct KtArtList: ' || L_KtArtList);
         -- for i in 1..cardinality(PI_KtArtNr) loop
         --    dbms_output.put_line('    Loop iteration: ' || i || ' Value: ' || coalesce(to_char(PI_KtArtNr(i)),'<null>'));
         -- end loop;
   END TestProc;
BEGIN
   G_LoginReturn := F2QLOGIN.F_SetUser('MD1AT', 'berlin08', 949);
   if G_LoginReturn != 'OK' then   
      DBMS_OUTPUT.PUT_LINE('Login fehlgeschlagen: ' || G_LoginReturn);
      return;
   end if;
   DBMS_OUTPUT.PUT_LINE('Login erfolgreich!');
   TestProc(1, NULL);
   TestProc(2, B2QF_ORDER_TYPE.C_KT_ART_NR(NULL));
   TestProc(3, B2QF_ORDER_TYPE.C_KT_ART_NR(160,180,160));
END;
/




select   ka.kt_art_nr,
         ka.BEZ_KURZ     as kt_art_bez_kurz,
       --ka.BEZ_MITTEL   as kt_art_bez_mittel,
         ka.BEZ_LANG     as kt_art_bez_lang,
         az.grp_art,
         ga.BEZ_KURZ     as grp_art_bez_kurz,
         ga.BEZ_MITTEL   as grp_art_bez_mittel,
       --ga.BEZ_LANG     as grp_art_bez_lang,
         az.gnr,
         gr.BEZ_KURZ     as gnr_bez_kurz,
         gr.BEZ_MITTEL   as gnr_bez_mittel,
         gr.BEZ_LANG     as gnr_bez_lang
from     kt1art                     ka
         inner join  kt_art_zuo     az on    az.kt_art_nr = ka.kt_art_nr 
                                       and   az.userbk_nr = ka.userbk_nr
         inner join sr1tabga        ga on    ga.userbk_nr = ka.userbk_nr
                                       and   ga.sprache_cd = ka.sprache_cd
                                       and   ga.tab_bez = 'KT_ART'
                                       and   ga.GRP_ART = az.GRP_ART
         inner join sr1tabg         gr on    gr.userbk_nr = ka.userbk_nr
                                       and   gr.sprache_cd = ka.sprache_cd
                                       and   gr.GNR = az.GNR
                                       and   gr.GRP_ART = az.GRP_ART
where    ka.userbk_nr = 949
   and   ka.sprache_cd = 1
   and   az.gnr = 10
   and   az.GRP_ART = 5339
order by ka.kt_art_nr      asc,
         az.grp_art        asc,
         az.gnr            asc
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
   Insert your test code here...
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
                    '%%'        as  table_name,
                    '%COPA%'        as  column_name
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


select   *
from     b2_fix_copa    copa
where    1=1
   and   copa.userbk_nr = 949
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
where   ob.owner like upper('%')
    and ob.object_name like upper('it%')
order   by  ob.object_type,
            ob.owner,
            ob.object_name
;



begin
   dbms_output.put_line(B2QCNST0.K_ZVKT_ID_FIX);
end;
/


-- parse the delimited string into row values using a common table expression (CTE) and the `regexp_substr` function
with cte as (
   select 'USERBK_NR,BO_AUF_TYP_CD,GF_NR,GNR_GF,BO_PLATZ_LNR' as csv_string
   from   dual
)
, w_columns as (
   select regexp_substr(csv_string, '[^,]+', 1, level) as column_name
   from   cte
   connect by regexp_substr(csv_string, '[^,]+', 1, level) is not null
)
select   *
from     sys.all_tab_columns
         inner join  w_columns wc
         on  wc.column_name = all_tab_columns.column_name
where    table_name  = upper(l_table_name)
      and  column_name like upper(l_column_name)
      and  owner like upper(l_table_owner)
order by column_id; --column_name;
