select  l.db_link,
        l.owner,
        l.username,
        l.host,
        l.created,
        l.valid
from    sys.dba_db_links    l
order   by  l.db_link,
            l.owner
;

select  *
from    sys.all_db_links
where   1=1
;


-- Recreate DB-Link LDWH.BALGROUPIT.COM ----------------------------------------

drop database link LDWH.BALGROUPIT.COM;

create 
    database link   LDWH.BALGROUPIT.COM
    connect to      L001570 
    identified by   "zdksouzo"
    using           'DWHZZ_APP_001P_PRI'
  --using           'DWHZZ_APP_001T_PRI'
  ;


-- Test : L001573 "miduexvk"
-- Int  : L001572 "npxptrxz"
-- Acc  : L001571 "tewomzvq"
-- Prod : L001570 "zdksouzo"

   
select  *
from    dwh_controltable
;

select * from DWHSSOUTT.TBWH_CRMSI_STEUER@LDWH.BALGROUPIT.COM;

select * from DWHPROD.TBWH_CRMSI_STEUER@LDWH.BALGROUPIT.COM;    
    
    
-- Recreate DB-Link ADOS_ODS.BALGROUPIT.COM ------------------------------------
    
drop database link "ADOS_ODS.BALGROUPIT.COM";

create database link "ADOS_ODS.BALGROUPIT.COM"
    connect to      "L004432" 
    identified by   "IXNvzZdu"
  --using           'EBILZ_APP_001A_PRI.balgroupit.com'
  --using           'EBILZ_APP_001I_PRI.BALGROUPIT.COM'
    using           'EBILZ_APP_001T_PRI.BALGROUPIT.COM'
  ;
  
-- Test : L004432 "IXNvzZdu"
-- Int  : L004433 "oBwieefS"
-- Acc  : L004435 "mAJdbpyO"
-- Prod : L004434 "UHyLWXKN"
    
select  *
from    ados_ods.kontakt_historie@ados_ods.balgroupit.com
;

-- Recreate DB-Link EDWH.BALGROUPIT.COM ----------------------------------------
    
drop database link "EDWH.BALGROUPIT.COM";

create database link "EDWH.BALGROUPIT.COM"
    connect to      "L004339" 
    identified by   "r*Tn/zNtX?2qM1ZFKeO"
    using           'EWIZZ_APP_001A_PRI.balgroupit.com';
    
    
-- Test : L004341 "Gv3$y#*|!*W82i:HBM4"
-- Int  : L004340 "Rzy#`Q*CBB?G9^Boj4dE"
-- Acc  : L004339 "r*Tn/zNtX?2qM1ZFKeO"
-- Prod : L004338 "XmmQZbnxS8xj#9%,K!+"
    
select  *
from    edwh_edh_bank_a.crm_lead_trigger@edwh.balgroupit.com
;




-- Drop database link in another schema ----------------------------------------    
declare
    v_cursor    integer;
   -- Define the DROP statement
    v_sql       varchar2(256 char) := 'DROP DATABASE LINK "LDWH.BALGROUPIT.COM"';
    v_user_id   number;
begin
    -- Get user id for owner of the database link
    select user_id into v_user_id from dba_users where username = 'BSIUSER';
    -- Open the cursor and run the SQL
    v_cursor := sys.dbms_sys_sql.open_cursor();
    sys.dbms_sys_sql.parse_as_user(
        c => v_cursor,
        statement => v_sql,
        language_flag => dbms_sql.native,
        userid => v_user_id
    );
end;