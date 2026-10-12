select   ka.kt_art_nr,
       --ka.BEZ_KURZ     as kt_art_bez_kurz,
       --ka.BEZ_MITTEL   as kt_art_bez_mittel,
         ka.BEZ_LANG     as kt_art_bez_lang,
         az.grp_art,
       --ga.BEZ_KURZ     as grp_art_bez_kurz,
       --ga.BEZ_MITTEL   as grp_art_bez_mittel,
         ga.BEZ_LANG     as grp_art_bez_lang,
         az.gnr,
       --gr.BEZ_KURZ     as gnr_bez_kurz,
       --gr.BEZ_MITTEL   as gnr_bez_mittel,
         gr.BEZ_LANG     as gnr_bez_lang
from     kt1art                     ka
         inner join  kt_art_zuo     az on    az.kt_art_nr = ka.kt_art_nr 
                                       and   az.userbk_nr = ka.userbk_nr
         inner join sr1tabga        ga on    ga.userbk_nr = ka.userbk_nr
                                       and   ga.sprache_cd = ka.sprache_cd
                                       and   ga.tab_bez = 'KT_ART'
                                       and   ga.GRP_ART = az.GRP_ART
         inner join sr1tabg         gr on    gr.userbk_nr = ka.userbk_nr
                                       and   gr.sprache_cd = ka.sprache_cd
                                       and   gr.GNR = az.GNR
                                       and   gr.GRP_ART = az.GRP_ART
where    ka.userbk_nr = 949
   and   ka.sprache_cd = 1
   and   az.gnr = 10
   and   az.GRP_ART = 5339
order by ka.kt_art_nr      asc,
         az.grp_art        asc,
         az.gnr            asc
;