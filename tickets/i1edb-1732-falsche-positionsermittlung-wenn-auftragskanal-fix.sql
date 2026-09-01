declare
    L_LoginReturn varchar2(30); --Variabel für den Return-Wert der Login-Funktion
    /*
      PI_TlPtnLnrSrc    => Destination. Empfänger des Auftrags.
      PI_ExtRef         => externer Schlüssel
      PI_KtLnr          => technical number of the deposit
      PI_KtLnrKt        => technical number of the client cash account
      PI_VlRefLnr       => technical number of the security
      PI_ISINNr         => ISIN Nummer
      PI_BoPlatzLnr     => technical number of the security
      PI_HWrgLnr        => technical number of the security
      PI_GfNr           => business case
      PI_OpnCloCd       => Open/Close for options and futures
      PI_MengeAuf       => amount in pieces or nominal of the order
      PI_MengeSichtb    => Auftragsmenge die an der Boerse sichtbar sein darf.
      PI_MengeAufCash   => Auftragsmenge als Gegenwert (Cash-Order)
      PI_KursLim        => limit
      PI_KursLimCd      => kind of limit. Set to '0' by default
      PI_AusloLim       => trigger limit
      PI_ValidBisDt     => validity
      PI_AufEmpfCd      => order origin
      PI_TextHdl        => Text an Händler
      PI_AufComCd       => Übermittelt-Flag
      PI_KdLnrErt       => initiating user
      PO_AufLnr         => order number
    */
    L_PI_TLPTNLNRSRC_0 NUMBER;
    L_PI_EXTREF_0 VARCHAR2(4000);
    L_PI_KTLNR_0 NUMBER;
    L_PI_KTLNRKT_0 NUMBER;
    L_PI_VLREFLNR_0 NUMBER;
    L_PI_ISINNR_0 VARCHAR2(4000);
    L_PI_BOPLATZLNR_0 NUMBER;
    L_PI_HWRGLNR_0 NUMBER;
    L_PI_GFNR_0 NUMBER;
    L_PI_OPNCLOCD_0 VARCHAR2(4000);
    L_PI_MENGEAUF_0 NUMBER;
    L_PI_MENGESICHTB_0 NUMBER;
    L_PI_MENGEAUFCASH_0 NUMBER;
    L_PI_KURSLIM_0 NUMBER;
    L_PI_KURSLIMCD_0 VARCHAR2(4000);
    L_PI_AUSLOLIM_0 NUMBER;
    L_PI_VALIDBISDT_0 DATE;
    L_PI_AUFEMPFCD_0 VARCHAR2(4000);
    L_PI_TEXTHDL_0 VARCHAR2(4000);
    L_PI_AUFCOMCD_0 VARCHAR2(4000);
    L_PI_KDLNRERT_0 NUMBER;
    L_PO_AUFLNR_0 NUMBER;
begin
    L_LoginReturn := F2QLOGIN.F_SetUser('MD1AT', 'berlin08', 949);
    if L_LoginReturn != 'OK' then
        DBMS_OUTPUT.PUT_LINE('Login fehlgeschlagen: ' || L_LoginReturn);
        return;
    end if;
    L_PI_TLPTNLNRSRC_0      := null;
    L_PI_EXTREF_0           := 'Gugus-1';
    L_PI_KTLNR_0            := 89263187280406;  -- Depot 40.289.4015
    L_PI_KTLNRKT_0          := 89263190780420;  -- CHF-Konto b2simon 402.894.0002
    L_PI_VLREFLNR_0         := 14829634088459;  -- Ref LNR von AAPL Apple Computer Inc
    L_PI_ISINNR_0           := 'US0378331005';
    L_PI_BOPLATZLNR_0       := null;
    L_PI_HWRGLNR_0          := 333;             -- USD
    L_PI_GFNR_0             := 160;             -- Kauf
    L_PI_OPNCLOCD_0         := null;
    L_PI_MENGEAUF_0         := 10;              -- 10 Stück
    L_PI_MENGESICHTB_0      := null;
    L_PI_MENGEAUFCASH_0     := null;
    L_PI_KURSLIM_0          := null;
    L_PI_KURSLIMCD_0        := null;
    L_PI_AUSLOLIM_0         := null;
    L_PI_VALIDBISDT_0       := null;
    L_PI_AUFEMPFCD_0        := 'FX';
    L_PI_TEXTHDL_0          := null;
    L_PI_AUFCOMCD_0         := null;
    L_PI_KDLNRERT_0         := null;
    L_PO_AUFLNR_0           := null;
    B2QEAUF0.P_KDAUFTRAGERZEUGEN(PI_TLPTNLNRSRC => L_PI_TLPTNLNRSRC_0
                                ,PI_EXTREF => L_PI_EXTREF_0
                                ,PI_KTLNR => L_PI_KTLNR_0
                                ,PI_KTLNRKT => L_PI_KTLNRKT_0
                                ,PI_VLREFLNR => L_PI_VLREFLNR_0
                                ,PI_ISINNR => L_PI_ISINNR_0
                                ,PI_BOPLATZLNR => L_PI_BOPLATZLNR_0
                                ,PI_HWRGLNR => L_PI_HWRGLNR_0
                                ,PI_GFNR => L_PI_GFNR_0
                                ,PI_OPNCLOCD => L_PI_OPNCLOCD_0
                                ,PI_MENGEAUF => L_PI_MENGEAUF_0
                                ,PI_MENGESICHTB => L_PI_MENGESICHTB_0
                                ,PI_MENGEAUFCASH => L_PI_MENGEAUFCASH_0
                                ,PI_KURSLIM => L_PI_KURSLIM_0
                                ,PI_KURSLIMCD => L_PI_KURSLIMCD_0
                                ,PI_AUSLOLIM => L_PI_AUSLOLIM_0
                                ,PI_VALIDBISDT => L_PI_VALIDBISDT_0
                                ,PI_AUFEMPFCD => L_PI_AUFEMPFCD_0
                                ,PI_TEXTHDL => L_PI_TEXTHDL_0
                                ,PI_AUFCOMCD => L_PI_AUFCOMCD_0
                                ,PI_KDLNRERT => L_PI_KDLNRERT_0
                                ,PO_AUFLNR => L_PO_AUFLNR_0);
    DBMS_OUTPUT.PUT_LINE('L_PO_AUFLNR_0=' || to_char(L_PO_AUFLNR_0));
