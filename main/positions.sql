SELECT  *
FROM    KT_SALDO        s
WHERE   s.USERBK_NR = 949
;


SELECT  kds.KD_NR,
        kds.VORNAME,
        kds.NAME_1,
        grp.EDIT_KT_GNR,
        grp.RUBRIK
FROM    KD_STAMM                    kds
        INNER JOIN  KT_GRP          grp ON  grp.KD_LNR = kds.KD_LNR and grp.USERBK_NR = kds.USERBK_NR
        INNER JOIN  KT_SALDO        kts ON  kts.kt
WHERE   1=1
    AND kds.USERBK_NR = 949
    AND kds.NAME_1 = 'Bubendorf'
;


SELECT  kds.KD_NR,
        kds.VORNAME,
        kds.NAME_1,
        sym.SYM_BEZ,
        grp.EDIT_KT_GNR     as  portfolio_nr,
        kts.EDIT_KT_NR      as  kt_nr,
        wrg.BEZ_LANG        as  wrg,
        art.BEZ_LANG        as  kt_art,
        -- sal.SALDO_KWRG,
        -- sal.SALDO_BWRG,
        sal.BEST,
        vlr.vl_ref_lnr,
        SAL.*
FROM    KD_STAMM                    kds
        INNER JOIN  KD_SYM          sym on  sym.KD_LNR = kds.KD_LNR         and sym.USERBK_NR = kds.USERBK_NR
        LEFT  JOIN  KT_STAMM        kts on  kts.KD_LNR = kds.KD_LNR         and kts.USERBK_NR = kds.USERBK_NR
        LEFT  JOIN  KT_GRP          grp on  grp.KT_GNR = kts.KT_GNR
        LEFT  JOIN  KT1ART          art on  art.KT_ART_NR = kts.KT_ART_NR   and art.USERBK_NR = kts.USERBK_NR and art.SPRACHE_CD = 1
        LEFT  JOIN  AL1WRG          wrg on  wrg.WRG_LNR = kts.WRG_LNR       and wrg.USERBK_NR = kts.USERBK_NR and wrg.SPRACHE_CD = 1
        LEFT  JOIN  KT_SALDO        sal on  sal.KT_LNR = kts.KT_LNR         and sal.USERBK_NR = kts.USERBK_NR
        LEFT  JOIN  VL1REF          vlr on  vlr.VL_REF_LNR = sal.VL_REF_LNR and vlr.USERBK_NR = kts.USERBK_NR
WHERE   1=1
  --AND kds.USERBK_NR = 949
  --AND kds.NAME_1 = 'Bubendorf'
  --AND kds.KD_LNR = 89262937577633
    AND sym.SYM_BEZ = 'B2SIMON'
order   BY  kts.KT_LNR
;



SELECT  *
FROM    KT_STAMM            kts
WHERE   kts.KD_LNR = 89262937577633
;

