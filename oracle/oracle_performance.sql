select  *
from    v$parameter
where   name like 'optimizer_features_enable%'
;

-- Show active optimizer version --------------------------------------------------------------------------------
select  *
from    v$parameter_valid_values 
where   name = 'optimizer_features_enable' 
order   by  ordinal desc
;

-- Show patched currently configured -------------------------------------------
select  name, 
        sql_text, 
        created, 
        last_modified, 
        status 
from    dba_sql_patches;

select  * 
from    dba_sql_patches;


-- Show active SQL profiles ----------------------------------------------------
select  name, 
        sql_text, 
        created, 
        last_modified, 
        status 
from    dba_sql_profiles
where   status = 'ENABLED';

-- Oracle fix control ----------------------------------------------------------
select  fc.bugno,
        fc.value as is_active,
        fc.sql_feature,
        fc.description,
        fc.optimizer_feature_enable,
        fc.event,
        fc.is_default,
        fc.con_id
from    v$system_fix_control fc
where   1=1
  --and fc.bugno = 22174392    -- first k row optimization for window function rownum predicate
    and fc.value = 1        -- Only active fixes
order   by  fc.bugno        desc
;


select  *
from    v$system_fix_control 
where   bugno=28173995;


select  *
from    v$sql

where   sql_text like 'select * from (select table_0_.CASE_NR as col_0_, %'   --table_0_.EVT_START as col_1_, table_0_.CREATE_ITEM_TYPE_ID as col_2_, table_0_.CREATE_ITEM_KEY0_NR as col_2__1, table_7_.CHANNEL_UID as col_3_, case when ( ( ( (table_1_.EVT_END is null ) ) or ( table_1_.CASE_STEP_NR=table_0_.CURRENT_CASE_STEP_NR ) ) and table_1_.RESPONSIBLE_TYPE_UID='*****' and exists ( select '*****' as col_14_ from BSI_UC_ADVISOR table_8_ where table_8_.ADVISOR_UID=table_1_.RESPONSIBLE_ADVISOR_UID and table_8_.IS_UNIQUE_VALUE = cast('*****' as number('*****','*****')) ) ) then ( COALESCE(( cast(bsiutl_ucText(table_1_.RESPONSIBLE_ADVISOR_UID, ?) as varchar2('*****' char)) ), ( '*****' )) || COALESCE(( cast(case when ( COALESCE(( length(( select case ( table_11_.PRIVACY_STATUS_UID ) when ( '*****' ) then ( '*****' ) else ( case when ( not (table_11_.NAME2 is null ) ) then ( COALESCE(( cast(table_11_.NAME2 as varchar2('*****' char)) ), ( '*****' )) || '*****' || COALESCE(( cast(table_11_.NAME1 as varchar2('*****' char)) ), ( '*****' )) ) else ( table_11_.NAME1 ) end ) end as col_15_ from BSI_CASE_INPUT table_9_ join BSI_CUSTOMER_ADVISOR table_10_ on table_9_.ITEM_TYPE_ID='*****' and table_9_.ITEM_KEY0_NR=table_10_.CUSTOMER_NR and table_10_.ADVISOR_UID=table_1_.RESPONSIBLE_ADVISOR_UID join BSI_CUSTOMER table_11_ on table_10_.ADVISOR_USER_NR = table_11_.CUSTOMER_NR and table_11_.TYPE_UID in ( '*****', '*****', '*****', '*****', '*****', '*****' ) and not ( table_11_.TYPE_UID<>'*****' and not ( '*****' = '*****' ) and '*****' = case ( table_11_.X_PARTNER_TYPE_UID ) when ( '*****' ) then ( '*****' ) when ( '*****' ) then ( '*****' ) else ( '*****' ) end ) and not exists ( select '*****' as rxcol_1_ from BSI_TUTORIAL_ITEM rxtable_1_ where rxtable_1_.ITEM_TYPE_ID='*****' and rxtable_1_.ITEM_KEY0_NR=table_11_.CUSTOMER_NR ) where table_9_.PROCESS_INPUT_UID='*****' and table_9_.CASE_NR=table_0_.CASE_NR and exists ( select '*****' as rxcol_1_ from BSI_CASE rxtable_1_ where table_9_.CASE_NR=rxtable_1_.CASE_NR and '*****' = '*****' and not exists ( select '*****' as rxcol_2_ from BSI_CASE_INPUT rxtable_3_ join BSI_CUSTOMER rxtable_4_ on rxtable_3_.PROCESS_INPUT_UID='*****' and rxtable_4_.CUSTOMER_NR=rxtable_3_.ITEM_KEY0_NR where rxtable_1_.CASE_NR=rxtable_3_.CASE_NR and not ( not ( rxtable_4_.TYPE_UID<>'*****' and not ( '*****' = '*****' ) and '*****' = case ( rxtable_4_.X_PARTNER_TYPE_UID ) when ( '*****' ) then ( '*****' ) when ( '*****' ) then ( '*****' ) else ( '*****' ) end ) ) ) and not exists ( select '*****' as rxcol_3_ from BSI_TUTORIAL_ITEM rxtable_5_ where rxtable_5_.ITEM_TYPE_ID='*****' and rxtable_5_.ITEM_KEY0_NR=rxtable_1_.CASE_NR ) union all select '*****' as rxcol_1_ from BSI_DUAL rxtable_2_ where table_9_.CASE_NR='*****' ) )) ), ( '*****' )) = '*****' ) then ( null ) else ( ? || COALESCE(( cast(( select case ( table_14_.PRIVACY_STATUS_UID ) when ( '*****' ) then ( '*****' ) else ( case when ( not (table_14_.NAME2 is null ) ) then ( COALESCE(( cast(table_14_.NAME2 as varchar2('*****' char)) ), ( '*****' )) || '*****' || COALESCE(( cast(table_14_.NAME1 as varchar2('*****' char)) ), ( '*****' )) ) else ( table_14_.NAME1 ) end ) end as col_16_ from BSI_CASE_INPUT table_12_ join BSI_CUSTOMER_ADVISOR table_13_ on table_12_.ITEM_TYPE_ID='*****' and table_12_.ITEM_KEY0_NR=table_13_.CUSTOMER_NR and table_13_.ADVISOR_UID=table_1_.RESPONSIBLE_ADVISOR_UID join BSI_CUSTOMER table_14_ on table_13_.ADVISOR_USER_NR = table_14_.CUSTOMER_NR and table_14_.TYPE_UID in ( '*****', '*****', '*****', '*****', '*****', '*****' ) and not ( table_14_.TYPE_UID<>'*****' and not ( '*****' = '*****' ) and '*****' = case ( table_14_.X_PARTNER_TYPE_UID ) when ( '*****' ) then ( '*****' ) when ( '*****' ) then ( '*****' ) else ( '*****' ) end ) and not exists ( select '*****' as rxcol_1_ from BSI_TUTORIAL_ITEM rxtable_1_ where rxtable_1_.ITEM_TYPE_ID='*****' and rxtable_1_.ITEM_KEY0_NR=table_14_.CUSTOMER_NR ) where table_12_.PROCESS_INPUT_UID='*****' and table_12_.CASE_NR=table_0_.CASE_NR and exists ( select '*****' as rxcol_1_ from BSI_CASE rxtable_1_ where table_12_.CASE_NR=rxtable_1_.CASE_NR and '*****' = '*****' and not exists ( select '*****' as rxcol_2_ from BSI_CASE_INPUT rxtable_3_ join BSI_CUSTOMER rxtable_4_ on rxtable_3_.PROCESS_INPUT_UID='*****' and rxtable_4_.CUSTOMER_NR=rxtable_3_.ITEM_KEY0_NR where rxtable_1_.CASE_NR=rxtable_3_.CASE_NR and not ( not ( rxtable_4_.TYPE_UID<>'*****' and not ( '*****' = '*****' )


;

select  dbid,
        sql_id,
        to_char(substr(sql_text,1,400))
from    dba_hist_sqltext
where   sql_text like '%select table_0_.CASE_NR as col_0_, %'   --table_0_.EVT_START as col_1_, table_0_.CREATE_ITEM_TYPE_ID as col_2_, table_0_.CREATE_ITEM_KEY0_NR as col_2__1, table_7_.CHANNEL_UID as col_3_, case when ( ( ( (table_1_.EVT_END is null ) ) or ( table_1_.CASE_STEP_NR=table_0_.CURRENT_CASE_STEP_NR ) ) and table_1_.RESPONSIBLE_TYPE_UID='*****' and exists ( select '*****' as col_14_ from BSI_UC_ADVISOR table_8_ where table_8_.ADVISOR_UID=table_1_.RESPONSIBLE_ADVISOR_UID and table_8_.IS_UNIQUE_VALUE = cast('*****' as number('*****','*****')) ) ) then ( COALESCE(( cast(bsiutl_ucText(table_1_.RESPONSIBLE_ADVISOR_UID, ?) as varchar2('*****' char)) ), ( '*****' )) || COALESCE(( cast(case when ( COALESCE(( length(( select case ( table_11_.PRIVACY_STATUS_UID ) when ( '*****' ) then ( '*****' ) else ( case when ( not (table_11_.NAME2 is null ) ) then ( COALESCE(( cast(table_11_.NAME2 as varchar2('*****' char)) ), ( '*****' )) || '*****' || COALESCE(( cast(table_11_.NAME1 as varchar2('*****' char)) ), ( '*****' )) ) else ( table_11_.NAME1 ) end ) end as col_15_ from BSI_CASE_INPUT table_9_ join BSI_CUSTOMER_ADVISOR table_10_ on table_9_.ITEM_TYPE_ID='*****' and table_9_.ITEM_KEY0_NR=table_10_.CUSTOMER_NR and table_10_.ADVISOR_UID=table_1_.RESPONSIBLE_ADVISOR_UID join BSI_CUSTOMER table_11_ on table_10_.ADVISOR_USER_NR = table_11_.CUSTOMER_NR and table_11_.TYPE_UID in ( '*****', '*****', '*****', '*****', '*****', '*****' ) and not ( table_11_.TYPE_UID<>'*****' and not ( '*****' = '*****' ) and '*****' = case ( table_11_.X_PARTNER_TYPE_UID ) when ( '*****' ) then ( '*****' ) when ( '*****' ) then ( '*****' ) else ( '*****' ) end ) and not exists ( select '*****' as rxcol_1_ from BSI_TUTORIAL_ITEM rxtable_1_ where rxtable_1_.ITEM_TYPE_ID='*****' and rxtable_1_.ITEM_KEY0_NR=table_11_.CUSTOMER_NR ) where table_9_.PROCESS_INPUT_UID='*****' and table_9_.CASE_NR=table_0_.CASE_NR and exists ( select '*****' as rxcol_1_ from BSI_CASE rxtable_1_ where table_9_.CASE_NR=rxtable_1_.CASE_NR and '*****' = '*****' and not exists ( select '*****' as rxcol_2_ from BSI_CASE_INPUT rxtable_3_ join BSI_CUSTOMER rxtable_4_ on rxtable_3_.PROCESS_INPUT_UID='*****' and rxtable_4_.CUSTOMER_NR=rxtable_3_.ITEM_KEY0_NR where rxtable_1_.CASE_NR=rxtable_3_.CASE_NR and not ( not ( rxtable_4_.TYPE_UID<>'*****' and not ( '*****' = '*****' ) and '*****' = case ( rxtable_4_.X_PARTNER_TYPE_UID ) when ( '*****' ) then ( '*****' ) when ( '*****' ) then ( '*****' ) else ( '*****' ) end ) ) ) and not exists ( select '*****' as rxcol_3_ from BSI_TUTORIAL_ITEM rxtable_5_ where rxtable_5_.ITEM_TYPE_ID='*****' and rxtable_5_.ITEM_KEY0_NR=rxtable_1_.CASE_NR ) union all select '*****' as rxcol_1_ from BSI_DUAL rxtable_2_ where table_9_.CASE_NR='*****' ) )) ), ( '*****' )) = '*****' ) then ( null ) else ( ? || COALESCE(( cast(( select case ( table_14_.PRIVACY_STATUS_UID ) when ( '*****' ) then ( '*****' ) else ( case when ( not (table_14_.NAME2 is null ) ) then ( COALESCE(( cast(table_14_.NAME2 as varchar2('*****' char)) ), ( '*****' )) || '*****' || COALESCE(( cast(table_14_.NAME1 as varchar2('*****' char)) ), ( '*****' )) ) else ( table_14_.NAME1 ) end ) end as col_16_ from BSI_CASE_INPUT table_12_ join BSI_CUSTOMER_ADVISOR table_13_ on table_12_.ITEM_TYPE_ID='*****' and table_12_.ITEM_KEY0_NR=table_13_.CUSTOMER_NR and table_13_.ADVISOR_UID=table_1_.RESPONSIBLE_ADVISOR_UID join BSI_CUSTOMER table_14_ on table_13_.ADVISOR_USER_NR = table_14_.CUSTOMER_NR and table_14_.TYPE_UID in ( '*****', '*****', '*****', '*****', '*****', '*****' ) and not ( table_14_.TYPE_UID<>'*****' and not ( '*****' = '*****' ) and '*****' = case ( table_14_.X_PARTNER_TYPE_UID ) when ( '*****' ) then ( '*****' ) when ( '*****' ) then ( '*****' ) else ( '*****' ) end ) and not exists ( select '*****' as rxcol_1_ from BSI_TUTORIAL_ITEM rxtable_1_ where rxtable_1_.ITEM_TYPE_ID='*****' and rxtable_1_.ITEM_KEY0_NR=table_14_.CUSTOMER_NR ) where table_12_.PROCESS_INPUT_UID='*****' and table_12_.CASE_NR=table_0_.CASE_NR and exists ( select '*****' as rxcol_1_ from BSI_CASE rxtable_1_ where table_12_.CASE_NR=rxtable_1_.CASE_NR and '*****' = '*****' and not exists ( select '*****' as rxcol_2_ from BSI_CASE_INPUT rxtable_3_ join BSI_CUSTOMER rxtable_4_ on rxtable_3_.PROCESS_INPUT_UID='*****' and rxtable_4_.CUSTOMER_NR=rxtable_3_.ITEM_KEY0_NR where rxtable_1_.CASE_NR=rxtable_3_.CASE_NR and not ( not ( rxtable_4_.TYPE_UID<>'*****' and not ( '*****' = '*****' )
;



select  *
from    v$session_longops   slo
        inner join  v$sql   sql on  sql.sql_id = slo.sql_id
order   by  slo.start_time desc
;


-- Find SQL statements with info from Dynatrace pure path --------------------------------------------------------------------------------
--  1. Paste select statement from Dynatrace into Toad editor
--  2. Replace String "'*****'" with "%"
--  3. Replace String "?" with "%"
--  4. Replace String "..." with "%"

with w_sql as
(
    select
            lower(
                -- Insert Dynatrace statement here!
                'select * from (select count(distinct COALESCE(( cast(table_0_.ITEM_KEY0_NR as varchar2(% char)) ), ( % )) || % || COALESCE(( cast(table_0_.ITEM_TYPE_ID as varchar2(% char)) ), ( % ))) as col_0_ from BSI_NEWSFEED table_0_ left outer join BSI_NEWSFEED_USER table_1_ on table_1_.NEWSFEED_NR=table_0_.NEWSFEED_NR and table_1_.USER_NR=% where exists ( select % as col_1_ from BSI_NEWSFEED table_2_ where table_2_.NEWSFEED_NR=table_0_.NEWSFEED_NR and table_2_.ITEM_TYPE_ID<>% union all select % as col_1_ from BSI_NEWSFEED table_3_ join BSI_COMMUNICATION table_4_ on table_3_.ITEM_TYPE_ID=% and table_3_.ITEM_KEY0_NR=table_4_.COMMUNICATION_NR where table_3_.NEWSFEED_NR=table_0_.NEWSFEED_NR and table_3_.ITEM_TYPE_ID=% and table_4_.TYPE_UID = % ) and not exists ( select % as col_2_ from BSI_GLOBAL_KEY_STATE table_5_ where table_5_.ITEM_TYPE_ID=table_0_.ITEM_TYPE_ID and table_5_.ITEM_KEY0_NR=table_0_.ITEM_KEY0_NR ) and not ( exists ( select % as col_3_ from BSI_NEWSFEED_USER table_6_ where table_0_.NEWSFEED_NR=table_6_.NEWSFEED_NR and table_6_.USER_NR=% and table_6_.IS_READ=% ) ) and ( ( not ( table_0_.CHANGED_BY_ITEM_TYPE_ID in (%,%) ) ) or ( table_0_.CHANGED_BY_ITEM_KEY0_NR in ( select table_7_.USER_NR as col_4_ from BSI_USER table_7_ where table_7_.USER_NR in (%,%,%, %) union all select % as col_4_ from BSI_DUAL table_8_ ) ) ) and table_0_.NEWSFEED_NR in ( select table_9_.NEWSFEED_NR as col_5_ from BSI_NEWSFEED_RESPONSIBLE table_9_ where table_9_.CUSTOMER_NR in ( select table_10_.USER_NR as col_6_ from BSI_USER table_10_ where table_10_.IS_ACTIVE = cast(% as number(%,%)) and table_10_.USER_NR=% union all select table_11_.USER_NR as col_6_ from BSI_USER table_11_ where table_11_.IS_ACTIVE = cast(% as number(%,%)) and table_11_.USER_NR in ( select table_12_.USER_NR as col_7_ from BSI_USER_SUBSTITUTE table_12_ where table_12_.SUBSTITUTE_USER_NR=% ) ) ) and table_0_.ITEM_TYPE_ID in (%,%,%, %) and table_0_.EVT_CHANGE >= trunc(%) and table_0_.CHANGED_BY_ITEM_TYPE_ID in (%,%) and not ( table_0_.CHANGED_BY_ITEM_KEY0_NR in ( select table_13_.USER_NR as col_8_ from BSI_USER table_13_ where table_13_.USER_NR in (%,%,%, %) ) )) where rownum <= %'
            ) || '%' as sql_text
    from    dual
)
select  sql_id,
        executions,
        user_io_wait_time,
        elapsed_time,
        last_active_time,
        regexp_replace(sql_text, '\s{2,}', ' ') as sql_text,
        sql_fulltext
from    v$sql
where   1=1
    and sql_id = '5fhzbwabf2xhr'
    and lower(regexp_replace(sql_fulltext, '\s{2,}', ' ')) like (select sql_text from w_sql)
order   by  last_active_time desc
;



select  a.snap_id,
        a.instance_number inst_id, 
        a.plan_hash_value, 
        to_char(b.begin_interval_time , 'dd.mm.yy hh24:mi') btime, 
        to_char(b.end_interval_time   , 'dd.mm.yy hh24:mi') etime, 
        abs(extract(minute from (b.end_interval_time-b.begin_interval_time)) + extract(hour from (b.end_interval_time-b.begin_interval_time))*60 + extract(day from (b.end_interval_time-b.begin_interval_time))*24*60) minutes,
        a.executions_total,
        a.executions_delta, 
        round(ELAPSED_TIME_delta/1000000/greatest(executions_delta,1),4) avg_duration_sec 
from    dba_hist_SQLSTAT                a
        inner join dba_hist_snapshot    b   on  b.snap_id = a.snap_id and b.instance_number = b.instance_number
where   1=1
    and sql_id='fbm7jhwbqjjpy'
order   by  a.snap_id desc, 
            a.instance_number;




-- Find long running statements
select  a.sql_id,
        a.plan_hash_value, 
        to_char(b.begin_interval_time , 'dd.mm.yy hh24:mi') btime, 
        to_char(b.end_interval_time   , 'dd.mm.yy hh24:mi') etime, 
        abs(
            extract(minute from (b.end_interval_time-begin_interval_time)) + 
            extract(hour   from (b.end_interval_time-begin_interval_time))*60 + 
            extract(day    from (b.end_interval_time-begin_interval_time))*24*60) minutes,
        a.executions_total          as  exec_total,
        a.executions_delta          as  exec_delta,
        a.elapsed_time_total,
        round(elapsed_time_total/1000000/greatest(executions_total,1),4) avg_duration_sec,
        s.sql_text,
        s.sql_fulltext
from    dba_hist_sqlstat                    a
        inner join dba_hist_snapshot        b on b.snap_id = a.snap_id and b.instance_number = b.instance_number
        inner join  v$sqlarea               s on s.sql_id = a.sql_id
where   1=1
    and round(elapsed_time_delta/1000000/greatest(executions_delta,1),4) > 120
--    and sql_text not like '%optstat_snapshot%'
--    and sql_text like '%bsi_hist_occurrence%'
order   by  avg_duration_sec    desc
;


select  snap_id,
        instance_number,
        count(*)
from    dba_hist_sqlstat a
where   1=1
group   by  snap_id,
            instance_number
order   by  1,2;

select  hs.sql_id,
        hs.snap_id,
        hs.instance_number,
        hs.plan_hash_value,
        hs.elapsed_time_delta,
        hs.elapsed_time_total
from    dba_hist_sqlstat    hs
where   1=1
    and hs.sql_id = 'fbm7jhwbqjjpy'
;

select  *
from    dba_hist_sqlstat    hs      
where   1=1
    and hs.snap_id = 4706
    and hs.instance_number = 2
;

select  s.sql_id,
        s.plan_hash_value,
        s.elapsed_time,
        s.executions, 
      --to_char(begin_interval_time , 'dd.mm.yy hh24:mi') btime, 
      --to_char(end_interval_time   , 'dd.mm.yy hh24:mi') etime, 
      --abs(extract(minute from (end_interval_time-begin_interval_time)) + extract(hour from (end_interval_time-begin_interval_time))*60 + extract(day from (end_interval_time-begin_interval_time))*24*60) minutes,
      --s.executions_delta  exec_delta,
      --s.executions_total  exec_total,
        round(elapsed_time/1000000/greatest(executions,1),4) avg_duration_sec,
        s.sql_text,
        s.sql_fulltext
from    v$sqlarea s 
where   1=1
  --and round(elapsed_time_delta/1000000/greatest(executions_delta,1),4) > 120
  --and sql_text not like '%optstat_snapshot%'
order   by  avg_duration_sec desc
;





select  a.sql_id,
        s.executions,
        sum(a.executions_total) exec_total,
        sum(a.executions_delta) exec_delta,
        (select sql_fulltext from v$sqlarea s where s.sql_id = a.sql_id) as sql_fulltext,
        round(avg(a.elapsed_time_delta/1000000/greatest(a.executions_delta,1)),4) as avg_duration,
        count(*)
from    dba_hist_sqlstat a
        inner join  v$sqlarea s on s.sql_id = a.sql_id
where   1=1
    --and round(a.elapsed_time_delta/1000000/greatest(a.executions_delta,1),4) > 120
    and s.sql_fulltext like '%BSI_NEWSFEED%'
group   by  a.sql_id,
            s.executions
order   by  avg_duration desc


select  s.sql_id,
        s.sql_text,
        count(*)
from    v$sqlarea  s
group   by  s.sql_id,
            s.sql_text
having count(*) > 1
order   by  1,2
;

select  s.*
from    v$sqlarea  s
;



select  *
from    dba_hist_sqlstat

where   sql_id = 'd3zcxwcpmhvbr'
order   by  snap_id desc
;

select  min(begin_interval_time_tz)
from    dba_hist_snapshot

where   sql_id = 'd3zcxwcpmhvbr'
order   by  snap_id desc
;


select  *
from    dba_hist_snapshot   ss
order   by  ss.begin_interval_time
;

select  *
from    v$sql
where   sql_id='d3zcxwcpmhvbr'

where   sql_id in
        (
            '5qub3swg9w2q2',
            'dmu8gvz26xsnf',
            '9t72r52kgg9yk',
            '764mk1pt6brr6'
        )





select  *
from    v$sesstat
;

select  *
from    v$session       ses
        inner join  v$sql sql on sql.sql_id = ses.sql_id
where   schemaname='BSIUSER'
    and status='ACTIVE'
    
;









DBA_HIST_SQLBIND
DBA_HIST_SQLCOMMAND_NAME
DBA_HIST_SQLSTAT
DBA_HIST_SQLTEXT
DBA_HIST_SQL_BIND_METADATA
DBA_HIST_SQL_PLAN
DBA_HIST_SQL_SUMMARY


select  *
from    dba_hist_sqlstat
where   sql_id='d3zcxwcpmhvbr'
;

create table sbu_sql_stat as
select  snap.snap_id,
        snap.instance_number,
        snap.startup_time,
        snap.begin_interval_time,
        snap.end_interval_time,
        stat.sql_id,
        stat.plan_hash_value,
        stat.optimizer_cost,
        stat.optimizer_mode,
        stat.module,
        stat.action,
        stat.sql_profile,
        stat.parsing_schema_name,
        stat.fetches_total,
        stat.fetches_delta,
        stat.end_of_fetch_count_total,
        stat.end_of_fetch_count_delta,
        stat.sorts_total,
        stat.sorts_delta,
        stat.executions_total,
        stat.executions_delta,
        stat.loads_total,
        stat.loads_delta,
        stat.invalidations_total,
        stat.invalidations_delta,
        stat.parse_calls_total,
        stat.parse_calls_delta,
        stat.disk_reads_total,
        stat.disk_reads_delta,
        stat.buffer_gets_total,
        stat.buffer_gets_delta,
        stat.rows_processed_total,
        stat.rows_processed_delta,
        stat.cpu_time_total,
        stat.cpu_time_delta,
        stat.elapsed_time_total,
        stat.elapsed_time_delta,
        stat.iowait_total,
        stat.iowait_delta,
        stat.physical_read_requests_total,
        stat.physical_read_requests_delta,
        stat.physical_read_bytes_total,
        stat.physical_read_bytes_delta,
        stat.bind_data
from    dba_hist_snapshot               snap
        inner join  dba_hist_sqlstat    stat    on  stat.instance_number = snap.instance_number and stat.snap_id = snap.snap_id
--where   stat.sql_id='d3zcxwcpmhvbr'
order   by  begin_interval_time
;


-- --------------------------------------------------------------------------------
-- Find SQL statement 
select  snap.snap_id,
        snap.begin_interval_time,
        snap.end_interval_time,
        stat.executions_delta,
        round(stat.elapsed_time_delta/1000000/greatest(stat.executions_delta,1),4) as avg_duration,
        sqla.sql_id,
        sqla.sql_text,
        sqla.sql_fulltext
from    dba_hist_snapshot               snap
        inner join  dba_hist_sqlstat    stat    on  stat.instance_number = snap.instance_number and stat.snap_id = snap.snap_id
        inner join  v$sqlstats           sqla    on  sqla.sql_id = stat.sql_id
where   1=1
    and lower(sqla.sql_fulltext) like '%bsi_newsfeed%'
order   by  avg_duration desc
;

-- --------------------------------------------------------------------------------
-- Show snapshot durations 
with
    function get_minutes_between(i_from timestamp, i_to timestamp) return number is
    begin
        return round(
            extract( day    from i_to - i_from) * 24 * 60 +
            extract( hour   from i_to - i_from)      * 60 +
            extract( minute from i_to - i_from)          
        );
    end;
select  ss.snap_id,
        ss.begin_interval_time,
        ss.end_interval_time,
        get_minutes_between(ss.begin_interval_time, ss.end_interval_time) snap_minutes
from    dba_hist_snapshot   ss
;




        

-- --------------------------------------------------------------------------------
-- Show long running statements 
select  stat.sql_id,
        stat.disk_reads,
        stat.executions,
        stat.elapsed_time,
        round(stat.elapsed_time/1000000/greatest(stat.executions,1),4) as avg_duration,
        stat.sql_text
from    v$sqlstats      stat
where   lower(stat.sql_fulltext) like '%bsi_newsfeed%'
order   by  round(stat.elapsed_time/1000000/greatest(stat.executions,1),4) desc
;


-- --------------------------------------------------------------------------------
-- Show statements generating high I/O
select  stat.sql_id,
        stat.disk_reads,
        stat.executions,
        stat.elapsed_time,
        stat.sql_text
from    v$sqlstats      stat
order   by  stat.disk_reads desc
;

-- --------------------------------------------------------------------------------
-- Show statements using high CPU
select  stat.sql_id,
        stat.buffer_gets,
        stat.executions,
        stat.elapsed_time,
        stat.sql_text
from    v$sqlstats      stat
order   by  stat.buffer_gets desc
;

-- --------------------------------------------------------------------------------
-- Show memory hog statements 
select  stat.sql_id,
        stat.sharable_mem,
        stat.executions,
        stat.elapsed_time,
        stat.sql_text
from    v$sqlstats      stat
order   by  stat.sharable_mem desc
;

