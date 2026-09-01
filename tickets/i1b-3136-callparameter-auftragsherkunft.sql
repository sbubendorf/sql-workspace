SELECT  h.AUF_EMPF_CD,
        count(*)
FROM    f2ldatp0.om1aufem   h
GROUP   BY  h.AUF_EMPF_CD
ORDER   BY  count(*) desc
;

SELECT  a.AUF_EMPF_CD,
        h.BEZ_LANG,
        count(*)
FROM    F2LDATP0.B2_AUF                 a
        INNER JOIN  F2LDATP0.OM1AUFEM   h   ON  h.AUF_EMPF_CD = a.AUF_EMPF_CD and h.USERBK_NR = a.USERBK_NR and h.SPRACHE_CD = 1
GROUP   BY  a.AUF_EMPF_CD, h.BEZ_LANG
ORDER   BY  a.AUF_EMPF_CD
;

SELECT  *
FROM    KDWI_STAMM_NODS_2;

SELECT  a.auf_lnr,
        a.userbk_nr,
        count(*)
FROM    B2_AUF      a
GROUP   BY  a.auf_lnr, a.userbk_nr
ORDER   BY  count(*) desc;

SELECT  *
FROM    B2_AUF          a
        inner join  b2_auf_de
;

SELECT  *
FROM    F2LDATP0.AL_TEXTC       t
WHERE   t.BEZ_KURZ = 'HAuf'
;


SELECT  *
FROM    F2LDATP0.AL_TREE_KAT    k
WHERE   1=1
    AND k.TREE_ANW_CD = 'BGRJ'
    AND k.USERBK_NR = 949
;

SELECT  *
FROM    F2LDATP0.SR_CALL_PAR            cp
WHERE   cp.APPL_ID = 'AL_TREE_SEL_BGRJ'
;

SELECT  *
FROM    F2LDATP0.SR_CALL_PAR            cp
WHERE   cp.APPL_ID not like 'AL_TREE_SEL_%'
;

