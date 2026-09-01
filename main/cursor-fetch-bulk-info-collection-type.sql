declare
   G_EvtStartTime    timestamp; --Variable für die Startzeit der Operation
   G_EvtEndTime      timestamp; --Variable für die Endzeit der Operation
   L_LimitRows number(10,0) := 1000000;
   L_Result B2CF_DL_ORDER_HEADER := B2CF_DL_ORDER_HEADER();
   L_StatusFilter DDCLNR22 := DDCLNR22(800,950);
   L_NumFilterRows number(10,0) := coalesce(cardinality(L_StatusFilter), 0);
   cursor C_ReadHeaders(cP_StatusFilter in DDCLNR22) is
      select
         B2YF_DL_ORDER_HEADER(
             AUF_LNR             => ba.AUF_LNR
            ,B2_GNR              => ba.B2_GNR
            ,BO_AUF_TYP_CD       => ba.BO_AUF_TYP_CD
            ,OBJ_STAT_CD         => ba.OBJ_STAT_CD
            ,AUF_ID              => ba.AUF_ID
            ,AUF_EMPF_CD         => ba.AUF_EMPF_CD
            ,B2_AUF_ART_CD       => ba.B2_AUF_ART_CD
            ,AUF_ART_CD          => ba.AUF_ART_CD
            ,VL_REF_LNR          => ba.VL_REF_LNR
            ,HWRG_LNR            => ba.HWRG_LNR
            ,AUF_DT_ERT          => ba.AUF_DT_ERT
            ,VALID_VON_DT        => ba.VALID_VON_DT
            ,VALID_BIS_DT        => ba.VALID_BIS_DT
            ,BO_PLATZ_LNR        => ba.BO_PLATZ_LNR
            ,CREATE_DT           => ba.CREATE_DT
            ,VL_EINH_CD          => ba.VL_EINH_CD
            ,GF_NR               => ba.GF_NR
            ,KURS_LIM            => ba.KURS_LIM
            ,MENGE_AUF           => ba.MENGE_AUF
         ) as ORDER_HEADER
      from table( DDQI_DDCLNR22.F_CollStats(cast (cP_StatusFilter as DDCLNR22), L_NumFilterRows))  filter1
      inner join B2_AUF ba on (filter1.column_value = ba.OBJ_STAT_CD)
      where ba.userbk_nr    = 949
      order by ba.AUF_LNR asc;

   L_ChunkedResult      B2CF_DL_ORDER_HEADER;
   L_Row                B2YF_DL_ORDER_HEADER;
begin
   G_EvtStartTime := SYSTIMESTAMP;
   open C_ReadHeaders(cP_StatusFilter => L_StatusFilter);
   fetch C_ReadHeaders bulk collect into L_ChunkedResult limit L_LimitRows;
   <<LoopWhileInputFound>>
   while L_ChunkedResult.COUNT > 0 and coalesce(cardinality(L_Result), 0)  < L_LimitRows
   loop
      <<LoopOverFoundRows>>
      for idxChunk in 1 .. L_ChunkedResult.COUNT
      loop
         if L_Result.COUNT > L_LimitRows then
            exit LoopWhileInputFound;
         end if;
         L_Row := L_ChunkedResult(idxChunk);
         L_Result.extend();
         L_Result(L_Result.COUNT) :=  L_Row;
      end loop LoopOverFoundRows;
      fetch C_ReadHeaders bulk collect into L_ChunkedResult limit L_LimitRows;
   end loop LoopWhileInputFound;
   close C_ReadHeaders;
   G_EvtEndTime := SYSTIMESTAMP;
   dbms_output.put_line('Execution time: ' || (G_EvtEndTime - G_EvtStartTime));
   dbms_output.put_line('Total rows fetched: ' || L_Result.COUNT);
   -- Show details of the first 5 and the last 5 rows fetched
   -- Add CREATE_DT to the output for better visibility
   for idx in 1 .. least(L_Result.COUNT, 5) loop
      dbms_output.put_line('  - ' || idx || ': AUF_LNR=' || L_Result(idx).AUF_LNR || ', B2_GNR=' || L_Result(idx).B2_GNR || ', OBJ_STAT_CD=' || L_Result(idx).OBJ_STAT_CD || ', CREATE_DT=' || L_Result(idx).CREATE_DT);
   end loop;
   dbms_output.put_line('  ...');
   for idx in greatest(L_Result.COUNT - 4, 1) .. L_Result.COUNT loop
      dbms_output.put_line('  - ' || idx || ': AUF_LNR=' || L_Result(idx).AUF_LNR || ', B2_GNR=' || L_Result(idx).B2_GNR || ', OBJ_STAT_CD=' || L_Result(idx).OBJ_STAT_CD || ', CREATE_DT=' || L_Result(idx).CREATE_DT);
   end loop;
end;

