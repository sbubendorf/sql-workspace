create table employee 
(
    emp_id          number (4)      constraint emp_pk primary key,
    name            varchar2 (15)   not null, 
    dept_id         number (2)      not null,
    manager_emp_id  number (4)      constraint manager_emp_fk references employee(emp_id),
    salary          number (7,2)    not null,
    hire_date       date            not null, 
    job_id          number (3)
);

begin
    insert into employee        values (7839,'KING'  ,10,null,5000,'17-NOV-81',1); 
      insert into employee      values (7566,'JONES' ,20,7839,2000,'02-APR-81',1); 
        insert into employee    values (7788,'SCOTT' ,20,7566,3000,'19-APR-87',1); 
          insert into employee  values (7876,'ADAMS' ,20,7788,1100,'23-MAY-87',1); 
        insert into employee    values (7902,'FORD'  ,20,7566,3000,'03-DEC-81',1); 
          insert into employee  values (7369,'SMITH' ,20,7902,800 ,'17-DEC-80',1); 
      insert into employee      values (7698,'BLAKE' ,30,7839,2850,'01-MAY-80',1); 
        insert into employee    values (7499,'ALLEN' ,30,7698,1600,'20-FEB-81',1); 
        insert into employee    values (7521,'WARD'  ,30,7698,1250,'22-FEB-81',1); 
        insert into employee    values (7654,'MARTIN',30,7698,1250,'28-SEP-81',1); 
        insert into employee    values (7844,'TURNER',30,7698,1500,'08-SEP-81',1); 
        insert into employee    values (7900,'JAMES' ,30,7698,950 ,'03-DEC-81',1); 
      insert into employee      values (7782,'CLARK' ,10,7839,2450,'09-JUN-81',1); 
        insert into employee    values (7934,'MILLER',10,7782,1300,'23-JAN-82',1);
    commit;
end;        

select  *
from    employee
start   with manager_emp_id is null
connect by  prior emp_id = manager_emp_id;

select  e.*, level
from    employee    e
start   with name = 'JONES'
connect by  prior emp_id = manager_emp_id;

select  e.*, level
from    employee    e
start   with hire_date = (select min(hire_date) from employee)
connect by  prior emp_id = manager_emp_id;


select  max(level)
from    employee    e
connect by  e.manager_emp_id = prior e.emp_id
start   with e.manager_emp_id is null;

select  level, count(*) as num_employees
from    employee    e
connect by  e.manager_emp_id = prior e.emp_id
start   with e.manager_emp_id is null
group   by  level
order   by  level



select  level, 
        lpad('  ', 2 * (level - 1)) || name as emp_name,
        emp_id, 
        manager_emp_id,
        substr(sys_connect_by_path(name, ' / '),4) as path,
        connect_by_isleaf as leaf
from    employee
start   with manager_emp_id is null
connect by prior emp_id = manager_emp_id
order   siblings by name


-- ------ Cycles -------------------------------------

update  employee
set     manager_emp_id = 7654
where   manager_emp_id is null;

select  level, 
        lpad('  ', 2 * (level - 1)) || name as emp_name,
        emp_id, 
        manager_emp_id,
        connect_by_iscycle,
        connect_by_isleaf,
        connect_by_root(emp_id)        
from    employee
start   with emp_id = 7839
connect by  nocycle prior emp_id = manager_emp_id;


