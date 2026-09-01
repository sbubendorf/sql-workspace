select  b.USERBK_NR_HOME,
        b.BEZ_KURZ,
        b.BEZ_MITTEL,
        b.BEZ_LANG,
        r.BEZ_LANG as rz_name
from    F2LDATP0.SR1USBK                b
        left  join  F2LDATP0.SR1USBK    r   on  r.USERBK_NR_HOME = b.USERBK_NR_BRZ 
                                            and r.USERBK_NR = b.USERBK_NR 
                                            and r.SPRACHE_CD = b.SPRACHE_CD
where   b.SPRACHE_CD = 1
    and b.USERBK_NR = 949
order   by  b.USERBK_NR,
            b.USERBK_NR_HOME
;



