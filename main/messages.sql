SELECT  msgi.CS_SYS_CD,
        to_char(count(*),'999G999G999G999', 'NLS_NUMERIC_CHARACTERS=''.''''') as row_count
FROM    CS_MSG_IN               msgi
GROUP   BY  msgi.CS_SYS_CD
;


SELECT  m.USERBK_NR,
        m.CS_MSG_TYP_CD,
        m.CS_APPL_NAME,
        m.CS_KORR_ADR,
        m.CS_MSG_TEXT
FROM    CS_MSG_IN               m
WHERE   1=1
    AND m.USERBK_NR = 949
    AND m.CS_SYS_CD = 'FIX'
    AND m.CS_MSG_TYP_CD like 'D%'
;

--8=FIX.4.4~9=187~35=D~34=202~49=M959MQ~52=20260421-12:00:24~56=M949MQ~11=PL201225~15=USD~21=2~22=4~38=30~40=1~48=US0378331005~54=1~55=AAPL~59=6~60=20260421-12:00:24~100=XNAS~120=USD~126=20260529-21:00:00~10=028~



declare
  L_FixMsg varchar2(2000);
  L_ClOrdId varchar2(20);
  L_NewMsgId   BG_MSG.BG_MSG_LNR%type;
begin
    f2qapenv.setlogpar(64147726648959,1,949,9500); -- 64147726648959 = md1mth
    
    SRQLOG00.setup('B2QBGB20=DEBUG'); --Debug des Packages aktivieren
	 
	 L_ClOrdId := 'XXX'||f2qapenv.F_CreLnr;
    
    /*
	 
        8 = FIX Version
        9 = BodyLength
       35 = MsgType 
                D = NewOrderSingle
                8 = ExecutionReport
                J = Allocation
       34 = MsgSeqNum
       49 = SenderCompID
       52 = SendingTime
       56 = TargetCompID ("INT", "DVL")
        6 = AvgPx
       11 = ClOrdId (Platzierungs-ID bei ExecutionReport-Meldungen)
       12 = Commission
       14 = CumQty (bisher zugeteilte Menge, inkl. der Menge dieser Meldung)
       15 = Currency (Handelswährung)
       17 = ExecID
       20 = ExecTransType (z.B. '0' in einer 8/0/A-Meldung, oder einer 8/0/2-Meldung)
      150 = ExecType (z.B. 'A' in einer 8/0/A-Meldung, oder '2' in einer 8/0/2-Meldung)
       21 = HandlInstr
       22 = SecurityIDSource (4 = ISIN)
       30 = LastMkt
       31 = LastPx
       32 = LastQty (Menge der Ausführung)
       37 = OrderID => muss die Platzierungs-ID enthalten. (Bei FE-Orders: Denselben Wert, der auch in 8/0/A im Tag 37 mitgegeben wurde)
       38 = OrderQty
       39 = OrdStatus (bei einer 8/0/A-Meldung: 'A', bei einer 8/0/0-Meldung: '0'; bei einer 8/0/2-Meldung: '2')
       40 = OrdType
       48 = SecurityID
       53 = Quantity
       54 = Side ("Valid values: 1 = Buy, 2 = Sell", ..., 5 = Sell short, ..., D = Subscribe (e.g. CIV), E = Redeem (e.g. CIV), ...")
       55 = Symbol ("Common, "human understood" representation of the security. SecurityID <48> value can be specified if no symbol exists (e.g. non-exchange traded Collective Investment Vehicles). Use '[N/A]' for products which do not have a symbol.")
       59 = TimeInForce
       60 = TransactTime
       64 = SettlDate
       70 = AllocId (Unique identifier for Allocation Instruction (J) message.)
       71 = AllocTransType (0 = New, 1 = Replace, 2 = Cancel)
       73 = NoOrders (Indicates number of orders to be combined for average pricing and allocation.)
       75 = TradeDate
       78 = NoAllocs (Number of repeating AllocAccount <79>/AllocPrice <366> entries)
       79 = AllocAccount
       80 = AllocQty (Quantity to be allocated to specific sub-account)
      100 = ExDestination
      119 = SettlCurrAmt (Total amount due expressed in settlement currency (includes the effect of the forex transaction))
      120 = SettlCurrency
      126 = ExpireTime
      136 = NoMiscFees
      137 = MiscFeeAmt
      138 = MiscFeeCurr
      139 = MiscFeeType
      151 = LeavesQty
      154 = AllocNetMoney
      155 = SettlCurrFxRate
      156 = SettlCurrFxRateCalc
      157 = NumDaysInterest
       10 = CheckSum
    */

  -- Broker schickt Bestätigung, dass er die Platzierung erhalten hat (Platzierungs-Status wechselt von "Beantragt" zu "Bestätigt"), Kauf Aktie
  L_FixMsg := '8=FIX.4.2~35=8~49=SIMU~56=MOD~20=0~150=8~39=8~37=PL164859~11=PL164859~103=3';
  --                        |                   |     |
  --                        |                   |     +--->  8 : Oderstatus      = 8 - Rejected          ------+
  --                        |                   +---------> 20 : ExecTransType   = 0 - New                     +--> 808 --> Reject-Message
  --                        +-----------------------------> 35 : Message Type    = 8 - Execution Report  ------+
  /*
    8=FIX.4.2
    35=8            MsgType = Execution Report
    49=SIMU         SenderCompID (identifying firm sending message)
    56=MOD          TargetCompID (identifying receiving firm)
    20=0            ExecTransType = New
    150=8           ExecType = Rejected
    39=8            OrdStatus = Rejected
    37=PL164859     OrderID (Platzierungsnummer)
    11=PL164859     ClOrdID (Platzierungsnummer)
    103=3           OrdRejReason = Order exeeds limit
  */
  B2QBG200.FIXAcceptInboundAd(L_NewMsgId, L_FixMsg,null,null,'M959','M949');
  dbms_output.put_line(' have id='||L_NewMsgId);
  commit;
  srqmess0.dumpmessages;
end;
/


declare
    G_HProfDirectory    VARCHAR2(20 CHAR) := 'MANIFEST_DIR';            -- Directory-Objekt für HPROF-Ausgabe
    G_HProfFilename     VARCHAR2(50 CHAR) := 'b2_test_' || to_char(sysdate,'YYYYMMDDHH24MISS') || '.trc';  -- Dateiname für HPROF-Ausgabe
    G_HProfEnabled      BOOLEAN := FALSE; -- Flag, um HPROF-Teil des Codes zu aktivieren/deaktivieren
    --
    G_LoginReturn       VARCHAR2(30 CHAR); --Variabel für den Return-Wert der Login-Funktion
    G_EvtStartTime      TIMESTAMP; --Variable für die Startzeit der Operation
    G_EvtEndTime        TIMESTAMP; --Variable für die Endzeit der Operation
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
    -- Test-Code starts here ---------------------------------------------------
    --
    null;
    --
    -- Test-Code end here ------------------------------------------------------
    --
    G_EvtEndTime := SYSTIMESTAMP;
    --
    -- Stop profiling
    if G_HProfEnabled then
        DBMS_HPROF.STOP_PROFILING;
    end if;
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


declare
    L_LoginReturn       varchar2(30); --Variabel für den Return-Wert der Login-Funktion
    L_B2DPINPUT_0       B2CI_DPST_PARAMS;
    L_Result_0          B2CI_DPST_INFO;
begin
    L_LoginReturn := F2QLOGIN.F_SetUser('MD1AT', 'berlin08', 949);
    if L_LoginReturn != 'OK' then
        DBMS_OUTPUT.PUT_LINE('Login fehlgeschlagen: ' || L_LoginReturn);
        return;
    end if;
    L_B2DPINPUT_0 := B2CI_DPST_PARAMS();
    L_B2DPINPUT_0.extend();
    L_B2DPINPUT_0(L_B2DPINPUT_0.LAST) := B2YI_DPST_PARAMS();
    L_B2DPINPUT_0(L_B2DPINPUT_0.LAST).REF_IDX := null;
    L_B2DPINPUT_0(L_B2DPINPUT_0.LAST).VL_REF_LNR := 14829634088459;
    L_B2DPINPUT_0(L_B2DPINPUT_0.LAST).HWRG_LNR := 333;
    L_B2DPINPUT_0(L_B2DPINPUT_0.LAST).BO_PLATZ_LNR := 67;
    L_B2DPINPUT_0(L_B2DPINPUT_0.LAST).DP_BEST_LNR := null;
    L_B2DPINPUT_0(L_B2DPINPUT_0.LAST).KT_LNR_DP := 1000931;
    L_B2DPINPUT_0(L_B2DPINPUT_0.LAST).GF_CD := 160;
    L_B2DPINPUT_0(L_B2DPINPUT_0.LAST).OPN_CLO_CD := null;
    L_B2DPINPUT_0(L_B2DPINPUT_0.LAST).DP_KEY_LNR := null;
    L_B2DPINPUT_0(L_B2DPINPUT_0.LAST).OM_BER_ZIELSYSTEM := 'B2';



    L_Result_0 := B2QI_UTIL_0.F_GETDEPOTSTELLE(P_B2DPINPUT => L_B2DPINPUT_0);
    if L_Result_0 is not null then
        DBMS_OUTPUT.PUT_LINE('L_Result_0.COUNT=' ||L_Result_0.COUNT);
        if L_Result_0.COUNT > 0 then
            for idx0 in L_Result_0.FIRST..L_Result_0.LAST loop
                DBMS_OUTPUT.PUT_LINE('----------------------------------------Begin L_Result_0(idx0)----------------------------------------');
                if L_Result_0(idx0) is not null then
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').REF_IDX=' || to_char(L_Result_0(idx0).REF_IDX));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').DPST_NR=' || to_char(L_Result_0(idx0).DPST_NR));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').DPST_GNR=' || to_char(L_Result_0(idx0).DPST_GNR));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').KT_LNR=' || to_char(L_Result_0(idx0).KT_LNR));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').KT_LNR_ORDI=' || to_char(L_Result_0(idx0).KT_LNR_ORDI));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').DP_BEST_LNR=' || to_char(L_Result_0(idx0).DP_BEST_LNR));
                end if;
                DBMS_OUTPUT.PUT_LINE('-----------------------------------------End L_Result_0-----------------------------------------');
            end loop;
        end if;
    else
        DBMS_OUTPUT.PUT_LINE('L_Result_0 is null');
    end if;

exception
    when others then
        dbms_output.put_line('sqlerrm = '|| sqlerrm);
        SRQMESS0.DumpMessages(); --Finnova spezifisches Log ausgeben
end;

