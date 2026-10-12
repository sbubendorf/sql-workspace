select   
         kd.kd_nr,
         kd.name_1      as last_name,
         kd.vorname     as first_name,
         kt.kt_lnr,
         kt.kt_nr,
         kt.kt_art_nr,
         ka.bez_lang    as kt_art_bez_lang,
         (select count(*) from b2_auf a where a.kt_lnr = kt.kt_lnr and a.userbk_nr = kt.userbk_nr) as auf_count,
       --ks.vl_ref_lnr,
         vs.tk_sym as vl_sym,
         vs.isin_nr,
         ks.best,
         vt.text_rec as vl_name
from     kt_stamm                   kt
         inner join  kd_stamm       kd on    kd.kd_lnr = kt.kd_lnr and kd.userbk_nr = kt.userbk_nr
         inner join  kt1art         ka on    ka.kt_art_nr = kt.kt_art_nr and ka.userbk_nr = kt.userbk_nr and ka.sprache_cd = 1
         left  join  kt_saldo       ks on    ks.kt_lnr = kt.kt_lnr and ks.userbk_nr = kt.userbk_nr
         left  join  vl_ref         vr on    vr.vl_ref_lnr = ks.vl_ref_lnr and vr.userbk_nr = kt.userbk_nr 
         left  join  vl_stamm       vs on    vs.vl_lnr = vr.vl_lnr and vs.userbk_nr = vr.userbk_nr
         left  join  vl_text        vt on    vt.VL_TEXT_LNR = vs.VL_TEXT_LNR and vt.userbk_nr = vs.userbk_nr and vt.VL_ABSCHNITT_NR = 0 and vt.sprache_cd = 1
where    kt.userbk_nr = 949
   and   kd.kd_stat_cd = 0 -- Aktiv
   and   kt.aufheb_dat is null
   and   kt.kt_art_nr in
         (
            5030,    -- Anlagedepot (mit spezial Stückelung)
            5001,    -- Depot Ordinario (ohne spezial Stückelung)
            null
         )
order by kt.kt_lnr desc   
fetch first 500 rows only
;



select   *
from     kd_adr         a
where    a.userbk_nr = 949
fetch first 500 rows only
;


select   l.LAND_LNR,
         l.ISO_LAND_CD,
         l.ISO_LAND_3_CD,
         l.BEZ_LANG           as land_bez,
         o.ORT_LNR,
         o.PLZ,
         o.ORT
from     al1land           l
         inner join  al_ort          o on    o.LAND_LNR = l.LAND_LNR and o.userbk_nr = l.userbk_nr
         inner join  al_strasse        s on    s.ORT_LNR = o.ORT_LNR and s.userbk_nr = o.userbk_nr
where    l.userbk_nr = 949
   and   l.sprache_cd = 1
 --and   l.land_lnr > 1
order by l.iso_land_cd;


select   o.*
from     al_ort          o
where    o.userbk_nr = 949
fetch first 500 rows only
;

select   *
from     al_strasse s