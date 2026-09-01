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

-- Show all colums of a given table with comments ------------------------------
select  tcol.owner,
        tcol.table_name,
        tcol.column_id      as  col_id,
        tcol.column_name,
        tcol.data_type,
        tcol.data_length,
        tcol.data_precision,
        tcol.data_scale,
        tcol.nullable,
        tcol.num_distinct,
        comm.comments
from    (
            select  '%DAT%'     as  owner_name,
                    'vl%'        as  table_name,
                    '%isin%'        as  column_name
            from    dual
        )                                   sett
        inner join  sys.all_tab_columns     tcol    on  tcol.owner          like upper(sett.owner_name)
                                                    and tcol.table_name     like upper(sett.table_name)
                                                    and tcol.column_name    like upper(sett.column_name)
        left  join  sys.all_col_comments    comm    on  comm.owner          = tcol.owner
                                                    and comm.table_name     = tcol.table_name
                                                    and comm.column_name    = tcol.column_name
order   by  tcol.owner,
tcol.table_name,
tcol.column_id;