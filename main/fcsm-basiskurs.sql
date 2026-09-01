-- Anmelden mit Login für FCS GUI
select   F2QAPENV.F_SETUSER('MD1SIBU', 'xZTQ48X@W@ZzYftLzcqz') from DUAL;

-- Rücksetzen der Login-Information, bei Bedarf
begin 
   SYS.DBMS_SESSION.reset_package; 
end;
/

select   k.kd_nr,
         k.name_1,
         k.vorname,
         k.kd_lnr,
         k.sprache_cd,
         k.land_lnr_nat
from     f2ldatp0.kdwi_kundenstamm_1    k
where    k.kd_nr = 402641
;

select   k.kd_nr,
         k.name_1,
         k.vorname,
         k.kd_lnr,
         k.sprache_cd,
         k.land_lnr_nat,
--         l.land_name,
         null
from     f2ldatp0.kdwi_kundenstamm_1    k
--         inner join f2ldatp0.AL1LAND    l   on  l.land_lnr = k.LAND_LNR_NAT and l.userbk_nr = k.userbk_nr
where    k.kd_nr = 402641
;



select   *
from     f2lsecp0.kd_stamm    k
where    k.kd_nr = '402641'
;

select   *
from     f2ldatp0.kdwstamm_view;


select   * 
from     SYS.ALL_SYNONYMS
where    SYNONYM_NAME = 'KT_STAMM' 
   and   OWNER like '__LSEC__'
;


select   xxqf_sibu_gugus_1.F_GetUserBank
from     dual;


