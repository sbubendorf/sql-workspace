create table depts (
    dept_id   number(2) constraint depts_pk primary key,
    dept_name varchar2(14),
    loc        varchar2(13)
);

insert all
    into depts values (10,'ACCOUNTING','NEW YORK')
    into depts values (20,'RESEARCH','DALLAS')
    into depts values (30,'SALES','CHICAGO')
    into depts values (40,'OPERATIONS','BOSTON')
    select * From dual;
    
commit;    
    
select  *
from    depts
where   1=1
;    


create table emps (
    emp_id      number(4) constraint emps_pk primary key,
    emp_name    varchar2(10),
    job         varchar2(9),
    mgr_id      number(4),
    hiredt      date,
    sal         number(7,2),
    comm        number(7,2),
    dept_id     number(2) constraint emp_dept_id_fk references depts(dept_id)
);


insert all
    into emps values (7369,'SMITH','CLERK',7902,to_date('17-12-1980','dd-mm-yyyy'),800,NULL,20)
    into emps values (7499,'ALLEN','SALESMAN',7698,to_date('20-2-1981','dd-mm-yyyy'),1600,300,30)
    into emps values (7521,'WARD','SALESMAN',7698,to_date('22-2-1981','dd-mm-yyyy'),1250,500,30)
    into emps values (7566,'JONES','MANAGER',7839,to_date('2-4-1981','dd-mm-yyyy'),2975,NULL,20)
    into emps values (7654,'MARTIN','SALESMAN',7698,to_date('28-9-1981','dd-mm-yyyy'),1250,1400,30)
    into emps values (7698,'BLAKE','MANAGER',7839,to_date('1-5-1981','dd-mm-yyyy'),2850,NULL,30)
    into emps values (7782,'CLARK','MANAGER',7839,to_date('9-6-1981','dd-mm-yyyy'),2450,NULL,10)
    into emps values (7788,'SCOTT','ANALYST',7566,to_date('13-JUL-87','dd-mm-rr')-85,3000,NULL,20)
    into emps values (7839,'KING','PRESIDENT',NULL,to_date('17-11-1981','dd-mm-yyyy'),5000,NULL,10)
    into emps values (7844,'TURNER','SALESMAN',7698,to_date('8-9-1981','dd-mm-yyyy'),1500,0,30)
    into emps values (7876,'ADAMS','CLERK',7788,to_date('13-JUL-87', 'dd-mm-rr')-51,1100,NULL,20)
    into emps values (7900,'JAMES','CLERK',7698,to_date('3-12-1981','dd-mm-yyyy'),950,NULL,30)
    into emps values (7902,'FORD','ANALYST',7566,to_date('3-12-1981','dd-mm-yyyy'),3000,NULL,20)
    into emps values (7934,'MILLER','CLERK',7782,to_date('23-1-1982','dd-mm-yyyy'),1300,NULL,10)
    select * From dual;

commit;


select  dept_name, 
        emp_name
from    depts d
        cross join 
        (
            select  emp_name
            from    emps e
            where   e.dept_id = d.dept_id
        )
order   by 1, 2;






