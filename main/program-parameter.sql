select   p.prg_id,
         p.userbk_nr,
         p.par_id,
         t.bez_lang,
         p.feld_datentyp_cd,
         f.BEZ_LANG,
         p.par_wert,
         p.bem_int
from     sr_prg_par              p
         inner join  al_textc    t  on  t.userbk_nr = p.userbk_nr
                                    and t.sprache_cd = 1
                                    and t.textc_lnr = p.textc_lnr
         left  join  sr1fedat  f  on  f.sprache_cd = 1
                                    and f.FELD_DATENTYP_CD = p.FELD_DATENTYP_CD
where    1=1
   and   upper(p.prg_id) like upper('%')
   and   upper(p.par_id) like upper('spez_denomin%')
order by p.prg_id, 
         p.par_id,
         p.userbk_nr
;


select   p.prg_id,
         p.userbk_nr,
         p.par_id,
         p.feld_datentyp_cd,
         f.userbk_nr,
         f.BEZ_KURZ,
         f.BEZ_MITTEL,
         f.BEZ_LANG
from     sr_prg_par              p
         left  join  sr1fedat  f  on  f.sprache_cd = 1
                                    and f.FELD_DATENTYP_CD = p.FELD_DATENTYP_CD
where    1=1
   and   upper(p.prg_id) like upper('%')
   and   upper(p.par_id) like upper('spez_denomin%')
order by p.prg_id, 
         p.par_id,
         p.userbk_nr,
         f.userbk_nr
;

