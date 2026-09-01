/*MTH 23.06.2022

Script, um eine Bestätigung des Platzierungserhalts vom Broker an die Finnovabank zu schicken, mit einer FIX-Meldung 8/0/A = ExecutionReport (incoming)

*/

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
  --                        |                   |     +---> Oderstatus      = 8 - Rejected          ------+
  --                        |                   +---------> ExecTransType   = 0 - New                     +--> 808 --> Reject-Message
  --                        +-----------------------------> Message Type    = 8 - Execution Report  ------+
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
    and ob.object_name like upper('B2QBG200')
order   by  ob.object_type,
            ob.owner,
            ob.object_name
;