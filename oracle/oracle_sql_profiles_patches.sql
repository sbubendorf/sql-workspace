select  name, 
        sql_text, 
        created, 
        last_modified, 
        status,
        '    dbms_sqldiag.drop_sql_patch(name => ''' || p.name || ''');' as dropper,
        p.*
from    dba_sql_patches p
;

select  'dbms_sqldiag.drop_sql_patch(name => ''' || p.name || ''');' as patch_dropper
from    dba_sql_patches p
;


-- Delete SQL patches --------------------------------------------------------------------------------
begin
    dbms_sqldiag.drop_sql_patch(name => 'Fix_Temp_TS_Jira_DCS-28941');
    dbms_sqldiag.drop_sql_patch(name => 'Alarmkachel_8xx6g13dkc4hx');
    dbms_sqldiag.drop_sql_patch(name => 'Alarmkachel_ab5ztaqzrnrzx');
    dbms_sqldiag.drop_sql_patch(name => 'cqh5tpwk107ma_opt_squ_bu_false');
    dbms_sqldiag.drop_sql_patch(name => 'Alarmkachel_ba8tn5jjht87d');
end;

select  name, 
        sql_text, 
        created, 
        last_modified, 
        status,
        '    dbms_sqltune.alter_sql_profile(name => '''  || name || ''', attribute_name => ''STATUS'', value => ''DISABLED'');' as disabler,
        p.*
from    dba_sql_profiles p
;

select  'dbms_sqltune.alter_sql_profile(name => '''  || name || ''', attribute_name => ''STATUS'', value => ''DISABLED'');' as profile_disabler
from    dba_sql_profiles p
;

-- Disable SQL profiles --------------------------------------------------------------------------------
begin
    dbms_sqltune.alter_sql_profile(name => '5xhusqtb06fxq_opt_squ_bu_false', attribute_name => 'STATUS', value => 'DISABLED');
    dbms_sqltune.alter_sql_profile(name => 'coe_4rfb4rhdpgrk0_478532422', attribute_name => 'STATUS', value => 'DISABLED');
    dbms_sqltune.alter_sql_profile(name => '209rpjba9d8gv_jira_ch2_261', attribute_name => 'STATUS', value => 'DISABLED');
    dbms_sqltune.alter_sql_profile(name => 'coe_8v9rt41vphzva_303009185', attribute_name => 'STATUS', value => 'DISABLED');
    dbms_sqltune.alter_sql_profile(name => 'coe_d9txb4xdwfwvq_630117384', attribute_name => 'STATUS', value => 'DISABLED');
    dbms_sqltune.alter_sql_profile(name => 'coe_2n3hx6m2h4yzv_3117682778', attribute_name => 'STATUS', value => 'DISABLED');
    dbms_sqltune.alter_sql_profile(name => 'coe_02uzqu6mnrt2y_3592887166', attribute_name => 'STATUS', value => 'DISABLED');
    dbms_sqltune.alter_sql_profile(name => '0u3nfm0td4v72_jira_ch2_261', attribute_name => 'STATUS', value => 'DISABLED');
    dbms_sqltune.alter_sql_profile(name => 'coe_4c5tx2dqg5p53_2279113769', attribute_name => 'STATUS', value => 'DISABLED');
    dbms_sqltune.alter_sql_profile(name => 'coe_8rkrsrvhpus4a_4134411207', attribute_name => 'STATUS', value => 'DISABLED');
end;

exec dbms_sqltune.alter_sql_patch 

select  trunc(sample_time), count(*)
from    v$active_session_history
group   by  trunc(sample_time);

select  *
from    v$sqlarea
;

exec dbms_sqldiag.drop_sql_patch(name => 'Fix_Temp_TS_Jira_DCS-28941');

