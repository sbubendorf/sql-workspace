alter session set current_schema = bsi;


explain plan for 
select  cust.customer_nr,
        cust.customer_no,
        cust.display_name,
        cust.is_active,
        cust.evt_birth,
        bsiutl_uctext(cust.nationality_country_uid,246)        as nationality,
        bsiutl_uctext(cust.x_source_system_uid,246)            as source,
        bsiutl_uctext(cust.rating_uid,246)                     as rating_name,
        bsiutl_uctext(cust.type_uid,246)                       as type_name,
        cust.private_street,
        cust.private_address,
        (select addr.channel_value from bsi.bsi_address addr where addr.item_key0_nr = cust.customer_nr and addr.channel_uid = 113638 and addr.is_default_address = 1 and rownum = 1) as addr_telefon,
        (select addr.channel_value from bsi.bsi_address addr where addr.item_key0_nr = cust.customer_nr and addr.channel_uid = 113640 and addr.is_default_address = 1 and rownum = 1) as addr_mobile,
        (select addr.channel_value from bsi.bsi_address addr where addr.item_key0_nr = cust.customer_nr and addr.channel_uid = 113641 and addr.is_default_address = 1 and rownum = 1) as addr_email
from    bsi_customer cust
where   1=1
    and cust.customer_nr = 3
  --and cust.customer_no = ''
;

select  *
from    table(dbms_xplan.display('plan_table',null,'basic'));

/*
Plan hash value: 596198388
 
----------------------------------------------------------------
| Id  | Operation                            | Name            |
----------------------------------------------------------------
|   0 | SELECT STATEMENT                     |                 |
|   1 |  COUNT STOPKEY                       |                 |
|   2 |   TABLE ACCESS BY INDEX ROWID BATCHED| BSI_ADDRESS     |
|   3 |    INDEX RANGE SCAN                  | BSI_ADDRESSX5   |
|   4 |  COUNT STOPKEY                       |                 |
|   5 |   TABLE ACCESS BY INDEX ROWID BATCHED| BSI_ADDRESS     |
|   6 |    INDEX RANGE SCAN                  | BSI_ADDRESSX5   |
|   7 |  COUNT STOPKEY                       |                 |
|   8 |   TABLE ACCESS BY INDEX ROWID BATCHED| BSI_ADDRESS     |
|   9 |    INDEX RANGE SCAN                  | BSI_ADDRESSX5   |
|  10 |  TABLE ACCESS BY INDEX ROWID         | BSI_CUSTOMER    |
|  11 |   INDEX UNIQUE SCAN                  | BSI_CUSTOMERXPK |
----------------------------------------------------------------

*/


select  s.sql_id,
        s.parsing_schema_name,
        trunc(to_date(s.first_load_time,'yyyy-mm-dd/hh24:mi:ss')) as first_load,
        trunc(to_date(s.last_load_time,'yyyy-mm-dd/hh24:mi:ss')) as last_load,
        s.last_load_time,
        s.last_active_time,
        s.executions,
        s.elapsed_time,
        round((s.elapsed_time /1000000) / greatest(s.executions,1), 2) elapsed_time_per_exec_sec,
        s.sql_text,
        s.sql_fulltext
from    v$sql       s
where   1=1
order   by  elapsed_time_per_exec_sec desc
;



