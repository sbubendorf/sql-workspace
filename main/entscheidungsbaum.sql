SELECT  *
FROM    SR_TAB_ANW                  anw
        --INNER JOIN  SR_CALL_PAR     par ON  anw.anw_cd = par.anw_cd
WHERE   anw.ANW_CD = 'BGRJ';



SELECT  *
FROM    f2ldatp0.om1aufem;

select  a.TAB_BEZ,
        a.FELD_BEZ,
        a.SPRACHE_CD,
        a.BEZ_LANG,
        a.USERBK_NR
from    sr1steuer_cd_pos                a
        inner join  sr1steuer_cd_wert   b   on  a.tab_bez       = b.tab_bez
                                            and a.feld_bez      = b.feld_bez
                                            and a.steuer_cd_pos = b.steuer_cd_pos   
                                            and a.sprache_cd    = b.sprache_cd
                                            and a.userbk_nr     = b.userbk_nr
where   a.tab_bez       = 'OM_AUFEM' 
    and a.feld_bez      = 'STEUER_CD_1'     
;

