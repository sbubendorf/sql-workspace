select  rtrim(
            xmlagg(
                xmlelement(
                    customer_nr, 
                    cust.customer_nr,
                    ','
                ).extract('//text()')
                order by cust.customer_nr
            ).GetClobVal(),
            ','
        )   as cust_list
from    bsi.bsi_customer                cust
where   1=1
    and cust.type_uid = 168392      -- Interne Person
    and cust.is_active = 1
    and cust.customer_nr > 1000000
;


-- Selektion von Kunden in Blöcken von 1000 Elementen in für IN-Clauses
-- verwendet werden können
select  trunc((rownum - 1) / 1000) as group_nr,
        rtrim(
            xmlagg(
                xmlelement(
                    customer_nr, 
                    cust.customer_nr,
                    ','
                ).extract('//text()')
                order by cust.customer_nr
            ).GetClobVal(),
            ','
        )   as cust_list
from    bsi.bsi_customer                cust
where   1=1
    and cust.type_uid = 168392      -- Interne Person
    and cust.is_active = 1
    and cust.customer_nr > 1000000
group   by  trunc((rownum - 1) / 1000)
order   by  group_nr    
;

