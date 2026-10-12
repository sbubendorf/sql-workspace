select   abr.userbk_nr,
         abr.b2_abr_lnr,
         count(*) num_auf
from     b2_abr                     abr
         inner join  b2_auf         auf   on    auf.auf_lnr = abr.auf_lnr
                                          and   auf.userbk_nr = abr.userbk_nr
group    by abr.userbk_nr,
            abr.b2_abr_lnr
order by num_auf desc
;


select   abr.userbk_nr,
         abr.b2_trade_gnr,
         abr.b2_abr_lnr,
         abr.userbk_nr,
         auf.auf_lnr,
         auf.b2_auf_art_cd,
         art.bez_lang,
         kts.kt_art_nr
from     b2_abr                     abr
         inner join  b2_auf         auf   on    auf.auf_lnr = abr.auf_lnr
                                          and   auf.userbk_nr = abr.userbk_nr
         inner join  b21auf_art     art   on    art.b2_auf_art_cd = auf.b2_auf_art_cd   
                                          and   art.userbk_nr = auf.userbk_nr
                                          and   art.sprache_cd = 1
         inner join  kt_stamm       kts   on    kts.userbk_nr = abr.userbk_nr
                                          and   kts.kt_lnr = auf.kt_lnr
where    abr.userbk_nr = 949
   and   abr.b2_trade_gnr = 18217184323386
   and   abr.b2_auf_art_cd in (10,110) -- Kunde und Nostro in Kundenrolle
order by abr.userbk_nr,
         abr.b2_trade_gnr,
         auf.b2_auf_art_cd,
         abr.b2_abr_lnr,
         auf.auf_lnr
;


-- --------------------------------------------------------------------------------
--  AUF_ART_CD
-- --------------------------------------------------------------------------------

select   auf.b2_auf_art_cd,
         art.bez_lang,
         count(*)
from     b2_abr                     abr
         inner join  b2_auf         auf   on    auf.auf_lnr = abr.auf_lnr
                                          and   auf.userbk_nr = abr.userbk_nr
         inner join  b21auf_art     art   on    art.b2_auf_art_cd = auf.b2_auf_art_cd   
                                          and   art.userbk_nr = auf.userbk_nr
                                          and   art.sprache_cd = 1
where    abr.userbk_nr = 949
group by auf.b2_auf_art_cd,
         art.bez_lang
order by auf.b2_auf_art_cd
;

/*
Wertebereich B2_AUF_ART (BK949)

B2_AUF_ART_CD  BEZ_LANG                    COUNT(*)                    
10             Kunde                       120501                      
20             Gegenpartei                 25337                       
40             Interim                     89                          
110            Nostro in Kundenrolle       195                         
120            Nostro in Gegenparteirolle  108                         
*/

-- --------------------------------------------------------------------------------
--  KT_ART_NR
-- --------------------------------------------------------------------------------

select   kts.kt_art_nr,
         art.bez_lang,
         count(*) 
from     b2_abr                     abr
         inner join  b2_auf         auf   on    auf.auf_lnr = abr.auf_lnr
                                          and   auf.userbk_nr = abr.userbk_nr
         inner join  kt_stamm       kts   on    kts.userbk_nr = abr.userbk_nr
                                          and   kts.kt_lnr = auf.kt_lnr
         inner join  kt1art         art   on    art.userbk_nr = kts.userbk_nr
                                          and   art.kt_art_nr = kts.kt_art_nr
                                          and   art.sprache_cd = 1
where    abr.userbk_nr = 949
   and   abr.b2_auf_art_cd in (10,110) -- Kunde und Nostro in Kundenrolle
group by kts.kt_art_nr,
         art.bez_lang
order by kts.kt_art_nr,
         art.bez_lang
;

/*
Wertebereich KT_ART (userbk_nr = 949)

KT_ART_NR                   BEZ_LANG                                             COUNT(*)                    
1                           Kontokorrent                                         7                           
160                         Depot Säule3a bankeigene                             78                          
194                         VD Vorsorgedepot Standardprodukt                     30                          
197                         VD Prifonds Vorsorgedepot Standardprodukt            2                           
5001                        Depot Ordinario                                      109854                      
5002                        Depot VV                                             9724                        
5003                        Mitglieder-Depot                                     9                           
5010                        *EWS Finanzanlagen Niederstwert                      3                           
5011                        *EWS Handelsbestand Marktwert                        10                          
5013                        Depot Plus                                           48                          
5020                        Institutionelle                                      22                          
5030                        Anlageplandepot                                      415                         
5051                        Depotstellen                                         160                         
5055                        Nostro Depot Liberty Handelskonto / Marktwert (EW)   3                           
5062                        Banken- / Effektenhändler- / Lieferd-Depot           13                          
5074                        Nostro Depot FA Accruel (EW)                         69                          
5075                        Nostro Depot FA Niederstwert (EW)                    29                          
5076                        Nostro Depot HB Marktwert (EW)                       18                          
5077                        Nostro Depot HB Niederstwert (EW)                    9                           
5078                        Nostro Depot Handelskonto / Marktwert (EW)           10                          
5079                        Nostro Depot Beteiligungen (EW)                      4                           
5091                        Lieferdepot                                          176                         
5101                        Collateral Lieferanspruch                            1                           
*/


