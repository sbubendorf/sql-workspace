drop table t_busi_values;

drop materialized view m_busi_fields;

drop table t_busi_fields;

create table t_busi_fields
(
    id              number,
    type            varchar2(1),
    name            varchar2(50),
    constraint t_busi_fields_pk primary key (id)
);

create materialized view log on t_busi_fields
with primary key, rowid, sequence;
    

insert into t_busi_fields values (1,'T','Name');
insert into t_busi_fields values (2,'T','First Name');
insert into t_busi_fields values (3,'T','Street');
insert into t_busi_fields values (4,'T','Zip');
insert into t_busi_fields values (5,'T','City');

create materialized view m_busi_fields
    nologging
    cache
    build immediate
    refresh fast
    start with sysdate
    next sysdate+(1/24/60/12) 
    with primary key
    as select * from t_busi_fields;
    
create table t_busi_values
(
    object_id       number,
    field_id        number,
    value           varchar2(4000),
    constraint t_busi_values_pk primary key (object_id, field_id),
    constraint fk_field
        foreign key (field_id)
        references m_busi_fields(id)
);

insert into t_busi_values values (1,1,'Bubendorf');
insert into t_busi_values values (1,2,'Simon');
insert into t_busi_values values (1,3,'Drosselstrasse 29');
insert into t_busi_values values (1,4,'4106');
insert into t_busi_values values (1,5,'Therwil');

--insert into t_busi_values values (1,6,'Schweiz');

insert into t_busi_fields values (6,'T','Country');

commit;

select  *
from    m_busi_fields
order   by  id
;


begin
    dbms_mview.refresh('m_busi_fields','f');
end;

select  *
from    dba_jobs;


select  *
from    user_snapshot_logs;



select  *
from    mlog$_co_fields
;