exception
    when others then
        dbms_output.put_line('sqlerrm = '|| sqlerrm);
        SRQMESS0.DumpMessages(); --Finnova spezifisches Log ausgeben
end;
/

declare
    L_LoginReturn           varchar2(30);           --Variabel für den Return-Wert der Login-Funktion
    L_HeaderAuftrag         B2YF_ORD_CHECK_INFO := B2YF_ORD_CHECK_INFO();
    L_TeilAuftrag           B2YF_PAR_CHECK_INFO := B2YF_PAR_CHECK_INFO();
    L_Auftrag               B2YF_BL_AUFTRAG_OBJ := B2YF_BL_AUFTRAG_OBJ();
    L_Validierungen         B2CF_VALIDATION;
begin
    L_LoginReturn := F2QLOGIN.F_SetUser('MD1AT', 'berlin08', 949);
    if L_LoginReturn != 'OK' then
        DBMS_OUTPUT.PUT_LINE('Login fehlgeschlagen: ' || L_LoginReturn);
        return;
    end if;
    --
    L_HeaderAuftrag.SELF_REF_IDX := 1;--nur einen Auftrag
    L_HeaderAuftrag.TEIL_IDX := DDCLNR22(1);--nur 1 teilauftrag.
    L_HeaderAuftrag.BO_PLATZ_LNR := null;       -- P_BoPlatzLnr;
    L_HeaderAuftrag.HWRG_LNR := 333;
    L_HeaderAuftrag.VL_REF_LNR := 14829634088459;
    L_HeaderAuftrag.OPN_CLO_CD := null;         -- P_OpnCloCd;
    L_HeaderAuftrag.GF_CD := 160;
    L_HeaderAuftrag.KURS_LIMIT_TYP := null;     -- P_KursLimCd;
    L_HeaderAuftrag.KURS_LIMIT := null;         -- P_KursLim;
    L_HeaderAuftrag.AUSLOESUNGS_LIMIT := null;  -- P_AusloLim;
    L_HeaderAuftrag.SH_CD := null;
    L_HeaderAuftrag.KD_LNR_ERF := null;
    L_HeaderAuftrag.BO_VALID       := B2QE_BOERSENGUELTIKEIT_1.F_BisGueltigDatum;
    L_HeaderAuftrag.ORD_MIFID_BERAT_LEV_CD := null;
    L_HeaderAuftrag.EINHEIT_CD := null;
    L_HeaderAuftrag.HAND_INSTR_CD := null;
    L_HeaderAuftrag.VALID_VON := null;
    L_HeaderAuftrag.AUF_EMPF_CD := 'FX';
    L_HeaderAuftrag.BO_AUF_TYP_CD := B2QE_AUF_TYP_1.F_EINZELAUFTRAG();
    L_HeaderAuftrag.AUF_ART_CD := 10;
    L_HeaderAuftrag.B2_AUF_ART_CD := null;
    L_HeaderAuftrag.VALID_BIS  := null;         -- P_ValidBisDt;
    L_HeaderAuftrag.ISIN_NR := null;            -- P_ISINNr;
    L_HeaderAuftrag.B2_AUF_COM_CD := null;      -- P_AufComCd;
    L_HeaderAuftrag.MENGE_SICHTB := null;       -- P_MengeSichtb;
    L_HeaderAuftrag.OM_BER_QUELLSYSTEM := B2QCNST0.K_OM_BER_B2;
    L_HeaderAuftrag.OM_BER_PRUEFSYSTEM := B2QCNST0.K_OM_BER_B2;
    L_HeaderAuftrag.EXT_REF  := 'Gugus-1';
    L_HeaderAuftrag.TL_PTN_LNR_SRC := null;     -- P_TlPtnLnrSrc;
    L_HeaderAuftrag.VALID_VON := sysdate;
    --
    L_TeilAuftrag.MENGE := 10;
    L_TeilAuftrag.KT_LNR_KT := 89263190780420;
    L_TeilAuftrag.KT_LNR_DP := 89263187280406;
    L_TeilAuftrag.SELF_TEIL_IDX := 1;
    L_TeilAuftrag.REF_IDX := 1;
    L_TeilAuftrag.EXT_REF := 'Gugus-1';
    L_TeilAuftrag.EXT_REF_KD := 'Papperlapp';
    L_TeilAuftrag.B2_AUF_ART_CD := null;
    L_TeilAuftrag.AKTIV_REGU := WVY_DTO_REGU();
    --
    L_Auftrag.AUFTRAG_REFS := B2C_CLIENT_REF_MAP(
        B2Y_CLIENT_REF_MAP(
            REF_IDX  => 1,
            TEIL_IDX => 1
        )
    );
    --
    L_Auftrag.AUFTRAEGE := B2CF_ORD_CHECK_INFO(L_HeaderAuftrag);
    L_Auftrag.TEIL_AUFTRAEGE := B2CF_PAR_CHECK_INFO(L_TeilAuftrag);
    dbms_output.put_line('Anzahl Teilaufträge : ' || L_Auftrag.TEIL_AUFTRAEGE.count);
    FOR i IN 1 .. L_Auftrag.TEIL_AUFTRAEGE.count loop
        dbms_output.put_line(' - ' || L_Auftrag.TEIL_AUFTRAEGE(1).EXT_REF);
    end loop;
    L_Validierungen := B2QF_SUBMIT_ORDERS.F_SaveOrders(
        P_AuftragObj              => L_Auftrag,
        P_StatusFallsVerletzungen => B2QE_AUFTRAG_STATUS_2.F_NACHBEARBEITEN()
    );
    rollback;