select  v.sql_id,
        se.sid, 
        se.status,
        se.username, 
        v.child_number, 
        to_char(v.executions, '999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''.''''')  as  executions, 
        to_char((v.elapsed_time /1000000) / greatest(v.executions,1), '999G999G990D000000', 'NLS_NUMERIC_CHARACTERS=''.''''')     as  seconds_per_exec, 
        substr(sql_text, 1, 160),
        to_char(v.elapsed_time, '999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''.''''')    as  elapsed_time, 
        to_char(v.cpu_time, '999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''.''''')     as  cpu_time, 
        v.plsql_exec_time, 
        to_char(v.user_io_wait_time, '999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''.''''')   as  user_io_wait_time, 
        to_char(v.last_active_time,'yyyy.mm.dd hh24:mi:ss') as last_active_time, 
      --to_char(v.first_load_time,'yyyy.mm.dd hh24:mi:ss') as first_load_time,
        v.first_load_time,
        v.sql_fulltext,
        length(v.sql_fulltext) as sql_length,
        regexp_count(lower(v.sql_fulltext),'join lateral') as num_lateral_joins,
        regexp_count(lower(v.sql_fulltext),'bsi_matrix_partition') as num_matrix_acc
from    v$sql       v
        left join v$session se on se.sql_id = v.sql_id and se.sql_child_number = v.child_number and se.status = 'ACTIVE'
where   1=1
    and v.parsing_schema_name like 'BSIUSER%'
  --and lower(sql_text) like '%bsi_benefit%'
  --and v.sql_text like 'SELECT table_0_.ITEM_NR AS col_0_, table_0_.REFERENCE_DATA AS col_1_, table_0_.REVERSE_REFERENCE_DATA AS col_2_ FROM BSI_%_CHANGE table_0_ %'
  --and v.sql_text like 'SELECT count(%)  AS col_1_ FROM ( SELECT % AS col_0_ FROM BSI_CUSTOMER table_0_ %' --WHERE table_0_.CUSTOMER_NR in (SELECT COLUMN_VALUE FROM table(?) t) and table_0_.TYPE_UID IN ( %, %, %, %, %, % ) AND EXISTS ( SELECT % AS rxcol_1_ FROM BSI_MATRIX_PARTITION rxtable_1_ WHERE rxtable_1_.ITEM_TYPE_ID=% AND rxtable_1_.ITEM_KEY0_NR=table_0_.CUSTOMER_NR AND rxtable_1_.PARTITION_UID in (?) ) ) table_1_ fetch next ? rows only'
  --and v.sql_text not like 'SELECT table_0_.BUSINESS_NR AS col_0_, COALESCE(( cast(table_0_.DISPLAY_NAME as varchar2(4000 char)) ), ( '''' )) || '' ('' || COALESCE(( cast(table_0_.BUSINESS_NO %'
  --and lower(v.sql_text) not like lower('SELECT table_0_.BUSINESS_NR AS col_0_, COALESCE(( cast(table_0_.DISPLAY_NAME as varchar2(4000 char)) ), (%')
  --and v.sql_id = '7vbphcz5bsmug'
  --and v.sql_id in ('brst392x8k9ah','grmzx2x79m38a')
  --and lower(v.sql_fulltext) like '%matrix%'
  --and se.status = 'ACTIVE'
  --and v.executions = 0
    and v.LAST_ACTIVE_TIME > TRUNC(sysdate)+16/24+30/24/60
  --and se.sid = 479
  --and v.sql_id in ('da12djdp1fsuf','5j64uhbybrz0r','buwmx1btpvxx8','3pbw3qnumqvbb')
--order   by  v.elapsed_time desc;
order   by  elapsed_time desc 
;

933uccp27s9k1

select * from table(dbms_xplan.display_cursor('cqttxjdg1jxma',0,'typical'));

/*
SQL_ID  cqttxjdg1jxma, child number 0
-------------------------------------
SELECT table_0_.BUSINESS_NR AS col_0_, COALESCE(( 
cast(table_0_.DISPLAY_NAME as varchar2(4000 char)) ), ( '' )) || ' (' 
|| COALESCE(( cast(table_0_.BUSINESS_NO as varchar2(4000 char)) ), ( '' 
)) || ')'  AS col_1_, table_0_.DISPLAY_NAME AS col_2_, 
table_0_.BUSINESS_NO AS col_3_, table_0_.CUSTOMER_NR AS col_4_, 
table_0_.BUSINESS_MANAGER_USER_NR AS 
col_5_,table_0_.BUSINESS_MANAGER_TEAM_UID AS 
col_5__1,table_0_.BUSINESS_MANAGER_TEAM_ROLE_UID AS col_5__2, 
table_0_.STATUS_UID AS col_6_, COALESCE(( 
cast(bsiutl_ucText(table_0_.X_LEAD_SORT_UID, :1 ) as varchar2(4000 
char)) ), ( '' )) || COALESCE(( cast(CASE WHEN ( COALESCE(( 
length(COALESCE(( cast(bsiutl_ucText(table_0_.X_BRANCHE_UID, :2 ) as 
varchar2(4000 char)) ), ( '' )) || COALESCE(( cast(table_2_.CONTRACT_NO 
as varchar2(4000 char)) ), ( '' ))) ), ( 0 )) = 0 ) THEN ( NULL ) ELSE 
( ' (' || COALESCE(( cast(bsiutl_ucText(table_0_.X_BRANCHE_UID, :3 ) as 
varchar2(4000 char)) ), ( '' )) || COALESCE(( cast(CASE WHEN ( 
bsiutl_ucText(table_0_.X_BRAN
 
Plan hash value: 51288782
 
----------------------------------------------------------------------------------------------------------------------
| Id  | Operation                               | Name                       | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                        |                            |       |       |    26 (100)|          |
|*  1 |  VIEW                                   |                            |  4001 |    36M|    26   (4)| 00:00:01 |
|*  2 |   WINDOW NOSORT STOPKEY                 |                            |     1 |  1544 |    26   (4)| 00:00:01 |
|   3 |    VIEW                                 | VM_NWVW_2                  |     1 |  1544 |    26   (4)| 00:00:01 |
|   4 |     HASH UNIQUE                         |                            |     1 |   181 |    26   (4)| 00:00:01 |
|   5 |      NESTED LOOPS OUTER                 |                            |     1 |   181 |    20   (0)| 00:00:01 |
|   6 |       NESTED LOOPS OUTER                |                            |     1 |   174 |    19   (0)| 00:00:01 |
|   7 |        NESTED LOOPS                     |                            |     1 |   156 |    17   (0)| 00:00:01 |
|   8 |         NESTED LOOPS OUTER              |                            |     1 |   143 |    15   (0)| 00:00:01 |
|   9 |          NESTED LOOPS                   |                            |     1 |   136 |    14   (0)| 00:00:01 |
|  10 |           NESTED LOOPS                  |                            |     4 |    60 |     6   (0)| 00:00:01 |
|  11 |            TABLE ACCESS BY INDEX ROWID  | BSI_USER_SUBSTITUTE_FLAT   |     1 |    14 |     2   (0)| 00:00:01 |
|* 12 |             INDEX RANGE SCAN            | BSI_USER_SUBSTITUTE_FLATX1 |     1 |       |     1   (0)| 00:00:01 |
|  13 |            TABLE ACCESS BY INDEX ROWID  | BSI_BUSINESS_ROLE          |     4 |    52 |     4   (0)| 00:00:01 |
|* 14 |             INDEX RANGE SCAN            | BSI_BUSINESS_ROLEX2        |     4 |       |     2   (0)| 00:00:01 |
|* 15 |           TABLE ACCESS BY INDEX ROWID   | BSI_BUSINESS               |     1 |   135 |     2   (0)| 00:00:01 |
|* 16 |            INDEX UNIQUE SCAN            | BSI_BUSINESSXPK            |     1 |       |     1   (0)| 00:00:01 |
|  17 |             NESTED LOOPS                |                            |     1 |    22 |     5   (0)| 00:00:01 |
|  18 |              NESTED LOOPS               |                            |     1 |    22 |     5   (0)| 00:00:01 |
|* 19 |               INDEX RANGE SCAN          | BSI_BUSINESS_ROLEXPK       |     1 |    18 |     3   (0)| 00:00:01 |
|* 20 |               INDEX UNIQUE SCAN         | BSI_CUSTOMERXPK            |     1 |       |     1   (0)| 00:00:01 |
|* 21 |              TABLE ACCESS BY INDEX ROWID| BSI_CUSTOMER               |     1 |    18 |     2   (0)| 00:00:01 |
|  22 |          TABLE ACCESS BY INDEX ROWID    | BSI_UC_CURRENCY            |     1 |    23 |     1   (0)| 00:00:01 |
|* 23 |           INDEX UNIQUE SCAN             | BSI_UC_CURRENCYXPK         |     1 |       |     0   (0)|          |
|* 24 |         INDEX RANGE SCAN                | BSI_CUSTOMERXX5            |     1 |    27 |     2   (0)| 00:00:01 |
|  25 |        TABLE ACCESS BY INDEX ROWID      | BSI_X_CONTRACT             |     1 |    32 |     2   (0)| 00:00:01 |
|* 26 |         INDEX UNIQUE SCAN               | BSI_X_CONTRACTXPK          |     1 |       |     1   (0)| 00:00:01 |
|  27 |       TABLE ACCESS BY INDEX ROWID       | BSI_UC                     |     1 |    21 |     1   (0)| 00:00:01 |
|* 28 |        INDEX UNIQUE SCAN                | BSI_UCXPK                  |     1 |       |     0   (0)|          |
----------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("from$_subquery$_014"."rowlimit_$$_rownumber"<=4001)
   2 - filter(ROW_NUMBER() OVER ( ORDER BY NULL)<=4001)
  12 - access("TABLE_7_"."SUBSTITUTE_USER_NR"=:16352)
  14 - access("TABLE_6_"."CUSTOMER_NR"="TABLE_7_"."USER_NR")
  15 - filter((INTERNAL_FUNCTION("TABLE_0_"."STATUS_UID") AND NVL("TABLE_0_"."PRIVACY_STATUS_UID",0)=0))
  16 - access("TABLE_0_"."BUSINESS_NR"="TABLE_6_"."BUSINESS_NR")
       filter( IS NOT NULL)
  19 - access("TABLE_4_"."BUSINESS_NR"=:B1 AND "TABLE_4_"."ROLE_UID"=2380)
       filter(("TABLE_4_"."ROLE_UID"=2380 AND INTERNAL_FUNCTION("TABLE_4_"."CUSTOMER_NR")))
  20 - access("TABLE_4_"."CUSTOMER_NR"="TABLE_5_"."CUSTOMER_NR")
       filter(("TABLE_5_"."CUSTOMER_NR"=:13 OR "TABLE_5_"."CUSTOMER_NR"=:14 OR "TABLE_5_"."CUSTOMER_NR"=:15 
              OR "TABLE_5_"."CUSTOMER_NR"=:16 OR "TABLE_5_"."CUSTOMER_NR"=:17 OR "TABLE_5_"."CUSTOMER_NR"=:18 OR 
              "TABLE_5_"."CUSTOMER_NR"=:19 OR "TABLE_5_"."CUSTOMER_NR"=:20 OR "TABLE_5_"."CUSTOMER_NR"=:21 OR 
              "TABLE_5_"."CUSTOMER_NR"=:22 OR "TABLE_5_"."CUSTOMER_NR"=:23 OR "TABLE_5_"."CUSTOMER_NR"=:24 OR 
              "TABLE_5_"."CUSTOMER_NR"=:25 OR "TABLE_5_"."CUSTOMER_NR"=:26 OR "TABLE_5_"."CUSTOMER_NR"=:27 OR 
              "TABLE_5_"."CUSTOMER_NR"=:28 OR "TABLE_5_"."CUSTOMER_NR"=:29 OR "TABLE_5_"."CUSTOMER_NR"=:30 OR 
              "TABLE_5_"."CUSTOMER_NR"=:31 OR "TABLE_5_"."CUSTOMER_NR"=:32 OR "TABLE_5_"."CUSTOMER_NR"=:33 OR 
              "TABLE_5_"."CUSTOMER_NR"=:34 OR "TABLE_5_"."CUSTOMER_NR"=:35 OR "TABLE_5_"."CUSTOMER_NR"=:36 OR 
              "TABLE_5_"."CUSTOMER_NR"=:37 OR "TABLE_5_"."CUSTOMER_NR"=:38 OR "TABLE_5_"."CUSTOMER_NR"=:39 OR 
              "TABLE_5_"."CUSTOMER_NR"=:40 OR "TABLE_5_"."CUSTOMER_NR"=:41 OR "TABLE_5_"."CUSTOMER_NR"=:42 OR 
              "TABLE_5_"."CUSTOMER_NR"=:43 OR "TABLE_5_"."CUSTOMER_NR"=:44 OR "TABLE_5_"."CUSTOMER_NR"=:45 OR 
              "TABLE_5_"."CUSTOMER_NR"=:46 OR "TABLE_5_"."CUSTOMER_NR"=:47 OR "TABLE_5_"."CUSTOMER_NR"=:48 OR 
              "TABLE_5_"."CUSTOMER_NR"=:49 OR "TABLE_5_"."CUSTOMER_NR"=:50 OR "TABLE_5_"."CUSTOMER_NR"=:51 OR 
              "TABLE_5_"."CUSTOMER_NR"=:52 OR "TABLE_5_"."CUSTOMER_NR"=:53 OR "TABLE_5_"."CUSTOMER_NR"=:54 OR 
              "TABLE_5_"."CUSTOMER_NR"=:55 OR "TABLE_5_"."CUSTOMER_NR"=:56 OR "TABLE_5_"."CUSTOMER_NR"=:57 OR 
              "TABLE_5_"."CUSTOMER_NR"=:58 OR "TABLE_5_"."CUSTOMER_NR"=:59 OR "TABLE_5_"."CUSTOMER_NR"=:60 OR 
              "TABLE_5_"."CUSTOMER_NR"=:61 OR "TABLE_5_"."CUSTOMER_NR"=:62 OR "TABLE_5_"."CUSTOMER_NR"=:63 OR 
              "TABLE_5_"."CUSTOMER_NR"=:64 OR "TABLE_5_"."CUSTOMER_NR"=:65 OR "TABLE_5_"."CUSTOMER_NR"=:66 OR 
              "TABLE_5_"."CUSTOMER_NR"=:67 OR "TABLE_5_"."CUSTOMER_NR"=:68 OR "TABLE_5_"."CUSTOMER_NR"=:69 OR 
              "TABLE_5_"."CUSTOMER_NR"=:70 OR "TABLE_5_"."CUSTOMER_NR"=:71 OR "TABLE_5_"."CUSTOMER_NR"=:72 OR 
              "TABLE_5_"."CUSTOMER_NR"=:73 OR "TABLE_5_"."CUSTOMER_NR"=:74 OR "TABLE_5_"."CUSTOMER_NR"=:75 OR 
              "TABLE_5_"."CUSTOMER_NR"=:76 OR "TABLE_5_"."CUSTOMER_NR"=:77 OR "TABLE_5_"."CUSTOMER_NR"=:78 OR 
              "TABLE_5_"."CUSTOMER_NR"=:79 OR "TABLE_5_"."CUSTOMER_NR"=:80 OR "TABLE_5_"."CUSTOMER_NR"=:81 OR 
              "TABLE_5_"."CUSTOMER_NR"=:82 OR "TABLE_5_"."CUSTOMER_NR"=:83 OR "TABLE_5_"."CUSTOMER_NR"=:84 OR 
              "TABLE_5_"."CUSTOMER_NR"=:85 OR "TABLE_5_"."CUSTOMER_NR"=:86 OR "TABLE_5_"."CUSTOMER_NR"=:87 OR 
              "TABLE_5_"."CUSTOMER_NR"=:88 OR "TABLE_5_"."CUSTOMER_NR"=:89 OR "TABLE_5_"."CUSTOMER_NR"=:90 OR 
              "TABLE_5_"."CUSTOMER_NR"=:91 OR "TABLE_5_"."CUSTOMER_NR"=:92 OR "TABLE_5_"."CUSTOMER_NR"=:93 OR 
              "TABLE_5_"."CUSTOMER_NR"=:94 OR "TABLE_5_"."CUSTOMER_NR"=:95 OR "TABLE_5_"."CUSTOMER_NR"=:96 OR 
              "TABLE_5_"."CUSTOMER_NR"=:97 OR "TABLE_5_"."CUSTOMER_NR"=:98 OR "TABLE_5_"."CUSTOMER_NR"=:99 OR 
              "TABLE_5_"."CUSTOMER_NR"=:100 OR "TABLE_5_"."CUSTOMER_NR"=:101 OR "TABLE_5_"."CUSTOMER_NR"=:102 OR 
              "TABLE_5_"."CUSTOMER_NR"=:103 OR "TABLE_5_"."CUSTOMER_NR"=:104 OR "TABLE_5_"."CUSTOMER_NR"=:105 OR 
              "TABLE_5_"."CUSTOMER_NR"=:106 OR "TABLE_5_"."CUSTOMER_NR"=:107 OR "TABLE_5_"."CUSTOMER_NR"=:108 OR 
              "TABLE_5_"."CUSTOMER_NR"=:109 OR "TABLE_5_"."CUSTOMER_NR"=:110 OR "TABLE_5_"."CUSTOMER_NR"=:111 OR 
              "TABLE_5_"."CUSTOMER_NR"=:112 OR "TABLE_5_"."CUSTOMER_NR"=:113 OR "TABLE_5_"."CUSTOMER_NR"=:114 OR 
              "TABLE_5_"."CUSTOMER_NR"=:115 OR "TABLE_5_"."CUSTOMER_NR"=:116 OR "TABLE_5_"."CUSTOMER_NR"=:117 OR 
              "TABLE_5_"."CUSTOMER_NR"=:118 OR "TABLE_5_"."CUSTOMER_NR"=:119 OR "TABLE_5_"."CUSTOMER_NR"=:120 OR 
              "TABLE_5_"."CUSTOMER_NR"=:121 OR "TABLE_5_"."CUSTOMER_NR"=:122 OR "TABLE_5_"."CUSTOMER_NR"=:123 OR 
              "TABLE_5_"."CUSTOMER_NR"=:124 OR "TABLE_5_"."CUSTOMER_NR"=:125 OR "TABLE_5_"."CUSTOMER_NR"=:126 OR 
              "TABLE_5_"."CUSTOMER_NR"=:127 OR "TABLE_5_"."CUSTOMER_NR"=:128 OR "TABLE_5_"."CUSTOMER_NR"=:129 OR 
              "TABLE_5_"."CUSTOMER_NR"=:130 OR "TABLE_5_"."CUSTOMER_NR"=:131 OR "TABLE_5_"."CUSTOMER_NR"=:132 OR 
              "TABLE_5_"."CUSTOMER_NR"=:133 OR "TABLE_5_"."CUSTOMER_NR"=:134 OR "TABLE_5_"."CUSTOMER_NR"=:135 OR 
              "TABLE_5_"."CUSTOMER_NR"=:)
  21 - filter(((CASE "TABLE_5_"."X_PARTNER_TYPE_UID" WHEN 124320 THEN 1 WHEN 124335 THEN 1 ELSE 0 END <>1 OR 
              NVL("TABLE_5_"."TYPE_UID",0)=168392) AND NVL("TABLE_5_"."PRIVACY_STATUS_UID",0)=0 AND 
              NVL("TABLE_5_"."TYPE_UID",0)))
  23 - access("TABLE_1_"."CURRENCY_UID"=:12 AND "TABLE_1_"."CURRENCY_DATE"="TABLE_0_"."CURRENCY_DATE")
  24 - access("RXTABLE_1_"."CUSTOMER_NR"="TABLE_0_"."CUSTOMER_NR")
       filter((CASE "RXTABLE_1_"."X_PARTNER_TYPE_UID" WHEN 124320 THEN 1 WHEN 124335 THEN 1 ELSE 0 END <>1 OR 
              "RXTABLE_1_"."TYPE_UID"=168392))
  26 - access("TABLE_0_"."X_CONTRACT_NR"="TABLE_2_"."CONTRACT_NR")
  28 - access("TABLE_0_"."TYPE_UID"="TABLE_3_"."UC_UID")
 
 
*/


execute sys.flush_pool;

select  inst_id,
        sql_id,
        position,
        name,
        value_string 
from    gv$sql_bind_capture 
where   sql_id='dmj62qkpfs20j' 
 --   and inst_id=1 
order   by  position
;

select  bc.name,
        bc.value_anydata
from    v$sql_bind_capture  bc
where   1=1
    and bc.sql_id = 'cskf8w5jxpyb6'
    and bc.child_number = 0
order   by  position;


select  *
from    v$sql_bind_capture  bc
where   1=1
    and bc.sql_id = 'cskf8w5jxpyb6'
order   by  position;

 


declare 
    cursor  c_xplan is
            SELECT  * 
            FROM    table   (
                                DBMS_XPLAN.DISPLAY_CURSOR(
                                    sql_id          => 'gy6tsdspr61zh',
                                    cursor_child_no => 0,
                                    format          => 'ALLSTATS LAST +OUTLINE +HINT_REPORT -ADAPTIVE +PEEKED_BINDS'
                                )
                            );
    r_xplan c_xplan%rowtype;
begin
    open c_xplan;
    loop
        fetch c_xplan into r_xplan;
        exit when c_xplan%notfound;
        dbms_output.put_line(r_xplan.plan_table_output);
    end loop;
end;





/* Formatted on 02/11/2023 07:36:29 (QP5 v5.371) */
select  table_0_.CUSTOMER_NR as col_4_, table_3_.EVT_START as col_5_, table_4_.EVT_START as col_6_
from    bsi.BSI_CUSTOMER  table_0_
        join lateral 
        (
            select  --distinct 
                    table_1_.COMMUNICATION_NR              as col_0_,
                    table_1_.PARTICIPANT_CUSTOMER_NR       as col_1_,
                    table_1_.PARTICIPANT_TEAM_ROLE_UID     as col_2_,
                    table_1_.PARTICIPANT_TEAM_UID          as col_3_
            from    bsi.BSI_COMMUNICATION_PARTICIPANT table_1_
            where       table_0_.CUSTOMER_NR = table_1_.PARTICIPANT_CUSTOMER_NR
                    and exists
                            (select  1     as rxcol_1_
                             from    bsi.BSI_COMMUNICATION rxtable_1_
                             where       table_1_.COMMUNICATION_NR = rxtable_1_.COMMUNICATION_NR
                                     and 1 =
                                         case
                                             when (rxtable_1_.TYPE_UID = 152475)
                                             then
                                                 (1)
                                             when (    1 =
                                                       case
                                                           when ((select  rxtable_3_.OWNER_ORGANIZATION_UNIT_UID    as rxcol_2_
                                                                  from    bsi.BSI_USER rxtable_3_
                                                                  where   rxtable_3_.USER_NR = :1) in
                                                                     (select  case (rxtable_4_.RESPONSIBLE_TYPE_UID)
                                                                                  when (71403)
                                                                                  then
                                                                                      (rxtable_6_.OWNER_ORGANIZATION_UNIT_UID)
                                                                                  else
                                                                                      (rxtable_5_.OWNER_ORGANIZATION_UNIT_UID)
                                                                              end    as rxcol_3_
                                                                      from    bsi.BSI_COMMUNICATION
                                                                              rxtable_4_
                                                                              left outer join
                                                                              bsi.BSI_UC_TEAM
                                                                              rxtable_5_
                                                                                  on rxtable_5_.TEAM_UID =
                                                                                     rxtable_4_.RESPONSIBLE_TEAM_UID
                                                                              left outer join
                                                                              bsi.BSI_USER rxtable_6_
                                                                                  on rxtable_6_.USER_NR =
                                                                                     rxtable_4_.RESPONSIBLE_USER_NR
                                                                      where   rxtable_4_.COMMUNICATION_NR =
                                                                              rxtable_1_.COMMUNICATION_NR))
                                                           then
                                                               (1)
                                                           else
                                                               (case
                                                                    when (exists
                                                                              (select  1    as rxcol_4_
                                                                               from    bsi.BSI_USER_OU_ACL
                                                                                       rxtable_7_
                                                                               where       rxtable_7_.USER_NR =
                                                                                           :2
                                                                                       and rxtable_7_.PERMISSION_NAME =
                                                                                           'crm.ReadCommunication'
                                                                                       and rxtable_7_.ORGANIZATION_UNIT_UID in
                                                                                               (select  case (rxtable_8_.RESPONSIBLE_TYPE_UID)
                                                                                                            when (71403)
                                                                                                            then
                                                                                                                (rxtable_10_.OWNER_ORGANIZATION_UNIT_UID)
                                                                                                            else
                                                                                                                (rxtable_9_.OWNER_ORGANIZATION_UNIT_UID)
                                                                                                        end    as rxcol_5_
                                                                                                from    bsi.BSI_COMMUNICATION
                                                                                                        rxtable_8_
                                                                                                        left outer join
                                                                                                        bsi.BSI_UC_TEAM
                                                                                                        rxtable_9_
                                                                                                            on rxtable_9_.TEAM_UID =
                                                                                                               rxtable_8_.RESPONSIBLE_TEAM_UID
                                                                                                        left outer join
                                                                                                        bsi.BSI_USER
                                                                                                        rxtable_10_
                                                                                                            on rxtable_10_.USER_NR =
                                                                                                               rxtable_8_.RESPONSIBLE_USER_NR
                                                                                                where   rxtable_8_.COMMUNICATION_NR =
                                                                                                        rxtable_1_.COMMUNICATION_NR)))
                                                                    then
                                                                        (1)
                                                                    else
                                                                        (0)
                                                                end)
                                                       end
                                                   and 1 =
                                                       case (rxtable_1_.PRIMARY_CUSTOMER_NR)
                                                           when (0)
                                                           then
                                                               (1)
                                                           else
                                                               (select  1     as rxcol_6_
                                                                from    bsi.BSI_CUSTOMER rxtable_11_
                                                                where       rxtable_11_.CUSTOMER_NR =
                                                                            rxtable_1_.PRIMARY_CUSTOMER_NR
                                                                        and not (    rxtable_11_.TYPE_UID <>
                                                                                     168392
                                                                                 and not (1 = 0)
                                                                                 and 1 =
                                                                                     case (rxtable_11_.X_PARTNER_TYPE_UID)
                                                                                         when (124320)
                                                                                         then
                                                                                             (1)
                                                                                         when (124335)
                                                                                         then
                                                                                             (1)
                                                                                         else
                                                                                             (0)
                                                                                     end))
                                                       end)
                                             then
                                                 (1)
                                             else
                                                 (0)
                                         end
                             union all
                             select  1     as rxcol_1_
                             from    bsi.BSI_DUAL rxtable_2_
                             where   table_1_.COMMUNICATION_NR = 0)) table_2_
            on 1 = 1
        left outer join bsi.BSI_COMMUNICATION table_3_
            on     table_3_.CHANNEL_UID <> 0
               and table_3_.EVT_START >= :3
               and table_3_.EVT_START < :4
               and table_3_.CHANNEL_UID = :5
               and ((table_3_.CHANNEL_UID <> 105316) or (table_3_.TYPE_UID <> 172418))
               and table_2_.col_0_ = table_3_.COMMUNICATION_NR
               and 1 =
                   case
                       when (table_3_.TYPE_UID = 152475)
                       then
                           (1)
                       when (    1 =
                                 case
                                     when ((select  rxtable_1_.OWNER_ORGANIZATION_UNIT_UID    as rxcol_1_
                                            from    bsi.BSI_USER rxtable_1_
                                            where   rxtable_1_.USER_NR = :6) in
                                               (select  case (rxtable_2_.RESPONSIBLE_TYPE_UID)
                                                            when (71403)
                                                            then
                                                                (rxtable_4_.OWNER_ORGANIZATION_UNIT_UID)
                                                            else
                                                                (rxtable_3_.OWNER_ORGANIZATION_UNIT_UID)
                                                        end    as rxcol_2_
                                                from    bsi.BSI_COMMUNICATION  rxtable_2_
                                                        left outer join bsi.BSI_UC_TEAM rxtable_3_
                                                            on rxtable_3_.TEAM_UID =
                                                               rxtable_2_.RESPONSIBLE_TEAM_UID
                                                        left outer join bsi.BSI_USER rxtable_4_
                                                            on rxtable_4_.USER_NR =
                                                               rxtable_2_.RESPONSIBLE_USER_NR
                                                where   rxtable_2_.COMMUNICATION_NR =
                                                        table_3_.COMMUNICATION_NR))
                                     then
                                         (1)
                                     else
                                         (case
                                              when (exists
                                                        (select  1     as rxcol_3_
                                                         from    bsi.BSI_USER_OU_ACL rxtable_5_
                                                         where       rxtable_5_.USER_NR = :7
                                                                 and rxtable_5_.PERMISSION_NAME =
                                                                     'crm.ReadCommunication'
                                                                 and rxtable_5_.ORGANIZATION_UNIT_UID in
                                                                         (select  case (rxtable_6_.RESPONSIBLE_TYPE_UID)
                                                                                      when (71403)
                                                                                      then
                                                                                          (rxtable_8_.OWNER_ORGANIZATION_UNIT_UID)
                                                                                      else
                                                                                          (rxtable_7_.OWNER_ORGANIZATION_UNIT_UID)
                                                                                  end    as rxcol_4_
                                                                          from    bsi.BSI_COMMUNICATION
                                                                                  rxtable_6_
                                                                                  left outer join
                                                                                  bsi.BSI_UC_TEAM
                                                                                  rxtable_7_
                                                                                      on rxtable_7_.TEAM_UID =
                                                                                         rxtable_6_.RESPONSIBLE_TEAM_UID
                                                                                  left outer join
                                                                                  bsi.BSI_USER
                                                                                  rxtable_8_
                                                                                      on rxtable_8_.USER_NR =
                                                                                         rxtable_6_.RESPONSIBLE_USER_NR
                                                                          where   rxtable_6_.COMMUNICATION_NR =
                                                                                  table_3_.COMMUNICATION_NR)))
                                              then
                                                  (1)
                                              else
                                                  (0)
                                          end)
                                 end
                             and 1 =
                                 case (table_3_.PRIMARY_CUSTOMER_NR)
                                     when (0)
                                     then
                                         (1)
                                     else
                                         (select  1     as rxcol_5_
                                          from    bsi.BSI_CUSTOMER rxtable_9_
                                          where       rxtable_9_.CUSTOMER_NR =
                                                      table_3_.PRIMARY_CUSTOMER_NR
                                                  and not (    rxtable_9_.TYPE_UID <> 168392
                                                           and not (1 = 0)
                                                           and 1 =
                                                               case (rxtable_9_.X_PARTNER_TYPE_UID)
                                                                   when (124320) then (1)
                                                                   when (124335) then (1)
                                                                   else (0)
                                                               end))
                                 end)
                       then
                           (1)
                       else
                           (0)
                   end
        left outer join bsi.BSI_COMMUNICATION table_4_
            on     table_4_.CHANNEL_UID = :8
               and table_4_.EVT_START >= :9
               and table_4_.EVT_START < :10
               and ((table_4_.CHANNEL_UID <> 105316) or (table_4_.TYPE_UID <> 172418))
               and table_2_.col_0_ = table_4_.COMMUNICATION_NR
               and 1 =
                   case
                       when (table_4_.TYPE_UID = 152475)
                       then
                           (1)
                       when (    1 =
                                 case
                                     when ((select  rxtable_1_.OWNER_ORGANIZATION_UNIT_UID    as rxcol_1_
                                            from    bsi.BSI_USER rxtable_1_
                                            where   rxtable_1_.USER_NR = :11) in
                                               (select  case (rxtable_2_.RESPONSIBLE_TYPE_UID)
                                                            when (71403)
                                                            then
                                                                (rxtable_4_.OWNER_ORGANIZATION_UNIT_UID)
                                                            else
                                                                (rxtable_3_.OWNER_ORGANIZATION_UNIT_UID)
                                                        end    as rxcol_2_
                                                from    bsi.BSI_COMMUNICATION  rxtable_2_
                                                        left outer join bsi.BSI_UC_TEAM rxtable_3_
                                                            on rxtable_3_.TEAM_UID =
                                                               rxtable_2_.RESPONSIBLE_TEAM_UID
                                                        left outer join bsi.BSI_USER rxtable_4_
                                                            on rxtable_4_.USER_NR =
                                                               rxtable_2_.RESPONSIBLE_USER_NR
                                                where   rxtable_2_.COMMUNICATION_NR =
                                                        table_4_.COMMUNICATION_NR))
                                     then
                                         (1)
                                     else
                                         (case
                                              when (exists
                                                        (select  1     as rxcol_3_
                                                         from    bsi.BSI_USER_OU_ACL rxtable_5_
                                                         where       rxtable_5_.USER_NR = :12
                                                                 and rxtable_5_.PERMISSION_NAME =
                                                                     'crm.ReadCommunication'
                                                                 and rxtable_5_.ORGANIZATION_UNIT_UID in
                                                                         (select  case (rxtable_6_.RESPONSIBLE_TYPE_UID)
                                                                                      when (71403)
                                                                                      then
                                                                                          (rxtable_8_.OWNER_ORGANIZATION_UNIT_UID)
                                                                                      else
                                                                                          (rxtable_7_.OWNER_ORGANIZATION_UNIT_UID)
                                                                                  end    as rxcol_4_
                                                                          from    bsi.BSI_COMMUNICATION
                                                                                  rxtable_6_
                                                                                  left outer join
                                                                                  bsi.BSI_UC_TEAM
                                                                                  rxtable_7_
                                                                                      on rxtable_7_.TEAM_UID =
                                                                                         rxtable_6_.RESPONSIBLE_TEAM_UID
                                                                                  left outer join
                                                                                  bsi.BSI_USER
                                                                                  rxtable_8_
                                                                                      on rxtable_8_.USER_NR =
                                                                                         rxtable_6_.RESPONSIBLE_USER_NR
                                                                          where   rxtable_6_.COMMUNICATION_NR =
                                                                                  table_4_.COMMUNICATION_NR)))
                                              then
                                                  (1)
                                              else
                                                  (0)
                                          end)
                                 end
                             and 1 =
                                 case (table_4_.PRIMARY_CUSTOMER_NR)
                                     when (0)
                                     then
                                         (1)
                                     else
                                         (select  1     as rxcol_5_
                                          from    bsi.BSI_CUSTOMER rxtable_9_
                                          where       rxtable_9_.CUSTOMER_NR =
                                                      table_4_.PRIMARY_CUSTOMER_NR
                                                  and not (    rxtable_9_.TYPE_UID <> 168392
                                                           and not (1 = 0)
                                                           and 1 =
                                                               case (rxtable_9_.X_PARTNER_TYPE_UID)
                                                                   when (124320) then (1)
                                                                   when (124335) then (1)
                                                                   else (0)
                                                               end))
                                 end)
                       then
                           (1)
                       else
                           (0)
                   end
where   1=1
    --and table_0_.CUSTOMER_NR in (select /*+cardinality(t,100)*/ COLUMN_VALUE from    table ( :13) t)
    and exists
        (
            select  1     as col_7_
            from    bsi.BSI_COMMUNICATION table_5_
            where   table_5_.PRIVACY_STATUS_UID = 0
                and ((table_5_.CHANNEL_UID <> 105316) or (table_5_.TYPE_UID <> 172418))
                and table_2_.col_0_ = table_5_.COMMUNICATION_NR
        )
    and table_0_.TYPE_UID in 
        (
            157028,
            161236,
            135826,
            119333,
            168392,
            157029
        )
        and not 
            (
                    table_0_.TYPE_UID <> 168392
                and not (1 = 0)
                and 1 = case (table_0_.X_PARTNER_TYPE_UID)
                            when (124320) then (1)
                            when (124335) then (1)
                            else (0)
                        end
            );



select /*+cardinality(t,100)*/ COLUMN_VALUE from    table (1,2) t
;

select  *
from    v$sql           v
        inner join  dba_sql_plan_baselines  b   on  b.plan_name = v.sql_plan_baseline
                                                and b.signature = v.exact_matching_signature
where   1=1
  --and v.sql_id = 'dtyy2wfbx26sg'
    and v.sql_id in ('brst392x8k9ah','grmzx2x79m38a')
;


select  *
from    dba_sql_plan_baselines
where   1=1
;


select  * 
from    dba_hist_sql_plan 
where   sql_id in ('brst392x8k9ah','grmzx2x79m38a')
    --and id = 0
order   by  sql_id,
            plan_hash_value,
            id
            
            
select  b.sql_id,
        a.begin_interval_time,
        plan_hash_value,
        executions_delta,
        elapsed_time_delta/1000000 elapsed_secs, 
        (elapsed_time_delta/executions_delta)/1000000 elapsed_per_exec_secs
from    dba_hist_snapshot a, dba_hist_sqlstat b
where   a.snap_id=b.snap_id
  --and sql_id='624j2bftfpm1m'
    and sql_id in ('brst392x8k9ah','grmzx2x79m38a')
    and executions_delta > 0 
order   by  b.sql_id,
            a.begin_interval_time
;            

select  v.sql_id,
        v.sql_text,
        v.sql_fulltext,
        v.executions
from    v$sql           v
where   1=1
    and v.sql_text like 'SELECT  DISTINCT table___.USER_NR AS col___, table___.DISPLAY_NAME AS col___, table___.X_IS_DIAMOND AS col___, table___.CUSTOMER_NR AS col___, table___.CUSTOMER_NR AS col___, table___.CUSTOMER_NR AS col___, %'
;            

