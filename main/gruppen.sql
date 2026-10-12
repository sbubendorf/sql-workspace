-- --------------------------------------------------------------------------------
--  Gruppen und Gruppen-Arten
--
--  Finnova GUI: 
--    - Extrax / Gruppierungen/Entscheidungen / Gruppierungsarten
--    - Extrax / Gruppierungen/Entscheidungen / Gruppen modelieren/bilden
-- --------------------------------------------------------------------------------

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
         inner join  kt_art_zuo     az on    az.kt_art_nr   = ka.kt_art_nr 
                                       and   az.userbk_nr   = ka.userbk_nr
         inner join sr1tabga        ga on    ga.userbk_nr   = ka.userbk_nr
                                       and   ga.sprache_cd  = ka.sprache_cd
                                       and   ga.tab_bez     = 'KT_ART'
                                       and   ga.GRP_ART     = az.GRP_ART
         inner join sr1tabg         gr on    gr.userbk_nr   = ka.userbk_nr
                                       and   gr.sprache_cd  = ka.sprache_cd
                                       and   gr.GNR         = az.GNR
                                       and   gr.GRP_ART     = az.GRP_ART
where    ka.userbk_nr = 949
   and   ka.sprache_cd = 1
   and   az.gnr = 10
   and   az.GRP_ART = 5339
order by ka.kt_art_nr      asc,
         az.grp_art        asc,
         az.gnr            asc
;


-- Liste aller Zuordnungs-Tabellen mit deren Gruppierungs-Information ---------------------------------------------
select   replace(ob.object_name, '_ZUO', '') as table_name,
         ob.owner,
         tb.num_rows,
         ga.*
from     sys.all_objects               ob
         inner join  sys.all_tables    tb    on    tb.owner = ob.owner 
                                             and   tb.table_name = ob.object_name
         left  join  sr1tabga          ga    on    ga.userbk_nr = 949 
                                             and   ga.tab_bez = replace(ob.object_name, '_ZUO', '')
                                             and   ga.sprache_cd = 1
where    1=1
   and   ob.owner like 'F2%DAT%'
   and   ob.object_name like '%ZUO'
order by ob.object_name;
;

select   replace(ob.object_name, '_ZUO', '') as table_name,
         tb.num_rows,
         sum(case when ga.userbk_nr is not null then 1 else 0 end) as num_grp_art
from     sys.all_objects               ob
         inner join  sys.all_tables    tb    on    tb.owner = ob.owner 
                                             and   tb.table_name = ob.object_name
         left  join  sr1tabga          ga    on    ga.userbk_nr = 949 
                                             and   ga.tab_bez = replace(ob.object_name, '_ZUO', '')
                                             and   ga.sprache_cd = 1
where    1=1
   and   ob.owner like 'F2%DAT%'
   and   ob.object_name like '%ZUO'
group by replace(ob.object_name, '_ZUO', ''),
         tb.num_rows
order by replace(ob.object_name, '_ZUO', '');
;

select   *
from     sr1tabga    a
where    a.table_name = 'KT_ART'
;

select   a.kt_art_nr
         , a.grp_art
         , a.gnr
         ,  (
               select   a1.bez_lang
               from     sr1tabga a1
               where    a1.userbk_nr = a.userbk_nr
                  and   a1.sprache_cd = 1
                  and   a1.grp_art = a.grp_art
            )  as "Gruppierungsart"
         ,  (
               select   a2.bez_lang
               from     sr1tabg a2
               where    a2.userbk_nr = a.userbk_nr
                  and a2.sprache_cd = 1
                  and a2.grp_art = a.grp_art
                  and a2.gnr = a.gnr
            ) as "Gruppe"
from kt_art_zuo a
where a.kt_art_nr in (&&kt_art)
  and a.grp_art not in (5305, 5306)
  and a.grp_art not in (5407)  -- wird von Team IB gemacht
  and a.userbk_nr = &userbk_nr
order by a.grp_art asc, a.gnr asc, a.kt_art_nr asc
;

-- KT_ART - Gruppenarten
select   ga.grp_art,
         ga.BEZ_KURZ,
         ga.BEZ_MITTEL,
         ga.BEZ_LANG
from     sr1tabga    ga
where    1=1
   and   ga.userbk_nr = 949
   and   ga.sprache_cd = 1
   and   ga.tab_bez = 'KT_ART'
order by ga.grp_art asc;

-- KT_ART - Gruppen
select   g.gnr,
         g.grp_art,
         g.BEZ_KURZ,
         g.BEZ_MITTEL,
         g.BEZ_LANG
from     sr1tabg    g
where    1=1
   and   g.userbk_nr = 949
   and   g.sprache_cd = 1
   and   g.tab_bez = 'KT_ART'
order by g.gnr asc;


select   *
from     sr1tabg
;