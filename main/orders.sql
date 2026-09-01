-- $Revision$

-- Verwaiste Einträge in OM_AUF von Börsenaufträgen
SELECT  count(*)
FROM    OM_AUF              omauf
WHERE   not exists 
        (
            select  null 
            from    b2_auf a 
            where   a.auf_lnr = omauf.auf_lnr 
                and a.userbk_nr = omauf.userbk_nr
        )
    and omauf.om_ber = 'B2'
;

-- Order-Bereiche
select  omauf.USERBK_NR,
        omauf.OM_BER,
        to_char(count(*),'999G999G999G999')     as  num_orders
from    OM_AUF              omauf
group   by  omauf.USERBK_NR,
            omauf.OM_BER
;


SELECT  count(*)                num_total,
        sum(case when a.auf_lnr is null then 1 else 0 end) as num_orphaned
FROM    B2_AUF_DET              ad
        left  join  B2_AUF      a   on  a.auf_lnr = ad.auf_lnr 
                                    and a.userbk_nr = ad.userbk_nr
;

SELECT  count(*)                num_total,
        sum(case when a.auf_lnr is null then 1 else 0 end) as num_orphaned
FROM    B2_AUF_PLAZ_DET         ad
        left  join  B2_AUF      a   on  a.auf_lnr = ad.auf_lnr 
                                    and a.userbk_nr = ad.userbk_nr
;

SELECT  count(*)                num_total,
        sum(case when a.auf_lnr is null then 1 else 0 end) as num_orphaned
FROM    B2_AUF_UPD              u
        left  join  B2_AUF      a   on  a.auf_lnr = u.auf_lnr 
                                    and a.userbk_nr = u.userbk_nr
;


-- --------------------------------------------------------------------------------
--  Oder status
-- --------------------------------------------------------------------------------

-- Show all possible order status codes for userbk_nr = 949 ---------------------------
select   to_char(src.obj_typ_stat_cd - 1200000,'000')    as obj_typ_stat_cd,
         src.bez_kurz,
         src.bez_mittel,
         src.bez_lang
from     om1obj_typ_stat src
where    to_char(src.obj_typ_stat_cd) like '1200%'
   and   src.sprache_cd = 1
   and   src.userbk_nr = 949
;

-- Orders grouped by status ---------------------------------
select   a.obj_stat_cd,
         b.bez_lang,
         count(*) as anzahl_auftraege
from     b2_auf a
         left  join  om1obj_typ_stat b    on    b.userbk_nr = a.userbk_nr
                                          and   b.obj_typ_stat_cd - 1200000 = a.obj_stat_cd
                                          and   b.sprache_cd = 1
where    a.userbk_nr = 949
group by a.obj_stat_cd,
         b.bez_lang
order by a.obj_stat_cd
;

-- --------------------------------------------------------------------------------
--  Auftragstypen
-- --------------------------------------------------------------------------------

select   a.bo_auf_typ_cd,
         b.bez_lang,
         count(*) as anzahl_auftraege
from     b2_auf a
         left  join  bo1auf_typ   b       on    b.userbk_nr = a.userbk_nr
                                          and   b.BO_AUF_TYP_CD = a.BO_AUF_TYP_CD
                                          and   b.sprache_cd = 1
where    a.userbk_nr = 949
group by a.bo_auf_typ_cd,
         b.bez_lang
order by a.bo_auf_typ_cd
;

-- --------------------------------------------------------------------------------
--  Auftragsarten
-- --------------------------------------------------------------------------------

select   a.b2_auf_art_cd,
         b.bez_lang,
         count(*) as anzahl_auftraege
from     b2_auf a
         left  join  b21auf_art     b     on    b.userbk_nr = a.userbk_nr
                                          and   b.B2_AUF_ART_CD = a.B2_AUF_ART_CD
                                          and   b.sprache_cd = 1
where    a.userbk_nr = 949
group by a.b2_auf_art_cd,
         b.bez_lang
order by a.b2_auf_art_cd
;