-- -----------------------------------------------------------------------------
--  Lookup database objects
-- -----------------------------------------------------------------------------
select  ob.object_type, ob.owner, ob.object_name, ob.status,
        to_char(case ob.object_type when 'INDEX' then ix.num_rows when 'TABLE' then tb.num_rows else null end, '999G999G999G999', 'NLS_NUMERIC_CHARACTERS=''.''''')  as  num_rows,
        vw.text                                                 as  source,
        to_char(trunc(ob.created),'yyyy.mm.dd')                 as  created,
        to_char(trunc(ob.last_ddl_time),'yyyy.mm.dd')           as  last_ddl,
        to_char(trunc(tb.last_analyzed),'yyyy.mm.dd')           as  analyzed
from    sys.all_objects         ob
        left  join  sys.all_tables  tb  on  tb.owner = ob.owner and tb.table_name = ob.object_name
        left  join  sys.all_views   vw  on  vw.owner = ob.owner and vw.view_name = ob.object_name
        left  join  sys.all_indexes ix  on  ix.owner = ob.owner and ix.index_name = ob.object_name
where   ob.object_type in ('TABLE','VIEW') -- 'FUNCTION','INDEX','PACKAGE','PACKAGE BODY','PROCEDURE','SEQUENCE','TRIGGER')
    and ob.owner like upper('%')
    and ob.object_name like upper('%userbk')
order   by  ob.object_type,
            ob.owner,
            ob.object_name
;

select  b.USERBK_NR_HOME,
        b.USERBK_NR_BRZ,
        b.USERBK_NR,
        b.FIS_KUERZEL,
        t.BEZ_LANG,
        t.BEZ_MITTEL,
        t.BEZ_KURZ
from    f2ldatp0.sr_userbk              b
        inner join  f2ldatp0.SR_TEXTC   t   ON  t.SR_TEXTC_LNR = b.SR_TEXTC_LNR and t.SPRACHE_CD = 1
where   t.SPRACHE_CD = 1
order   by  b.USERBK_NR_HOME,
            b.USERBK_NR_BRZ,
            b.USERBK_NR
;


-- begin SYS.DBMS_SESSION.reset_package; end; -- Optional, Rücksetzen der Session
declare
   L_Bank      varchar2(300);
   L_Login     varchar2(100);
begin
   SRQLOG00.setup('XXQxyz00=DEBUG'); -- Debug-Level für Package setzen
   L_Login := F2QAPENV.F_SetUser('MD1SIBU', 'xZTQ48X@W@ZzYftLzcqz', 949); -- Login FCS
   SYS.DBMS_OUTPUT.put_line('Login Result:' || L_Login);
   if L_Login='OK' then
      XXQF_SIBU_GUGUS_1.GetUserBank(L_Bank);
      SYS.DBMS_OUTPUT.put_line(L_Bank);
      SRQMESS0.DumpMessages; -- Ausgabe des Message-Stacks
   end if;
exception 
   when others then
      SYS.DBMS_OUTPUT.put_line('Exception:' || sqlerrm); SRQMESS0.DumpMessages;
end;
/



select /* XXSIBU_GUGUS, 
          1 */
          T.SR_TEST_LNR as "SR_TEST_LNR", 
          T.FELD_NUM as "FELD_NUM", 
          T.FELD_NUM_SHORT as "FELD_NUM_SHORT", 
          T.FELD_NUM_MEDIUM as "FELD_NUM_MEDIUM", 
          T.FELD_BETRAG as "FELD_BETRAG", 
          to_char(T.FELD_DT, 
          'YYYY-MM-DD HH24:MI:SS') as "FELD_DT", 
          to_char(T.FELD_DAT, 
          'YYYY-MM-DD HH24:MI:SS') as "FELD_DAT", 
          to_char(T.FELD_TIME, 
          'YYYY-MM-DD HH24:MI:SS') as "FELD_TIME", 
          T.FELD_VC2_SHORT as "FELD_VC2_SHORT", 
          T.FELD_VC2_MEDIUM as "FELD_VC2_MEDIUM", 
          T.FELD_VC2_LONG as "FELD_VC2_LONG", 
          'ver=SR_TEST, 
          '||to_char(T.CREATE_DT, 
          'YYYY-MM-DD HH24:MI:SS')||', 
          '||T.CREATE_ID as "ROW_INFO"
    from  SR_TEST T
   where  T.USERBK_NR=949
   ;



select /* XXSIBU_GUGUS, 
          1 */
          T.SR_TEST_LNR as "SR_TEST_LNR", 
          T.FELD_NUM as "FELD_NUM", 
          T.FELD_NUM_SHORT as "FELD_NUM_SHORT", 
          T.FELD_NUM_MEDIUM as "FELD_NUM_MEDIUM", 
          T.FELD_BETRAG as "FELD_BETRAG", 
          to_char(T.FELD_DT, 
          'YYYY-MM-DD HH24:MI:SS') as "FELD_DT", 
          to_char(T.FELD_DAT, 
          'YYYY-MM-DD HH24:MI:SS') as "FELD_DAT", 
          to_char(T.FELD_TIME, 
          'YYYY-MM-DD HH24:MI:SS') as "FELD_TIME", 
          T.FELD_VC2_SHORT as "FELD_VC2_SHORT", 
          T.FELD_VC2_MEDIUM as "FELD_VC2_MEDIUM", 
          T.FELD_VC2_LONG as "FELD_VC2_LONG", 
          'ver=SR_TEST, 
          '||to_char(T.CREATE_DT, 
          'YYYY-MM-DD HH24:MI:SS')||', 
          '||T.CREATE_ID as "ROW_INFO"
    from  SR_TEST T
   where  FELD_VC2_MEDIUM = 'SIBU'
     and  T.USERBK_NR=949
    ;




select /* XXSIBU_GUGUS_DETAIL, 
          1 */
          T.SR_TEST_DETAIL_LNR as "SR_TEST_DETAIL_LNR", 
          T.SR_TEST_LNR as "SR_TEST_LNR", 
          T.LAND_LNR as "LAND_LNR", 
          T.WRG_LNR as "WRG_LNR", 
          T.TEXT_REC as "TEXT_REC", 
          'ver=SR_TEST_DETAIL, 
          '||to_char(T.CREATE_DT, 
          'YYYY-MM-DD HH24:MI:SS')||', 
          '||T.CREATE_ID as "ROW_INFO"
    from  SR_TEST_DETAIL T
   where  sr_test_lnr in (select sr_test_lnr
    from  sr_test
   where  feld_vc2_medium = 'SIBU')
     and  T.USERBK_NR=949
;


select /* XXSIBU_GUGUS_DETAIL, 
          1 */
          T.SR_TEST_DETAIL_LNR as "SR_TEST_DETAIL_LNR", 
          T.SR_TEST_LNR as "SR_TEST_LNR", 
          T.LAND_LNR as "LAND_LNR", 
          nvl(to_char(T.LAND_LNR), 
          chr(19)) as "LAND_NAME", 
          T.WRG_LNR as "WRG_LNR", 
          T.TEXT_REC as "TEXT_REC", 
          'ver=SR_TEST_DETAIL, 
          '||to_char(T.CREATE_DT, 
          'YYYY-MM-DD HH24:MI:SS')||', 
          '||T.CREATE_ID as "ROW_INFO"
    from  SR_TEST_DETAIL T
   where  sr_test_lnr in (select sr_test_lnr
    from  sr_test
   where  feld_vc2_medium = 'SIBU')
     and  T.USERBK_NR=949
;     


select  xxysibu_gugus_1.f_getrowinfofornewrecord
from    dual;


CREATE OR REPLACE TYPE sibu_test_rec AS OBJECT (
   kdnr             NUMBER(10),
   name             VARCHAR2(100 CHAR),
   birth_date       DATE,
   MEMBER FUNCTION getAge RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY sibu_test_rec AS 
   MEMBER FUNCTION getAge RETURN NUMBER IS
      l_age NUMBER := -1;
   BEGIN
      l_age := TRUNC(MONTHS_BETWEEN(SYSDATE, birth_date) / 12);
      RETURN l_age;
   END;
END;
/

drop table sibu_test_tab;

create table sibu_test_tab (
    id          number(10) not null,
    kd          sibu_test_rec
);

insert into SIBU_TEST_TAB values (1, sibu_test_rec(402641, 'Mustermann', to_date('1980-01-01', 'YYYY-MM-DD')));

insert into SIBU_TEST_TAB values (2, sibu_test_rec(402642, 'Musterfrau', to_date('1990-01-01', 'YYYY-MM-DD')));

commit;

SELECT  p.ID,
        p.kd.kdnr as "KDNR",
        p.kd.name as "NAME",
        p.kd.birth_date as "BIRTH_DATE",
        p.kd.getAge() as "AGE"
FROM    SIBU_TEST_TAB   p
;

update  SIBU_TEST_TAB
set     kd = sibu_test_rec(kd.kdnr, 'Mustergast', to_date('2000-01-01', 'YYYY-MM-DD'))
where   id = 1
;



SELECT  *
FROM    sys.dba_types           t
        inner join  sys.dba_objects o   on  o.object_name = t.type_name and o.owner = t.owner
where   t.type_name like 'XX_SIBU%'
    and o.object_type = 'TYPE'
;