exception
    when others then
        dbms_output.put_line('sqlerrm = '|| sqlerrm);
        SRQMESS0.DumpMessages(); --Finnova spezifisches Log ausgeben
end;
/

commit;

SELECT  *
FROM    B2_AUF          a
WHERE   a.AUF_LNR = 89878171875502 -- 89876455963117
;

SELECT  *
FROM    B2_AUF          a
WHERE   a.AUF_LNR = 89876455963117
;



select  r.*
from    VL_STAMM            V
        inner join  VL_REF  R   ON  r.VL_LNR = v.VL_LNR and r.USERBK_NR = v.USERBK_NR
where R.USERBK_NR  = 949
    AND v.tk_sym = 'AAPL'
;



select  r.*
from    VL_STAMM            V
        inner join  VL_REF  R   ON  r.VL_LNR = v.VL_LNR and r.USERBK_NR = v.USERBK_NR
where R.USERBK_NR  = 949
    AND v.vl_lnr = 14829634088459
;


-- Fragen:
--      - VL_STAMM --> VL_REF : Bedeutung/Grund?







SELECT  *
FROM    AL1GF           gf
WHERE   gf.USERBK_NR = 949
    AND gf.SPRACHE_CD = 1
  --AND gf.GF_NR = 160
    AND gf.OM_BER = 'B2'
;




SELECT  a.AUF_LNR,
        a.create_dt,
        a.gf_nr,            (select bez_lang from AL1GF     x where x.gf_nr         = a.gf_nr           and x.sprache_cd = 1 and x.USERBK_NR = a.userbk_nr) as gf_bez,
        a.menge_auf,
        a.hwrg_lnr,         (select bez_lang from AL1WRG    x where x.wrg_lnr       = a.hwrg_lnr        and x.sprache_cd = 1 and x.USERBK_NR = a.userbk_nr) as hwrg_bez,
        a.kurswert_hwrg,
        a.bo_platz_lnr,     (select bez_lang from BO1PLATZ  x where x.bo_platz_lnr  = a.bo_platz_lnr    and x.sprache_cd = 1 and x.USERBK_NR = a.userbk_nr) as bo_platz_bez,
        a.kt_lnr_dpst,      (select bez_lang from KT1DPST   x where x.kt_lnr        = a.kt_lnr_dpst     and x.sprache_cd = 1 and x.USERBK_NR = a.userbk_nr) as kt_bez_dbst,
        a.vl_ref_lnr,
        a.vl_lnr,
        a.vl_einh_cd,
        a.vl_tit_art_nr,
        a.kurs,
        a.b2_gnr,
        a.kt_lnr_kt,
        a.kt_best_lnr,
        a.b2_auf_art_cd,
        a.*
