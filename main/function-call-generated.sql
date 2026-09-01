declare
    L_LoginReturn varchar2(30); --Variabel für den Return-Wert der Login-Funktion
    L_FILTERB2GNR_0 DDCLNR22;
    L_FILTER_0 B2QF_DL_ORDER.T_DL_ORDER_FILTER;
    L_Result_0 B2CF_DL_ORDER_HEADER;
begin
    L_LoginReturn := F2QLOGIN.F_SetUser('MD1AT', 'berlin08', 949);
    if L_LoginReturn != 'OK' then
        DBMS_OUTPUT.PUT_LINE('Login fehlgeschlagen: ' || L_LoginReturn);
        return;
    end if;

    -- L_FILTERB2GNR_0 := DDCLNR22();
    -- L_FILTERB2GNR_0.extend();
    -- L_FILTERB2GNR_0(L_FILTERB2GNR_0.LAST) := 444444;
    -- L_FILTERB2GNR_0.extend();
    -- L_FILTERB2GNR_0(L_FILTERB2GNR_0.LAST) := 5555555;

    L_FILTER_0 := B2QF_DL_ORDER.T_DL_ORDER_FILTER();
    L_FILTER_0.AUF_DT_ERT_FROM := null;
    L_FILTER_0.AUF_DT_ERT_TO := null;

    -- L_FILTER_0.AUF_ID_IDX := B2QF_DL_ORDER.T_DL_ORDER_C40_IDX();
    -- L_FILTER_0.AUF_ID_IDX(1) := 1;

    L_FILTER_0.AUF_LNR_GRT := null;
    L_FILTER_0.CREATE_DT := null;
    L_FILTER_0.MAX_OUTPUT_ROWS := null;
    L_FILTER_0.MUT_VON_FROM := null;
    L_FILTER_0.VALID_BIS_DT_FROM := null;
    L_FILTER_0.VALID_BIS_DT_TO := null;
    L_FILTER_0.VALID_VON_DT_FROM := null;
    L_FILTER_0.VALID_VON_DT_TO := null;

    L_Result_0 := B2QF_DL_ORDER.F_READORDERHEADERSB2GNR(P_FILTERB2GNR => L_FILTERB2GNR_0
                                                       ,P_FILTER => L_FILTER_0);
    if L_Result_0 is not null then
        DBMS_OUTPUT.PUT_LINE('L_Result_0.COUNT=' ||L_Result_0.COUNT);
        if L_Result_0.COUNT > 0 then
            for idx0 in L_Result_0.FIRST..L_Result_0.LAST loop
                DBMS_OUTPUT.PUT_LINE('----------------------------------------Begin L_Result_0(idx0)----------------------------------------');
                if L_Result_0(idx0) is not null then
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').AUF_LNR=' || to_char(L_Result_0(idx0).AUF_LNR));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').B2_GNR=' || to_char(L_Result_0(idx0).B2_GNR));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').ROW_INFO=' || to_char(L_Result_0(idx0).ROW_INFO));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').EXT_REF=' || to_char(L_Result_0(idx0).EXT_REF));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').CREATE_ID=' || to_char(L_Result_0(idx0).CREATE_ID));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').BO_AUF_TYP_CD=' || to_char(L_Result_0(idx0).BO_AUF_TYP_CD));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').OBJ_STAT_CD=' || to_char(L_Result_0(idx0).OBJ_STAT_CD));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').KD_LNR=' || to_char(L_Result_0(idx0).KD_LNR));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').KT_LNR=' || to_char(L_Result_0(idx0).KT_LNR));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').KT_GNR=' || to_char(L_Result_0(idx0).KT_GNR));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').VT_LNR=' || to_char(L_Result_0(idx0).VT_LNR));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').KD_LNR_ERF=' || to_char(L_Result_0(idx0).KD_LNR_ERF));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').REF_IDX=' || to_char(L_Result_0(idx0).REF_IDX));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').TEIL_IDX=' || to_char(L_Result_0(idx0).TEIL_IDX));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').SELF_IDX=' || to_char(L_Result_0(idx0).SELF_IDX));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').VERSION_NUM=' || to_char(L_Result_0(idx0).VERSION_NUM));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').AUF_ID=' || to_char(L_Result_0(idx0).AUF_ID));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').WF_GF_LNR=' || to_char(L_Result_0(idx0).WF_GF_LNR));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').AUF_EMPF_CD=' || to_char(L_Result_0(idx0).AUF_EMPF_CD));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').B2_AUF_ART_CD=' || to_char(L_Result_0(idx0).B2_AUF_ART_CD));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').AUF_ART_CD=' || to_char(L_Result_0(idx0).AUF_ART_CD));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').VL_REF_LNR=' || to_char(L_Result_0(idx0).VL_REF_LNR));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').HWRG_LNR=' || to_char(L_Result_0(idx0).HWRG_LNR));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').AUF_DT_ERT=' || to_char(L_Result_0(idx0).AUF_DT_ERT, 'DD-MM-YYYY HH24:MI:SS'));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').VALID_VON_DT=' || to_char(L_Result_0(idx0).VALID_VON_DT, 'DD-MM-YYYY HH24:MI:SS'));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').VALID_BIS_DT=' || to_char(L_Result_0(idx0).VALID_BIS_DT, 'DD-MM-YYYY HH24:MI:SS'));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').MUT_VON=' || to_char(L_Result_0(idx0).MUT_VON, 'DD-MM-YYYY HH24:MI:SS'));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').BO_PLATZ_LNR=' || to_char(L_Result_0(idx0).BO_PLATZ_LNR));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').KT_LNR_KT=' || to_char(L_Result_0(idx0).KT_LNR_KT));
                    DBMS_OUTPUT.PUT_LINE('L_Result_0('||idx0||').CREATE_DT=' || to_char(L_Result_0(idx0).CREATE_DT, 'DD-MM-YYYY HH24:MI:SS'));
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
