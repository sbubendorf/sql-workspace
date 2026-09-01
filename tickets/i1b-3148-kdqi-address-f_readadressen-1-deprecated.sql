SELECT  F2QLOGIN.F_SetUser('MD1AT', 'berlin08', 949) from dual;

declare
    G_LoginReturn       VARCHAR2(30 CHAR); --Variabel für den Return-Wert der Login-Funktion
    L_KdAdrNew          KDYI_ADRESSE_1;
    L_KdAdrOld          KDYI_ADDRESS_2;
    L_KdLnr             number := 89262937577633;
begin
    G_LoginReturn := F2QLOGIN.F_SetUser('MD1AT', 'berlin08', 949);
    if G_LoginReturn != 'OK' then
        DBMS_OUTPUT.PUT_LINE('Login fehlgeschlagen: ' || G_LoginReturn);
        return;
    end if;
    DBMS_OUTPUT.PUT_LINE('Login erfolgreich!');
    --
    L_KdAdrNew := KDQI_ADRESSEN.F_ReadAdressen_1(L_KdLnr, 11, sysdate)(1);
    L_KdAdrOld := KDQI_ADDRESS.F_READADDRESSES_2(L_KdLnr, 11, sysdate)(1);
    --
    DBMS_OUTPUT.PUT_LINE('Address New: ' || L_KdAdrNew.F_ToString());
    DBMS_OUTPUT.PUT_LINE('        Old: ' || L_KdAdrOld.F_ToString());
exception
    when others then
        DBMS_OUTPUT.PUT_LINE('sqlerrm = '|| sqlerrm);
        SRQMESS0.DumpMessages(); --Finnova spezifisches Log ausgeben
end;
/


SELECT  k.KD_LNR,
        k.NAME_1,
        k.VORNAME,
        s.SYM_BEZ
FROM    KD_STAMM                    k
        INNER JOIN  KD_SYM          s   ON  s.KD_LNR = k.KD_LNR
WHERE   s.SYM_BEZ = 'B2SIMON'
;