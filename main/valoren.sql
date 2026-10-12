-- Valoren Query
-- $Revision$
-- Purpose: Query valoren master and text data
-- Author:
-- Date:
-- ============================================================================

SELECT  vlst.VL_LNR,
        vlre.vl_ref_lnr,
        vlst.tk_sym,
        vlst.isin_nr,
        vlst.VL_TEXT_LNR,
        vltx.TEXT_REC,
        vltx.*
FROM    vl_stamm                    vlst
        inner join  vl_ref          vlre    on  vlre.VL_LNR = vlst.VL_LNR and vlre.USERBK_NR = vlst.USERBK_NR
        inner join  vl_text         vltx    on  vltx.VL_TEXT_LNR = vlst.VL_TEXT_LNR and vltx.USERBK_NR = vlst.USERBK_NR
WHERE   1=1
    AND vlst.USERBK_NR = 949
    AND vlst.TK_SYM = 'AAPL'
;



-- Valoren ohne Bezeichnung ---------------------------------------
select   s.vl_lnr,
         s.VL_NR,
         s.TK_SYM,
         s.ISIN_NR,
         t.TEXT_REC,
         t.TEXT_REC_KURZ,
         r.vl_ref_lnr,
         b.kt_lnr
from     vl_stamm                s
         left  join  vl_text     t  on t.vl_text_lnr = s.vl_text_lnr and t.userbk_nr = s.userbk_nr and t.vl_abschnitt_nr = 0 and t.sprache_cd = 1
         left  join  vl_ref      r  on r.vl_lnr = s.vl_lnr and r.userbk_nr = s.userbk_nr
         left  join  kt_saldo    b  on b.VL_REF_LNR = r.VL_REF_LNR and b.userbk_nr = r.userbk_nr
where    s.USERBK_NR = 949
   and   t.text_rec is null
fetch first 500 rows only
;

-- Valoren mit mehr als einer Bezeichnung ---------------------------------------
select   s.vl_lnr,
         s.VL_NR,
         s.TK_SYM,
         s.ISIN_NR,
         count(*) as bezeichnung_count
from     vl_stamm                s
         left  join  vl_text     t  on t.vl_text_lnr = s.vl_text_lnr and t.userbk_nr = s.userbk_nr and t.vl_abschnitt_nr = 0 and t.sprache_cd = 1
where    s.USERBK_NR = 949
group by s.vl_lnr,
         s.VL_NR,
         s.TK_SYM,
         s.ISIN_NR
having   count(*) > 1
fetch first 500 rows only
;