select   ka.kt_art_nr,
         ka.BEZ_KURZ     as kt_art_bez_kurz,
       --ka.BEZ_MITTEL   as kt_art_bez_mittel,
         ka.BEZ_LANG     as kt_art_bez_lang,
         az.grp_art,
         ga.BEZ_KURZ     as grp_art_bez_kurz,
         ga.BEZ_MITTEL   as grp_art_bez_mittel,
       --ga.BEZ_LANG     as grp_art_bez_lang,
         az.gnr,
         gr.BEZ_KURZ     as gnr_bez_kurz,
         gr.BEZ_MITTEL   as gnr_bez_mittel,
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
 --and   az.gnr = 10
 --and   az.GRP_ART = 5339
   and   lower(ka.bez_lang) like '%depot%'
order by ka.kt_art_nr      asc,
         az.grp_art        asc,
         az.gnr            asc;



select   kt.kt_lnr,
         kt.kt_nr,
         kt.kt_art_nr,
         kd.kd_nr,
         kd.name_1      as last_name,
         kd.vorname     as first_name,
         ka.bez_lang    as kt_art_bez_lang,
         ga.grp_art,
         ga.bez_lang    as grp_art_bez_lang,
         gr.gnr,
         gr.bez_lang    as gnr_bez_lang,
         kt.*
from     kt_stamm                   kt
         inner join  kd_stamm       kd on    kd.kd_lnr = kt.kd_lnr and kd.userbk_nr = kt.userbk_nr
         inner join  kt1art         ka on    ka.kt_art_nr = kt.kt_art_nr and ka.userbk_nr = kt.userbk_nr and ka.sprache_cd = 1
         inner join  kt_art_zuo     az on    az.kt_art_nr = ka.kt_art_nr and az.userbk_nr = ka.userbk_nr
         inner join sr1tabga        ga on    ga.GRP_ART = az.GRP_ART and ga.userbk_nr = ka.userbk_nr and ga.sprache_cd = ka.sprache_cd and ga.tab_bez = 'KT_ART'
         inner join sr1tabg         gr on    gr.GNR = az.GNR and gr.GRP_ART = az.GRP_ART and gr.userbk_nr = ka.userbk_nr and gr.sprache_cd = ka.sprache_cd
where    kt.userbk_nr = 949
   and   lower(gr.bez_lang) like '%depot%'
   and   kt.kt_art_nr in
         (
            5030,    -- Anlagedepot (mit spezial Stückelung)
--            5001,    -- Depot Ordinario (ohne spezial Stückelung)
            null
         )
order by kd.kd_lnr desc   
;

select   
         kd.kd_nr,
         kd.name_1      as last_name,
         kd.vorname     as first_name,
         kt.kt_lnr,
         kt.kt_nr,
         kt.kt_art_nr,
         ka.bez_lang    as kt_art_bez_lang,
         (select count(*) from b2_auf a where a.kt_lnr = kt.kt_lnr and a.userbk_nr = kt.userbk_nr) as auf_count
from     kt_stamm                   kt
         inner join  kd_stamm       kd on    kd.kd_lnr = kt.kd_lnr and kd.userbk_nr = kt.userbk_nr
         inner join  kt1art         ka on    ka.kt_art_nr = kt.kt_art_nr and ka.userbk_nr = kt.userbk_nr and ka.sprache_cd = 1
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

select   s.kd_stat_cd,
         s.bez_lang
from     KD1STAT        s
where    s.userbk_nr = 949
   and   s.sprache_cd = 1
order by s.kd_stat_cd asc
;


select   *
from     sr1tabg                    gr
where    gr.userbk_nr = 949
   and   gr.sprache_cd = 1
;

select   ga.grp_art,
         ga.bez_kurz,
         ga.bez_mittel,
         ga.bez_lang
from     sr1tabga                   ga
where    ga.userbk_nr = 949
   and   ga.sprache_cd = 1
   and   ga.tab_bez = 'KT_ART'
   and   lower(ga.bez_lang) like '%depot%'
order by ga.grp_art asc;


/*
Kontoarten für Test:
   5030  Anlagedepot (mit spezial Stückelung)
   5001  Depot Ordinario (ohne spezial Stückelung)
*/