FROM    B2_AUF                      a
WHERE   a.USERBK_NR = 949
    AND a.BO_AUF_TYP_CD = 'E'       -- E=Einzelauftrag / L=Listenauftrag / G=Kunde in Gruppe
    AND a.CREATE_DT > sysdate - 7
ORDER   BY  a.AUF_LNR       desc
;






declare
    G_HProfDirectory    VARCHAR2(20 CHAR) := 'MANIFEST_DIR';            -- Directory-Objekt für HPROF-Ausgabe
    G_HProfFilename     VARCHAR2(50 CHAR) := 'b2_test_' || to_char(sysdate,'YYYYMMDDHH24MISS') || '.trc';  -- Dateiname für HPROF-Ausgabe
    G_HProfEnabled      BOOLEAN := FALSE; -- Flag, um HPROF-Teil des Codes zu aktivieren/deaktivieren
    --
    G_LoginReturn       VARCHAR2(30 CHAR); --Variabel für den Return-Wert der Login-Funktion
    G_EvtStartTime      TIMESTAMP; --Variable für die Startzeit der Operation
    G_EvtEndTime        TIMESTAMP; --Variable für die Endzeit der Operation
    G_Result            INTEGER; --Variable für den Return-Wert der Löschungs-Funktion
    --
    L_BestandSchluessel B2CF_POS_KEY := B2CF_POS_KEY();
    L_Key               B2YF_POS_KEY;
    L_RetVal            B2CF_POS_INFO;
begin
    G_LoginReturn := F2QLOGIN.F_SetUser('MD1AT', 'berlin08', 949);
    if G_LoginReturn = 'OK' then
        DBMS_OUTPUT.PUT_LINE('Login erfolgreich:');   
        DBMS_OUTPUT.PUT_LINE('  - ' || F2QAPENV.F_UB);
        DBMS_OUTPUT.PUT_LINE('  - ' || F2QAPENV.F_RZ);
        DBMS_OUTPUT.PUT_LINE('  - ' || F2QAPENV.F_SP);
        DBMS_OUTPUT.PUT_LINE('  - ' || F2QAPENV.F_SU);
    else
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
    L_Key := B2YF_POS_KEY(
                DP_KEY_LNR	    => 0,
                DP_STELLE_GNR	=> NULL,
                KD_LNR          => 89262937577633,
                KT_LNR_DP       => 89263187280406,
                REF_IDX         => NULL,
                RWRG_LNR        => NULL,
                TEIL_IDX        => NULL,
                VL_REF_LNR      => 14829634088459
    );
    --
    L_BestandSchluessel.extend;
    L_BestandSchluessel(L_BestandSchluessel.count) := L_Key;
    --    
    select  B2YF_POS_INFO (
                KT_LNR_DP         => ksd.KT_LNR,
                DP_STELLE_GNR     => ksd.DP_STELLE_GNR,
                DP_KEY_LNR        => ksd.DP_KEY_LNR,
                VL_REF_LNR        => ksd.VL_REF_LNR,
                KT_BEST_LNR       => ksd.KT_BEST_LNR,
                RWRG_LNR          => ksd.RWRG_LNR,
                EINTRAG_GEFUNDEN  => 1,
                BEST              => ksd.BEST,
                KD_LNR            => schluessel.KD_LNR
            )
    bulk collect into L_RetVal
    from    KT_SALDO_DISP           ksd
            inner join table(
                DDQI_B2CF_POS_KEY.F_CollStats(
                    cast(L_BestandSchluessel as B2CF_POS_KEY),cardinality(L_BestandSchluessel))
                )                   schluessel  on  ksd.VL_REF_LNR   = schluessel.VL_REF_LNR
                                                    and ksd.KT_LNR        = schluessel.KT_LNR_DP
                                                    and ksd.KN_LNR        is null
                                                    and ksd.KN_TN_LNR     is null
                                                    and ksd.USERBK_NR     = F2QAPENV.F_UB
                                                    
    where   ksd.USERBK_NR = F2QAPENV.F_UB;
    --
    dbms_output.put_line('Anzahl der gefundenen Positionen: ' || L_RetVal.count);
    for i in 1 .. L_RetVal.count loop
        dbms_output.put_line(' - ' || L_RetVal(i).F_ToString());
    end loop;
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

