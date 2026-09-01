SELECT  *
FROM    SR_PRG_PAR              p
        INNER JOIN  AL_TEXTC    t   on  t.TEXTC_LNR = p.TEXTC_LNR
WHERE   1=1
    AND p.PRG_ID = 'B2'
    AND p.PAR_ID like 'NOI_ERFASSUNG%'
;