declare
    type key_rec_type is record (key varchar(200), val_type varchar(50), counter number);
    type key_map_type is table of key_rec_type index by varchar(200);
    kr key_rec_type;
    km key_map_type;
    l_key varchar(200);
begin
    kr.val_type := 't';   kr.counter := 0; km('a') := kr;
    kr.val_type := 'b';   kr.counter := 0; km('b') := kr;
    kr.val_type := 'n';   kr.counter := 0; km('c') := kr;
    kr.val_type := 'x';   kr.counter := 1; km('x') := kr;
    km('b').counter := 9;
    --
    dbms_output.put_line('--------');
    if km.exists('x') then
        dbms_output.put_line('X existiert!');
    else
        dbms_output.put_line('X existiert nicht!!!!');
    end if;
    --
    l_key := km.first;
    loop
        exit when l_key is null;
        dbms_output.put_line(l_key || ' : ' || km(l_key).val_type || ' - ' || km(l_key).counter);
        l_key := km.next(l_key);
    end loop;
end;


-- Get all keys withing a Json -------------------------------------------------
declare
    jdoc    bsi.bsi_business_hist.data%type;
    jobj    json_object_t;
    keys    json_key_list;
    jarr    json_array_t;
    arrkeys json_key_list;
    elem    json_element_t;
begin
    select  data 
    into    jdoc
    from    bsi.bsi_business_hist
    where   rownum = 1;
    --
    jobj := json_object_t ( jdoc );
    --
    keys := jobj.get_keys;
    --
    for i in 1 .. keys.count loop
        dbms_output.put_line(keys(i));
        if jobj.get(keys(i)).is_array then
            jarr := jobj.get_array(keys(i));
            elem := jarr.get(1);
            arrkeys := treat ( elem as json_object_t ).get_keys;
            for j in 1 .. arrkeys.count loop
                dbms_output.put_line('  ' || arrkeys(j));
            end loop;
        end if;
    end loop;
end;




-- Get all keys withing a Json -------------------------------------------------
declare
    type    key_rec_type is record (key varchar(200), val_type varchar(50), counter number);
    type    key_map_type is table of key_rec_type index by varchar(200);
    kr      key_rec_type;
    km      key_map_type;
    jdoc    bsi.bsi_business_hist.data%type;
    jobj    json_object_t;
    keys    json_key_list;
    l_key   varchar2(200);
begin
    select  data 
    into    jdoc
    from    bsi.bsi_business_hist
    where   business_nr = 2739053091;
    --
    jobj := json_object_t ( jdoc );
    --
    keys := jobj.get_keys;
    --
    for i in 1 .. keys.count loop
        case
            when keys(i) in ('_type','k','t','tsk') then
                -- Ingore these keys
                null;
            when not km.exists(keys(i)) then
                kr.val_type := 't';
                kr.counter := 1;
                km(keys(i)) := kr;
            else 
                km(keys(i)).counter := km(keys(i)).counter + 1;
        end case; 
    end loop;
    -- 
    l_key := km.first;
    loop
        exit when l_key is null;
        dbms_output.put_line(l_key || ' : ' || km(l_key).val_type || ' - ' || km(l_key).counter);
        l_key := km.next(l_key);
    end loop;
end;



/*
{
    "_type":"crm.TimemachineData",
    "0823f5b9-20a0-402e-ac78-dad13a03cd34-evtFollowUp":{"d":"2022-08-22 00:00:00.000"},
    "0b488dd1-bc6f-4f5c-bbcf-4c20cd0d985a-salesManager":{"jpk":"1;112208;133135;j2739053091;j435;n;n;j2444","k":[{"k":"1;112210;318596;j435","t":"g003196 GKey"}],"t":"g003196 GKey"},
    "1a4cf9fd-fbb9-4da6-a9ce-dc2f670d5ff9-businessNo":{"t":"CRM_2739053091"},
    "250fc171-01b7-47ce-b5d6-e87d82e5df06-type":{"k":"1;112192;106064;j164952;j109909","t":{"de":"Offertenanfrage","en":"Offer request","fr":"Demande d'offre","it":"Richiesta d'offerta"}},
    "3666eedf-a874-42fc-b502-c0045ab7aca4-tax":{"n":0E-10},
    "4d70e38e-694d-476f-a949-e6720766c8b1-customer":{"jpk":"1;112208;133135;j2739053091;j1000134510;n;n;j2380","k":[{"k":"1;112210;318596;j1000134510","t":"Etelka Jelmi-Cordier"}],"t":"Etelka Jelmi-Cordier"},
    "7e3be449-fdb9-465b-9ab2-9e68043140e8-globalKey":{"t":"3b0e338e-6ad9-4b8a-b012-d10e8c87a2e4"},
    "a929a79f-08b1-46e0-9952-fe8d90c479af-primePrevious":{"n":4000.0000000000},
    "bc564206-28f3-4fb5-85b7-d8dc198fb7dd-status":{"k":"1;112192;106064;j109984;j71095","t":{"de":"Potential","en":"Potential","fr":"Potentiel","it":"Potenziale"}},
    "c7fb6e83-3fb0-446a-b2d0-14bee60fea53-yearlyTerminationRight":{"b":false},
    "d46e14d0-3966-49bd-a795-70f3adc70930-priceType":{"k":"1;112192;106064;j107824;j107821","t":{"de":"Jährlich","en":"Yearly","fr":"Annuel","it":"Annuale"}},
    "e6535143-db11-4d35-aca6-10aefcde99e8-primeNew":{"n":4500.0000000000},
    "ec336f40-fd9b-4896-a711-c9e01b8e555e-businessType":{"k":"1;112192;106064;j109908;j107813","t":{"de":"Lead","en":"Lead","fr":"Lead","it":"Lead"}},
    "f2e42fff-21ad-482e-a1b1-e9d81362220e-exchangeDate":{"d":"2013-11-21 00:00:00.000"},
    "k":"1;112208;318595;j2739053091","t":"Offertenanfrage","tsk":"1;176169;175620;j2682528022"
}
*/



exec dbms_json.create_view_on_path('bsi_business_hist_data','bsi_business_hist','data','$');

select  json_dataguide(data)
from    bsi.bsi_business_hist   h
where   rownum = 1
;

[
    {
        "o:path":"$",
        "type":"object",
        "o:length":2048
    },
    {
        "o:path":"$.k",
        "type":"string",
        "o:length":32
    },
    {
        "o:path":"$.t",
        "type":"string",
        "o:length":16
    },
    {
        "o:path":"$.tsk",
        "type":"string",
        "o:length":32
    },
    {
        "o:path":"$._type",
        "type":"string",
        "o:length":32
    },
    {
        "o:path":"$.\"3666eedf-a874-42fc-b502-c0045ab7aca4-tax\"",
        "type":"object",
        "o:length":16
    },
    {
        "o:path":"$.\"3666eedf-a874-42fc-b502-c0045ab7aca4-tax\".n",
        "type":"number",
        "o:length":8
    },
    {
        "o:path":"$.\"250fc171-01b7-47ce-b5d6-e87d82e5df06-type\"",
        "type":"object","o:length":256},{"o:path":"$.\"250fc171-01b7-47ce-b5d6-e87d82e5df06-type\".k","type":"string","o:length":32},{"o:path":"$.\"250fc171-01b7-47ce-b5d6-e87d82e5df06-type\".t","type":"object","o:length":128},{"o:path":"$.\"250fc171-01b7-47ce-b5d6-e87d82e5df06-type\".t.de","type":"string","o:length":16},{"o:path":"$.\"250fc171-01b7-47ce-b5d6-e87d82e5df06-type\".t.en","type":"string","o:length":16},{"o:path":"$.\"250fc171-01b7-47ce-b5d6-e87d82e5df06-type\".t.fr","type":"string","o:length":16},{"o:path":"$.\"250fc171-01b7-47ce-b5d6-e87d82e5df06-type\".t.it","type":"string","o:length":32},{"o:path":"$.\"bc564206-28f3-4fb5-85b7-d8dc198fb7dd-status\"","type":"object","o:length":128},{"o:path":"$.\"bc564206-28f3-4fb5-85b7-d8dc198fb7dd-status\".k","type":"string","o:length":32},{"o:path":"$.\"bc564206-28f3-4fb5-85b7-d8dc198fb7dd-status\".t","type":"object","o:length":128},{"o:path":"$.\"bc564206-28f3-4fb5-85b7-d8dc198fb7dd-status\".t.de","type":"string","o:length":16},{"o:path":"$.\"bc564206-28f3-4fb5-85b7-d8dc198fb7dd-status\".t.en","type":"string","o:length":16},{"o:path":"$.\"bc564206-28f3-4fb5-85b7-d8dc198fb7dd-status\".t.fr","type":"string","o:length":16},{"o:path":"$.\"bc564206-28f3-4fb5-85b7-d8dc198fb7dd-status\".t.it","type":"string","o:length":16},{"o:path":"$.\"4d70e38e-694d-476f-a949-e6720766c8b1-customer\"","type":"object","o:length":256},{"o:path":"$.\"4d70e38e-694d-476f-a949-e6720766c8b1-customer\".k","type":"array","o:length":64},{"o:path":"$.\"4d70e38e-694d-476f-a949-e6720766c8b1-customer\".k.k","type":"string","o:length":32},{"o:path":"$.\"4d70e38e-694d-476f-a949-e6720766c8b1-customer\".k.t","type":"string","o:length":32},{"o:path":"$.\"4d70e38e-694d-476f-a949-e6720766c8b1-customer\".t","type":"string","o:length":32},{"o:path":"$.\"4d70e38e-694d-476f-a949-e6720766c8b1-customer\".jpk","type":"string","o:length":64},{"o:path":"$.\"e6535143-db11-4d35-aca6-10aefcde99e8-primeNew\"","type":"object","o:length":32},{"o:path":"$.\"e6535143-db11-4d35-aca6-10aefcde99e8-primeNew\".n","type":"number","o:length":16},{"o:path":"$.\"7e3be449-fdb9-465b-9ab2-9e68043140e8-globalKey\"","type":"object","o:length":64},{"o:path":"$.\"7e3be449-fdb9-465b-9ab2-9e68043140e8-globalKey\".t","type":"string","o:length":64},{"o:path":"$.\"d46e14d0-3966-49bd-a795-70f3adc70930-priceType\"","type":"object","o:length":128},{"o:path":"$.\"d46e14d0-3966-49bd-a795-70f3adc70930-priceType\".k","type":"string","o:length":32},{"o:path":"$.\"d46e14d0-3966-49bd-a795-70f3adc70930-priceType\".t","type":"object","o:length":64},{"o:path":"$.\"d46e14d0-3966-49bd-a795-70f3adc70930-priceType\".t.de","type":"string","o:length":16},{"o:path":"$.\"d46e14d0-3966-49bd-a795-70f3adc70930-priceType\".t.en","type":"string","o:length":8},{"o:path":"$.\"d46e14d0-3966-49bd-a795-70f3adc70930-priceType\".t.fr","type":"string","o:length":8},{"o:path":"$.\"d46e14d0-3966-49bd-a795-70f3adc70930-priceType\".t.it","type":"string","o:length":8},{"o:path":"$.\"1a4cf9fd-fbb9-4da6-a9ce-dc2f670d5ff9-businessNo\"","type":"object","o:length":32},{"o:path":"$.\"1a4cf9fd-fbb9-4da6-a9ce-dc2f670d5ff9-businessNo\".t","type":"string","o:length":16},{"o:path":"$.\"0823f5b9-20a0-402e-ac78-dad13a03cd34-evtFollowUp\"","type":"object","o:length":32},{"o:path":"$.\"0823f5b9-20a0-402e-ac78-dad13a03cd34-evtFollowUp\".d","type":"string","o:length":32},{"o:path":"$.\"0b488dd1-bc6f-4f5c-bbcf-4c20cd0d985a-salesManager\"","type":"object","o:length":128},{"o:path":"$.\"0b488dd1-bc6f-4f5c-bbcf-4c20cd0d985a-salesManager\".k","type":"array","o:length":64},{"o:path":"$.\"0b488dd1-bc6f-4f5c-bbcf-4c20cd0d985a-salesManager\".k.k","type":"string","o:length":32},{"o:path":"$.\"0b488dd1-bc6f-4f5c-bbcf-4c20cd0d985a-salesManager\".k.t","type":"string","o:length":16},{"o:path":"$.\"0b488dd1-bc6f-4f5c-bbcf-4c20cd0d985a-salesManager\".t","type":"string","o:length":16},{"o:path":"$.\"0b488dd1-bc6f-4f5c-bbcf-4c20cd0d985a-salesManager\".jpk","type":"string","o:length":64},{"o:path":"$.\"ec336f40-fd9b-4896-a711-c9e01b8e555e-businessType\"","type":"object","o:length":128},{"o:path":"$.\"ec336f40-fd9b-4896-a711-c9e01b8e555e-businessType\".k","type":"string","o:length":32},{"o:path":"$.\"ec336f40-fd9b-4896-a711-c9e01b8e555e-businessType\".t","type":"object","o:length":64},{"o:path":"$.\"ec336f40-fd9b-4896-a711-c9e01b8e555e-businessType\".t.de","type":"string","o:length":4},{"o:path":"$.\"ec336f40-fd9b-4896-a711-c9e01b8e555e-businessType\".t.en","type":"string","o:length":4},{"o:path":"$.\"ec336f40-fd9b-4896-a711-c9e01b8e555e-businessType\".t.fr","type":"string","o:length":4},{"o:path":"$.\"ec336f40-fd9b-4896-a711-c9e01b8e555e-businessType\".t.it","type":"string","o:length":4},{"o:path":"$.\"f2e42fff-21ad-482e-a1b1-e9d81362220e-exchangeDate\"","type":"object","o:length":32},{"o:path":"$.\"f2e42fff-21ad-482e-a1b1-e9d81362220e-exchangeDate\".d","type":"string","o:length":32},{"o:path":"$.\"a929a79f-08b1-46e0-9952-fe8d90c479af-primePrevious\"","type":"object","o:length":32},{"o:path":"$.\"a929a79f-08b1-46e0-9952-fe8d90c479af-primePrevious\".n","type":"number","o:length":16},{"o:path":"$.\"c7fb6e83-3fb0-446a-b2d0-14bee60fea53-yearlyTerminationRight\"","type":"object","o:length":16},{"o:path":"$.\"c7fb6e83-3fb0-446a-b2d0-14bee60fea53-yearlyTerminationRight\".b","type":"boolean","o:length":8}]


/*

JSONPath Online Evaluator: 
    http://jsonpath.com/
    https://www.jsonquerytool.com/

Time machine handlers BSI CRM: https://git.bsiag.com/basler/bsicrm/-/blob/release-branches/COMET_25.1/ch.basler.bsicrm.migration.app.server.headless/timemachineHandlers.json

JSONPath to get all fields of a specific History table:
    $.handlers[?(@.m_mappings.m_bsiHistClass=="com.bsiag.crm.server.core.business.benefit.BsiBenefitHist")].m_mappings.m_columnMappings[*].m_uuid
                                               |                                                       |
                                               +------- Replace with specific table class name --------+
[
  "3dcaf06c-8ea3-4794-893f-b50884c4a313-benefitNo",
  "0042ea95-acb1-43fb-b885-86b9bb322e3d-business",
  "c178e652-3769-4590-8470-a327fb0223a3-evtBenefitDate",
  "deaf91c8-7c3c-4497-bbe6-77c76fe09c56-status",
  "59513342-aea0-4638-b9da-afeba43c5588-notes",
  "4a7a941d-7b1f-4421-9b8e-1e45f1cd1f40-privacyStatus",
  "abc3d024-3b5b-4dd7-a9aa-f35b763b99ca-incidentDate",
  "5bf7f2a5-7e6b-4053-a514-dd358ffb5964-currency",
  "94ec3589-2e1f-4f77-bf3f-1fe0171eb594-contract",
  "f1980654-e4fd-4102-bff4-380a6d5436ed-benefitSort",
  "46c9a418-4015-47de-b476-e1b92f8e2532-benefitCoverage",
  "12b25ae1-1582-43e3-8954-0c3127739b6c-benefitType",
  "b54fffa0-0428-4ee7-aaa5-4b7cadad7fd4-benefitReason",
  "67aba1ef-041e-4569-bc30-8edb8712a7c8-subBranch",
  "03e4e2cb-8746-4237-9bc9-cadb41f6eca8-bagatelle",
  "3a95da90-3375-4878-8715-b1060937c00d-creationDate",
  "1679793d-65f5-49f8-b272-5f5c252b2ba0-finishDate",
  "01432782-f377-4b15-9ea2-c76f3b9c988c-payment"
] 





com.bsiag.crm.server.core.business.benefit.BsiBenefitHist 
com.bsiag.crm.server.core.business.BsiBusinessHist 
com.bsiag.crm.server.core.communication.BsiCommunicationHist
ch.basler.bsicrm.server.contract.BsiXContractCustomerHist
[
  "029a5837-829f-4317-83a3-f3f1a3a18072-role",
  "e03efc9d-80ac-4319-84a9-9b9a2edcddf1-customer"
]
*/

select  h.hist_nr,
        h.change_item_type_id,
        h.change_item_key0_nr,
        h.evt_change,
        h.data,
        h.customer_nr,
        h.contract_nr,
        h.role_uid,
        json_value(h.data, '$."029a5837-829f-4317-83a3-f3f1a3a18072-role".k')   as  hist_role_uid,
        json_value(h.data, '$."e03efc9d-80ac-4319-84a9-9b9a2edcddf1-customer".k')   as  hist_customer_nr,
        json_value(h.data, '$.k')   as  k,
        json_value(h.data, '$.t')   as  t,
        json_value(h.data, '$.tsk') as  tsk
from    bsi_x_contract_customer_hist    h
;


/*
ch.basler.bsicrm.server.contract.BsiXContractHist
[
  "fb9e1829-d305-4a7d-8a91-d409d01b7200-contractNo",
  "95cc13e0-3e2c-4720-8b0f-141f7d9a5a93-advisor",
  "633a11c1-600a-4566-863d-541baca649cf-businessType",
  "8731d5b9-be0a-49a6-b795-738b0984b041-product",
  "75e5f4ed-1ed7-4fa6-9312-3caddc7b1308-rate",
  "00ff8669-24e3-4893-82d5-bf8e62158194-currency",
  "4136bff9-6d17-4f1a-af82-44112d1ab053-status",
  "c693930e-9d4e-412b-87fa-7f011b282549-cancelledOn",
  "c6f7093f-8262-4738-a3a1-3a853f7850ff-beginningDate",
  "a501502a-3af9-4ee1-8695-408d4be53bc2-expirationDate",
  "c5cf81c6-930e-41b0-baa7-6fbff4a937c4-carBrand",
  "53b2cff6-dfc2-4b68-8c10-502feaee66a5-registrationNo",
  "dba52d13-146c-4b1b-a5ae-9a6ad0732098-licensePlate",
  "6b9fa11b-6394-4aab-ba6b-f2de4a433a68-transferablePlate",
  "bbd51fa2-6b34-4111-95b9-1f4000c91299-foresight",
  "d59ed6df-ea92-402d-912f-c2ff3a4da5a8-buildingLocation",
  "1b283d63-e3a7-460e-8c2f-1f5c1674eef2-rateSum",
  "4c1ba067-45ff-4fad-8fb4-0e6ee4ab5ed1-benefitSum",
  "cff8ad14-0b6c-474d-9626-44a8bb1037a9-restructuringCode",
  "e6080216-7479-472d-b178-dccba49cd72e-dunningStatus",
  "32b1b414-9a59-4b10-88e3-30e909291ed6-dunningLevelSince",
  "7b5e73cd-4ec3-4929-aeb5-2411aa2d46c7-suspensionOfCover",
  "077891d3-9187-4d0e-bf3b-43664a1b2cad-overdueAmount",
  "509c3ee9-4903-4b29-b533-781f8fdfd813-dunningStop",
  "ed9f7901-302b-45b5-8e1d-b57e9114cc5c-leasingEnd",
  "643e91e8-7baf-4a07-a107-c16d96a71344-leasing",
  "37e250ba-37aa-4535-880d-6aa69206a739-younGo",
  "3be553e7-ccab-48b4-8f38-ca6207cf904e-atRiskRelevant",
  "ff678bd2-fe84-4cb2-8f57-c14257c901f4-externalPolicyNo",
  "52e40f6c-1084-4723-9c22-6510b13bd44e-licensePlateStatus",
  "a3366bd9-df51-46b0-872e-1c5429a96650-garageRisk",
  "c5894379-361e-4a30-b2bd-36a4df706426-atRisk"
]

*/

select  h.hist_nr,
        h.evt_change,
        h.data,
        h.contract_nr,
        json_value(h.data, '$."fb9e1829-d305-4a7d-8a91-d409d01b7200-contractNo".t')             as  contract_no,
        json_value(h.data, '$."95cc13e0-3e2c-4720-8b0f-141f7d9a5a93-advisor".k')                as  advisor_nr,
        json_value(h.data, '$."95cc13e0-3e2c-4720-8b0f-141f7d9a5a93-advisor".t.de')             as  advisor_name,
        json_value(h.data, '$."633a11c1-600a-4566-863d-541baca649cf-businessType".k')           as  business_type_uid,
        json_value(h.data, '$."633a11c1-600a-4566-863d-541baca649cf-businessType".t.de')        as  business_type_name,
        json_value(h.data, '$."8731d5b9-be0a-49a6-b795-738b0984b041-product".k')                as  product_uid,
        json_value(h.data, '$."8731d5b9-be0a-49a6-b795-738b0984b041-product".t.de')             as  product_name,
        json_value(h.data, '$."75e5f4ed-1ed7-4fa6-9312-3caddc7b1308-rate".n')                   as  rate,
        json_value(h.data, '$."00ff8669-24e3-4893-82d5-bf8e62158194-currency".k')               as  currency_id,
        json_value(h.data, '$."00ff8669-24e3-4893-82d5-bf8e62158194-currency".t.de')            as  currency_name,
        json_value(h.data, '$."4136bff9-6d17-4f1a-af82-44112d1ab053-status".k')                 as  status_uid,
        json_value(h.data, '$."4136bff9-6d17-4f1a-af82-44112d1ab053-status".t.de')              as  status_name,
        json_value(h.data, '$."c693930e-9d4e-412b-87fa-7f011b282549-cancelledOn".d')            as  cancelled_on,
        json_value(h.data, '$."c6f7093f-8262-4738-a3a1-3a853f7850ff-beginningDate".d')          as  beginning_date,
        json_value(h.data, '$."a501502a-3af9-4ee1-8695-408d4be53bc2-expirationDate".d')         as  expiration_date,
        json_value(h.data, '$."c5cf81c6-930e-41b0-baa7-6fbff4a937c4-carBrand".t')               as  car_brand,
        json_value(h.data, '$."53b2cff6-dfc2-4b68-8c10-502feaee66a5-registrationNo".t')         as  registraction_no,  
        json_value(h.data, '$."dba52d13-146c-4b1b-a5ae-9a6ad0732098-licensePlate".t')           as  license_plate,
        json_value(h.data, '$."6b9fa11b-6394-4aab-ba6b-f2de4a433a68-transferablePlate".b')      as  transferable_plate,
        json_value(h.data, '$."bbd51fa2-6b34-4111-95b9-1f4000c91299-foresight".b')              as  foresight,
        json_value(h.data, '$."d59ed6df-ea92-402d-912f-c2ff3a4da5a8-buildingLocation".t')       as  building_location,
        json_value(h.data, '$."1b283d63-e3a7-460e-8c2f-1f5c1674eef2-rateSum".n')                as  rate_sum,
        json_value(h.data, '$."4c1ba067-45ff-4fad-8fb4-0e6ee4ab5ed1-benefitSum".n')             as  benefit_sum,
        json_value(h.data, '$."cff8ad14-0b6c-474d-9626-44a8bb1037a9-restructuringCode".k')      as  restructuring_uid,
        json_value(h.data, '$."cff8ad14-0b6c-474d-9626-44a8bb1037a9-restructuringCode".t.de')   as  restructuring_name,
        json_value(h.data, '$."e6080216-7479-472d-b178-dccba49cd72e-dunningStatus".k')          as  dunning_status_uid,
        json_value(h.data, '$."e6080216-7479-472d-b178-dccba49cd72e-dunningStatus".t.de')       as  dunning_status_name,
        json_value(h.data, '$."32b1b414-9a59-4b10-88e3-30e909291ed6-dunningLevelSince".d')      as  dunning_level_since,
        json_value(h.data, '$."7b5e73cd-4ec3-4929-aeb5-2411aa2d46c7-suspensionOfCover".d')      as  suspension_of_cover,
        json_value(h.data, '$."077891d3-9187-4d0e-bf3b-43664a1b2cad-overdueAmount".n')          as  overdue_amount,
        json_value(h.data, '$."509c3ee9-4903-4b29-b533-781f8fdfd813-dunningStop".d')            as  dunning_stop,
        json_value(h.data, '$."ed9f7901-302b-45b5-8e1d-b57e9114cc5c-leasingEnd".d')             as  leasing_end,
        json_value(h.data, '$."643e91e8-7baf-4a07-a107-c16d96a71344-leasing".b')                as  leasing,
        json_value(h.data, '$."37e250ba-37aa-4535-880d-6aa69206a739-younGo".b')                 as  young_go,
        json_value(h.data, '$."3be553e7-ccab-48b4-8f38-ca6207cf904e-atRiskRelevant".b')         as  at_risk_relevant,
        json_value(h.data, '$."ff678bd2-fe84-4cb2-8f57-c14257c901f4-externalPolicyNo".t')       as  external_policy_no,
        json_value(h.data, '$."52e40f6c-1084-4723-9c22-6510b13bd44e-licensePlateStatus".k')     as  license_plate_status_uid,
        json_value(h.data, '$."52e40f6c-1084-4723-9c22-6510b13bd44e-licensePlateStatus".t.de')  as  license_plate_status_name,
        json_value(h.data, '$."a3366bd9-df51-46b0-872e-1c5429a96650-garageRisk".k')             as  garage_risk_uid,
        json_value(h.data, '$."a3366bd9-df51-46b0-872e-1c5429a96650-garageRisk".t.de')          as  garage_risk_name,
        json_value(h.data, '$."c5894379-361e-4a30-b2bd-36a4df706426-atRisk".k')                 as  at_risk_uid,
        json_value(h.data, '$."c5894379-361e-4a30-b2bd-36a4df706426-atRisk".t.de')              as  at_risk_name,
        json_value(h.data, '$.k')   as  k,
        json_value(h.data, '$.t')   as  t,
        json_value(h.data, '$.tsk') as  tsk
from    bsi_x_contract_hist    h
;

/*
com.bsiag.crm.server.core.customer.BsiCustomerHist
[
  "0a450fce-3135-440e-b4c3-44b7238d9815-globalKey",
  "08d68be5-318c-4964-a8f0-709d951130cb-name1",
  "d4fe4f86-6faa-4e5a-bc91-1e143a7fb8e5-name2",
  "6290fb03-61d4-4b0f-8333-542417769335-name3",
  "e7c86511-6d1e-42a2-8820-5d7a00b571ad-shortName",
  "9aa01169-efbe-4bfb-aa1e-0ff8a77ca999-customerNo",
  "f0ca768f-153c-4d5c-bb4a-1ea7a2d27988-genderUid",
  "9997af35-a65b-4ac2-bde5-2d797df6837e-title",
  "56799706-9bb1-4df2-82b7-9cad590231ed-useTitleInAddress",
  "c049bf00-9edf-4d33-840d-f7878fafee3f-evtBirth",
  "6320e8c3-f3c3-4c17-b7c0-d2430160130f-typeUid",
  "73b89ca6-d716-45a4-98f4-cdc38ab4162f-image",
  "329af230-3179-4964-bfa2-1d40fa915e4e-useLetterSalutationLineOverride",
  "3547a416-5fbe-45ca-9aaa-7aa0ea40e9dd-letterSalutationLineOverride",
  "0f952bc0-dee1-44df-af49-9b18a557bd05-languageUid",
  "467a26dd-42e0-43b7-ae3e-e3c20817209e-active",
  "63029141-806e-4974-b07e-3496785e3d40-ratingUid",
  "6c51c921-b353-4b7f-8bf0-027bd92e880e-notes",
  "c94c08a2-7be3-485f-950f-20baf9a487f4-privacyStatus",
  "f003eb92-6419-467b-9174-837d5614a5f4-lastMergeInfo",
  "d8cee60f-98a0-435e-8632-1a3709ddec47-advertisingBlock",
  "03b9a7fe-f3da-4ac5-bf6f-bf2290d75e8c-advertisingBlockByCustomer",
  "e6b77a86-9298-4053-a0c0-43a1296a3445-advertisingBlockReason",
  "595dd6f1-b2c8-4c29-8a0d-f3a9ddf48421-advertisingBlockCommunication",
  "0705fee0-d6ab-48ab-80e7-4691788d293d-preferredChannel",
  "c4c356ce-6c9d-4056-916b-bd6429d9f4b1-residencePermit",
  "8bb1c57e-fbe0-444e-a113-1c7db710d893-citizenship",
  "db736db5-dc50-447f-8e56-8207d9a25744-employmentStatus",
  "657dcc83-acc7-4834-9a47-b217a4b148f7-dateDeath",
  "002c81e5-19a5-47e3-aed0-8883fd54adbc-diamond",
  "d7bc55c8-26be-4948-828a-fde973db17d8-sobaCustomer",
  "07ac4848-8f26-489b-bd6a-d3309a638dd5-mortgageAtBasler",
  "afa8565a-74d7-4e13-996d-f5710c7f9aaf-myBaloise",
  "0f412b3e-a45b-4745-98f9-3cdb0c62c369-baloisePlusStatus",
  "5de9246d-17f8-4c81-a4be-d3743b9c54a5-tcsNo",
  "b02af55e-35bc-4a82-ad8e-27cd786d59ac-ahvNo",
  "c2130d28-4f0d-497b-b661-b9fd89c95bcc-vnaStopp",
  "ae03a198-475c-4270-82d2-64e5c6659b5c-partnerType",
  "b5261b66-a768-4ce0-a0ca-246ce8912971-advisorRythm",
  "ce705895-1557-4545-ae02-0c36b5ed4879-advisorRythmOverride",
  "716737c4-4f6a-4d60-b8bd-dda2f23e2d7b-prospectDataExpiry",
  "3232fc08-7d7d-4fd4-b0d8-59110882ae3d-prospectSource",
  "154a14ab-2e1c-4ef3-9abc-c0419d5c0632-prospectSourceDetail",
  "8a13fe98-32b0-4397-95e5-446b5ae1aadc-optIn",
  "1a16533c-02ee-445c-a796-a836ccb61111-additionalText",
  "fd764f36-eb82-441b-89d8-d7f47e9f418c-internalAddress",
  "f5435f85-e078-46bc-a2d3-97392762cd0f-fidlegDeclaration",
  "14992e8c-14dd-429d-a858-54a0531c463c-legalForm",
  "9d3bd9af-b235-46f7-b12c-115830edad96-salesTaxId",
  "2dbf354d-82ff-4dd4-b180-40082d94965b-dateFoundation",
  "b4592218-46f2-4af5-98e7-6c8668c243b0-dateLiquidation",
  "4b93d8d3-da26-4006-b22a-781b012e4987-estimatedTurnover",
  "75470f04-0100-428b-8b2a-eb402dbc2a2a-numEmployees",
  "bc3457d8-5220-4f74-be19-6fb6366793e5-region",
  "c2441fc3-0ac5-4e6a-a720-198e36d1d0fc-sector",
  "6a4c19df-9105-422f-81bd-8060f6c8fb15-noga"
]
com.bsiag.crm.server.core.marketing.campaign.BsiCampaignHist
com.bsiag.crm.server.core.process.BsiUcProcessHist
com.bsiag.crm.server.core.task.BsiTaskHist
com.bsiag.crm.server.core.user.BsiUserHist
com.bsiag.crm.server.core.address.BsiAddressHist
com.bsiag.crm.server.core.bankconnection.BsiBankConnectionHist
com.bsiag.crm.server.core.business.insuredobject.BsiInsuredObjectHist
com.bsiag.crm.server.core.business.insuredobject.elementaryproduct.BsiElementaryProductHist
com.bsiag.crm.server.core.business.payment.BsiPaymentPositionHist
com.bsiag.crm.server.core.business.payment.BsiPaymentHist
com.bsiag.crm.server.core.chat.BsiChatConversationParticipantHist
com.bsiag.crm.server.core.chat.BsiChatConversationHist
com.bsiag.crm.server.core.chat.BsiChatMessageHist
com.bsiag.crm.server.core.common.monitoring.BsiJobHist
com.bsiag.crm.server.core.common.seriespattern.BsiSeriesPatternHist
com.bsiag.crm.server.core.common.sharing.BsiSharingHist
com.bsiag.crm.server.core.communication.BsiCommunicationReactionHist
com.bsiag.crm.server.core.common.duplicate.BsiDuplicateCustomerFilterHist
com.bsiag.crm.server.core.configuration.code.BsiFormRuleHist
com.bsiag.crm.server.core.address.BsiUcAddressUsageHist
com.bsiag.crm.server.core.advisor.BsiUcAdvisorHist
com.bsiag.crm.server.core.configuration.code.BsiUcAttributeHist
com.bsiag.crm.server.core.business.BsiUcBusinessRoleHist
com.bsiag.crm.server.core.business.BsiUcBusinessHist
com.bsiag.crm.server.core.configuration.code.BsiUcCommercialHist
com.bsiag.crm.server.core.configuration.code.BsiUcCountryHist
com.bsiag.crm.server.core.configuration.code.BsiUcCurrencyHist
com.bsiag.crm.server.core.configuration.code.BsiUcCustomColumnHist
com.bsiag.crm.server.core.configuration.code.BsiUcCustomTableHist
com.bsiag.crm.server.core.customer.businesscard.BsiUcCustomerBusinessCardTemplateHist
com.bsiag.crm.server.core.customer.gender.BsiUcCustomerGenderHist
com.bsiag.crm.server.core.customer.role.BsiUcCustomerRoleHist
com.bsiag.crm.server.core.customer.targets.BsiUcCustomerSegmentationHist
com.bsiag.crm.server.core.customer.code.BsiUcCustomerTableHist
com.bsiag.crm.server.core.customer.code.BsiUcCustomerHist
com.bsiag.crm.server.core.user.BsiUcDefaultMatrixPartitionHist
com.bsiag.crm.server.core.common.duplicate.BsiUcDuplicateCustomerQueryHist
com.bsiag.crm.server.core.common.duplicate.BsiUcDuplicateCustomerTypeHist
com.bsiag.crm.server.core.dwh.BsiUcDwhIndexHist
com.bsiag.crm.server.core.dwh.report.BsiUcDwhReportCustomerHist
com.bsiag.crm.server.core.dwh.report.BsiUcDwhReportDisplayHist
com.bsiag.crm.server.core.dwh.report.BsiUcDwhReportOrganizationUnitHist
com.bsiag.crm.server.core.dwh.report.BsiUcDwhReportTeamHist
com.bsiag.crm.server.core.dwh.report.BsiUcDwhReportTimeRangeHist
com.bsiag.crm.server.core.dwh.report.BsiUcDwhReportHist
com.bsiag.crm.server.core.dwh.report.BsiUcDwhReportUserHist
com.bsiag.crm.server.core.emailimport.BsiUcEmailRuleHist
com.bsiag.crm.server.core.common.BsiUcEntityTypeHist
com.bsiag.crm.server.core.marketing.exportfilter.BsiUcExportdefinitionHist
com.bsiag.crm.server.core.configuration.code.BsiUcLanguageHist
com.bsiag.crm.server.core.communication.code.BsiUcMessageChannelHist
com.bsiag.crm.server.core.oauth.BsiUcOAuthAccountHist
com.bsiag.crm.server.core.ruleengine.operation.BsiUcOperationHist
com.bsiag.crm.server.core.process.BsiUcOutboundPhoneResultHist
com.bsiag.crm.server.core.configuration.privacy.rule.BsiUcPrivacyRuleHist
com.bsiag.crm.server.core.process.BsiUcProcessInfoHist
com.bsiag.crm.server.core.process.priority.BsiUcProcessPrioritizationHist
com.bsiag.crm.server.core.business.product.BsiUcProductLanguageHist
com.bsiag.crm.server.core.business.BsiUcProductHist
com.bsiag.crm.server.core.employee.activity.BsiUcProjectActivityHist
com.bsiag.crm.server.core.communication.BsiUcReactionHist
com.bsiag.crm.server.core.ruleengine.rule.BsiUcRuleHist
com.bsiag.crm.server.core.socialmedia.BsiUcSocialMediaChannelHist
com.bsiag.crm.server.core.socialmedia.report.BsiUcSocialMediaMetricHist
com.bsiag.crm.server.core.process.BsiUcStepStepHist
com.bsiag.crm.server.core.process.BsiUcStepHist
com.bsiag.crm.server.core.process.BsiUcStepTransitionHist
com.bsiag.crm.server.core.configuration.privacy.storageobligation.BsiUcStorageObligationRuleHist
com.bsiag.crm.server.core.configuration.code.BsiUcSystemHist
com.bsiag.crm.server.core.process.serviceline.BsiUcTeamHist
com.bsiag.crm.server.core.doctemplate.BsiUcTemplateHist
com.bsiag.crm.server.core.configuration.code.BsiUcHist
com.bsiag.crm.server.core.customer.relation.BsiUcTransitiveRelationHist
com.bsiag.crm.server.core.configuration.code.BsiUcUcHist
com.bsiag.crm.server.core.configuration.parameter.BsiParameterHist
com.bsiag.crm.server.core.configuration.parameter.BsiParameterToClusterNodeHist
com.bsiag.crm.server.core.configuration.parameter.BsiParameterToPartitionHist
com.bsiag.crm.server.core.configuration.parameter.BsiParameterToRoleHist
com.bsiag.crm.server.core.customer.optin.BsiOptInHist
com.bsiag.crm.server.core.customer.quickcapture.BsiUcQuickCaptureHist
com.bsiag.crm.server.core.customer.relation.BsiTransitiveRelationHist
com.bsiag.crm.server.core.customer.role.BsiCustomerCustomerHist
com.bsiag.crm.server.core.document.BsiDocumentHist
com.bsiag.crm.server.core.employee.month.BsiEmployeeMonthHist
com.bsiag.crm.server.core.employee.portfolio.BsiPortfolioHist
com.bsiag.crm.server.core.employee.resource.BsiResourceHist
com.bsiag.crm.server.core.externalcontract.BsiExternalContractHist
com.bsiag.crm.server.core.newsfeed.code.BsiUcNewsfeedFilterHist
com.bsiag.crm.server.core.process.knowledge.BsiKnowledgeLanguageHist
com.bsiag.crm.server.core.process.knowledge.BsiKnowledgeHist
com.bsiag.crm.server.core.process.memo.BsiMemoHist
com.bsiag.crm.server.core.process.pcase.BsiCaseInputHist
com.bsiag.crm.server.core.process.pcase.BsiCaseStepHist
com.bsiag.crm.server.core.process.pcase.BsiCaseHist
com.bsiag.crm.server.core.process.serviceline.BsiServiceLineHist
com.bsiag.crm.server.core.socialmedia.BsiSocialMediaItemHist
com.bsiag.crm.server.core.ticket.BsiTicketHist
com.bsiag.crm.server.core.tile.BsiTileHist
com.bsiag.crm.server.core.user.BsiMatrixPartitionHist
com.bsiag.crm.server.core.user.BsiUserSubstituteHist
com.bsiag.crm.server.core.user.tickermessage.BsiTickerHist


*/


/*
ch.basler.bsicrm.server.contract.BsiXContractCustomerHist
[
  "029a5837-829f-4317-83a3-f3f1a3a18072-role",
  "e03efc9d-80ac-4319-84a9-9b9a2edcddf1-customer"
]
*/



select  *
from    bsi_benefit_hist
;

select  *
from    bsi_x_contract_customer_hist
;




create table sbu_json (
  dept_json varchar2(1000) check (dept_json is json)
);

insert into sbu_json values ('{
  "department": "Accounting",
  "employees": [
    {
      "name": "Shelley,Higgins",
      "job": "Accounting Manager"
    },
    {
      "name": "William,Gietz",
      "job": "Public Accountant"
    }
  ]
}
');

select  json_object_t(dept_json).get_keys
from    sbu_json
;

commit;

declare
  jdoc t.dept_json%type;
  jobj json_object_t;
  keys json_key_list;
  jarr json_array_t;
  arrkeys json_key_list;
  elem json_element_t;
begin

  select dept_json 
  into   jdoc
  from   t;
  
  jobj := json_object_t ( jdoc );
    
  keys := jobj.get_keys;
  
  for i in 1 .. keys.count loop
    dbms_output.put_line(keys(i));
    if jobj.get(keys(i)).is_array then
      jarr := jobj.get_array(keys(i));
      elem := jarr.get(1);
      arrkeys := treat ( elem as json_object_t ).get_keys;
      for j in 1 .. arrkeys.count loop
        dbms_output.put_line('  ' || arrkeys(j));
      end loop;
    end if;
  end loop;
end;
/



create table sbu_json
(
    id  raw(16) not null,
    date_loaded timestamp(6) with time zone,
    json_data clob constraint ensure_json check (json_data is json)
);

insert into sbu_json
values (
            sys_guid(),
            systimestamp,
            '{"PONumber"              : 1600,
              "Reference"             : "ABULL-20140421",
               "Requestor"            : "Alexis Bull",
               "User"                 : "ABULL",
               "CostCenter"           : "A50",
               "ShippingInstructions" : {"name"   : "Alexis Bull",
                                         "Address": {"street"   : "200 Sporting Green",
                                                      "city"    : "South San Francisco",
                                                      "state"   : "CA",
                                                      "zipCode" : 99236,
                                                      "country" : "United States of America"},
                                         "Phone" : [{"type" : "Office", "number" : "909-555-7307"},
                                                    {"type" : "Mobile", "number" : "415-555-1234"}]},
               "Special Instructions" : null,
               "AllowPartialShipment" : true,
               "LineItems" : [{"ItemNumber" : 1,
                               "Part" : {"Description" : "One Magic Christmas",
                                         "UnitPrice"   : 19.95,
                                         "UPCCode"     : 13131092899},
                               "Quantity" : 9.0},
                              {"ItemNumber" : 2,
                               "Part" : {"Description" : "Lethal Weapon",
                                         "UnitPrice"   : 19.95,
                                         "UPCCode"     : 85391628927},
                               "Quantity" : 5.0}]}'
        );

select  *
from    sbu_json    jd,
        json_table(json_data, '$'
        columns(
            fields varchar2(100) format json path '$.*')) as jt
;
    



select  json,
        json_value(json, '$.002c81e5-19a5-47e3-aed0-8883fd54adbc-diamond')
from    (
    select  to_clob('
    {
        "_type":"crm.TimemachineData",
        "002c81e5-19a5-47e3-aed0-8883fd54adbc-diamond":{"b":false},
        "03b9a7fe-f3da-4ac5-bf6f-bf2290d75e8c-advertisingBlockByCustomer":{"b":false},
        "07ac4848-8f26-489b-bd6a-d3309a638dd5-mortgageAtBasler":{"b":false},
        "08d68be5-318c-4964-a8f0-709d951130cb-name1":{"t":"Berger"},
        "0a450fce-3135-440e-b4c3-44b7238d9815-globalKey":{"t":"4d6db968-24cc-4e4a-9390-649559bf05d7"},
        "0f952bc0-dee1-44df-af49-9b18a557bd05-languageUid":{
            "k":"1;112192;106064;j7770;j71099",
            "t":{"de":"Französisch","en":"French","fr":"français","it":"francese"}
        },
        "329af230-3179-4964-bfa2-1d40fa915e4e-useLetterSalutationLineOverride":{"b":false},
        "388bb19d-e3b9-451d-9cb0-a539e56ac8d9":{"b":true},
        "467a26dd-42e0-43b7-ae3e-e3c20817209e-active":{"b":true},
        "56799706-9bb1-4df2-82b7-9cad590231ed-useTitleInAddress":{"b":true},
        "6320e8c3-f3c3-4c17-b7c0-d2430160130f-typeUid":{
            "k":"1;112192;106064;j168392;j111864",
            "t":{"de":"Interne Person","en":"Internal contact person","fr":"Personne interne","it":"Persona interna"}
        },
        "73b89ca6-d716-45a4-98f4-cdc38ab4162f-image":{
            "br":"binref:/crm/timemachine/88755285-42ef-47ed-8eb7-e15cd9972f1d",
            "t":{"de":"(Bild)","en":"(Image)","fr":"(Image)","it":"(Immagine)"}
        },
        "94e5303c-a07f-4da2-987f-63ca3c5c74fb-advisors":{
            "ta":[
                {
                    "223d3cfe-4292-4781-9b1e-7739ff48e92b-advisor":{
                        "k":"1;112198;103380;j4",
                        "t":"Portfolio"
                    },
                    "a4f4068a-d3f6-44ac-9430-94f9b25301e5-advisorUid":{
                        "k":"1;112192;106064;j135985;j113690",
                        "t":{"de":"Hauptbetreuer","en":"Main advisor","fr":"Conseiller principal","it":"Consulente principale"}
                    },
                    "k":"1;113713;113701;j1058982689;j4;n;n;j135985"
                }
            ]
        }
    }') as json
    from    dual
) 
;



select  cust.customer_nr,
        cust.customer_no,
        cust.display_name,
        cuhi.hist_nr,
        cuhi.evt_change,
        json_value(cuhi.data, '$."08d68be5-318c-4964-a8f0-709d951130cb-name1".t')   as  name1,
        json_value(cuhi.data, '$."d4fe4f86-6faa-4e5a-bc91-1e143a7fb8e5-name2".t')   as  name2,
        json_value(cuhi.data, '$."6290fb03-61d4-4b0f-8333-542417769335-name3".t')   as  name3,
        json_value(cuhi.data, '$."e7c86511-6d1e-42a2-8820-5d7a00b571ad-shortName".t')   as  short_name,
        json_value(cuhi.data, '$."9aa01169-efbe-4bfb-aa1e-0ff8a77ca999-customerNo".t')   as  CUSTOMER_NO,
        json_value(cuhi.data, '$."f0ca768f-153c-4d5c-bb4a-1ea7a2d27988-genderUid".t.en')   as  GENDER_UID,
        json_value(cuhi.data, '$."9997af35-a65b-4ac2-bde5-2d797df6837e-title".t')   as  TITLE,
      --json_value(cuhi.data, '$."56799706-9bb1-4df2-82b7-9cad590231ed-useTitleInAddress".b')   as  USE_TITLE_IN_ADDRESS,
        json_value(cuhi.data, '$."c049bf00-9edf-4d33-840d-f7878fafee3f-evtBirth".d')   as  EVT_BIRTH,
        json_value(cuhi.data, '$."6320e8c3-f3c3-4c17-b7c0-d2430160130f-typeUid".t.en')   as  TYPE_UID,
      --json_value(cuhi.data, '$."329af230-3179-4964-bfa2-1d40fa915e4e-useLetterSalutationLineOverride".b')   as  USE_LETTER_SALUTATION_LINE_OVERRIDE,
      --json_value(cuhi.data, '$."3547a416-5fbe-45ca-9aaa-7aa0ea40e9dd-letterSalutationLineOverride".t')   as  LETTER_SALUTATION_LINE_OVERRIDE,
        json_value(cuhi.data, '$."0f952bc0-dee1-44df-af49-9b18a557bd05-languageUid".t.en')   as  LANGUAGE_UID,
        json_value(cuhi.data, '$."467a26dd-42e0-43b7-ae3e-e3c20817209e-active".b')   as  ACTIVE,
        json_value(cuhi.data, '$."63029141-806e-4974-b07e-3496785e3d40-ratingUid".t.en')   as  RATING_UID,
      --json_value(cuhi.data, '$."6c51c921-b353-4b7f-8bf0-027bd92e880e-notes".t')   as  TEXT_LOB,
        json_value(cuhi.data, '$."c94c08a2-7be3-485f-950f-20baf9a487f4-privacyStatus".t.en')   as  PRIVACY_STATUS_UID,
        json_value(cuhi.data, '$."f003eb92-6419-467b-9174-837d5614a5f4-lastMergeInfo".t')   as  LAST_MERGE_INFO,
        json_value(cuhi.data, '$."d8cee60f-98a0-435e-8632-1a3709ddec47-advertisingBlock".b')   as  ADVERTISING_BLOCK,
        json_value(cuhi.data, '$."03b9a7fe-f3da-4ac5-bf6f-bf2290d75e8c-advertisingBlockByCustomer".b')   as  ADVERTISING_BLOCK_BY_CUSTOMER,
        json_value(cuhi.data, '$."e6b77a86-9298-4053-a0c0-43a1296a3445-advertisingBlockReason".t')   as  ADVERTISING_BLOCK_REASON,
        json_value(cuhi.data, '$."595dd6f1-b2c8-4c29-8a0d-f3a9ddf48421-advertisingBlockCommunication".t')   as  ADVERTISING_BLOCK_COMMUNICATION_KEY,
        --json_value(cuhi.data, '$."".t')   as  ,
        --json_value(cuhi.data, '$."".t')   as  ,
        --json_value(cuhi.data, '$."".t')   as  ,
        --json_value(cuhi.data, '$."".t')   as  ,
        --json_value(cuhi.data, '$."".t')   as  ,
        --json_value(cuhi.data, '$."".t')   as  ,
        --json_value(cuhi.data, '$."".t')   as  ,
        --json_value(cuhi.data, '$."".t')   as  ,
        --json_value(cuhi.data, '$."".t')   as  ,
        cust.last_merge_info,
        cuhi.*
from    bsi.bsi_customer        cust
        inner join  bsi.bsi_customer_hist   cuhi    on  cuhi.customer_nr = cust.customer_nr
where   1=1
    and cust.customer_no in
        (
            '18726861',
            '19817471',
            null
        )
    and cust.type_uid = 157028	-- Person
order   by  cust.customer_nr,
            cuhi.hist_nr;

select  c.customer_no,
        c.display_name,
        c.last_merge_info
from    bsi.bsi_customer   c
where   1=1
    and c.last_merge_info is not null
;

select  *
from    bsi.bsi_customer_hist   h
where   1=1
    and h.data like '%595dd6f1-b2c8-4c29-8a0d-f3a9ddf48421-advertisingBlockCommunication%'
fetch first 2 rows only
;


select  cuch.*
from    bsi.bsi_customer        cust
        inner join  bsi.bsi_customer_change cuch    on  cuch.item_nr = cust.customer_nr
where   1=1
    and cust.customer_no = '18726861'
    and cust.type_uid = 157028	-- Person
;




/*
    CustomerTimemachineHandler
    


9997af35-a65b-4ac2-bde5-2d797df6837e-title
TITLE
56799706-9bb1-4df2-82b7-9cad590231ed-useTitleInAddress
USE_TITLE_IN_ADDRESS
c049bf00-9edf-4d33-840d-f7878fafee3f-evtBirth
EVT_BIRTH
6320e8c3-f3c3-4c17-b7c0-d2430160130f-typeUid
TYPE_UID
329af230-3179-4964-bfa2-1d40fa915e4e-useLetterSalutationLineOverride
USE_LETTER_SALUTATION_LINE_OVERRIDE
3547a416-5fbe-45ca-9aaa-7aa0ea40e9dd-letterSalutationLineOverride
LETTER_SALUTATION_LINE_OVERRIDE
0f952bc0-dee1-44df-af49-9b18a557bd05-languageUid
LANGUAGE_UID
467a26dd-42e0-43b7-ae3e-e3c20817209e-active
ACTIVE
63029141-806e-4974-b07e-3496785e3d40-ratingUid
RATING_UID
6c51c921-b353-4b7f-8bf0-027bd92e880e-notes
TEXT_LOB
c94c08a2-7be3-485f-950f-20baf9a487f4-privacyStatus
PRIVACY_STATUS_UID
f003eb92-6419-467b-9174-837d5614a5f4-lastMergeInfo
LAST_MERGE_INFO
d8cee60f-98a0-435e-8632-1a3709ddec47-advertisingBlock
ADVERTISING_BLOCK
03b9a7fe-f3da-4ac5-bf6f-bf2290d75e8c-advertisingBlockByCustomer
ADVERTISING_BLOCK_BY_CUSTOMER
e6b77a86-9298-4053-a0c0-43a1296a3445-advertisingBlockReason
ADVERTISING_BLOCK_REASON
595dd6f1-b2c8-4c29-8a0d-f3a9ddf48421-advertisingBlockCommunication
ADVERTISING_BLOCK_COMMUNICATION_KEY
0705fee0-d6ab-48ab-80e7-4691788d293d-preferredChannel
PREFERRED_CHANNEL_UID

        .withContentJoin(new TimemachineOneToManyContentJoinMapping.Builder<CustomerKey>()
            .withUuid("82dab41d-cedd-4345-9de0-42bfef463a63-scores")
            .withClassIds("c261e022-a248-4805-a1b6-a3242cc304ec")
            .withDefaultLabelTextKey("Score")
            .withChildMappings(createBsiCustomerScoreTableMappings())
            .withJoinKeyColumn(BsiCustomerScore_.CUSTOMER_KEY).build())
        .withContentJoin(new TimemachineOneToManyContentJoinMapping.Builder<CustomerKey>()
            .withUuid(SEGMENTATIONS_UUID)
            .withClassIds("446e06a9-efee-45c2-81f6-b2ceaf90c7ce")
            .withDefaultLabelTextKey("Segmentation")
            .withChildMappings(createBsiCustomerSegmentationTableMappings())
            .withJoinKeyColumn(BsiCustomerSegmentation_.CUSTOMER_KEY).build())
        .withContentJoin(new TimemachineOneToManyContentJoinMapping.Builder<CustomerKey>()
            .withUuid(ADVISORS_UUID)
            .withClassIds("9d9adc75-a6e1-4ee8-86ea-82e13db301c8")
            .withDefaultLabelTextKey("Representation")
            .withChildMappings(createBsiCustomerAdvisorTableMappings())
            .withJoinKeyColumn(BsiCustomerAdvisor_.CUSTOMER_KEY).build())
        .withTableJoin(new TimemachineOneToManyTableJoinMapping.Builder<CustomerKey>()
            .withUuid("ee506ad7-7cd8-42e6-9907-6e68f2e20f2c-customerRelations")
            .withDefaultLabelTextKey("CustomerRelations")
            .withJoinTableClass(BsiCustomerCustomer.class)
            .withJoinKeyColumns(
                BsiCustomerCustomer_.MAIN_CUSTOMER_KEY,
                BsiCustomerCustomer_.SUB_CUSTOMER_KEY)
            .build())
        .withTableJoin(new TimemachineOneToManyTableJoinMapping.Builder<CustomerKey>()
            .withUuid("83133ae3-15d2-4a0f-9b54-b3e3afe5866a-networks")
            .withDefaultLabelTextKey("Network")
            .withJoinTableClass(BsiCustomerTransitiveRelation.class)
            .withJoinKeyColumn(BsiCustomerTransitiveRelation_.CUSTOMER_KEY).build())
        .withTableJoin(new TimemachineOneToManyTableJoinMapping.Builder<CustomerKey>()
            .withUuid("0f7c5029-3903-485c-b3ac-80a58f93db16-addresses")
            .withClassIds("2de0035c-0431-4cbc-b65a-e303b54ff71d")
            .withDefaultLabelTextKey("Addresses")
            .withJoinTableClass(BsiAddress.class)
            .withJoinKeyColumnTypeChecked(BsiAddress_.ITEM_KEY, CustomerKey.class).build())
        .withTableJoin(new TimemachineOneToManyTableJoinMapping.Builder<CustomerKey>()
            .withUuid("2687cfbf-7be9-4274-9e61-4e5df12ea2ee-optIn")
            .withClassIds("49e8a0cc-ce8d-4feb-ad29-5695ae040d3c_c58a4e90-9327-438c-925e-a6348dfeedd0", "e541085c-f6d3-47fa-a55b-4fab3b44267b_c58a4e90-9327-438c-925e-a6348dfeedd0")
            .withDefaultLabelTextKey("Marketing")
            .withJoinTableClass(BsiOptIn.class)
            .withJoinKeyColumn(BsiOptIn_.CUSTOMER_KEY).build())
        .withContentJoin(new TimemachineOneToManyContentJoinMapping.Builder<CustomerKey>()
            .withUuid("39a77694-dff2-4a7c-bb66-a05ba641566a-figures")
            .withClassIds("c5f05235-8b6e-4523-9669-145af25b7392", "216e8496-edcf-4096-b7e2-5b688490f921")
            .withDefaultLabelTextKey("FinancialFigures")
            .withChildMappings(createBsiCustomerFigureTableMappings())
            .withJoinKeyColumn(BsiCustomerFigure_.CUSTOMER_KEY).build())
        .withContentJoin(new TimemachineOneToManyContentJoinMapping.Builder<CustomerKey>()
            .withUuid("3aa6e6d0-43f6-4199-a59b-6edddfb4529e-nextBestActions")
            .withClassIds("d74c7dd3-27cb-4e65-8409-d10381310b87")
            .withDefaultLabelTextKey("NextBestAction")
            .withChildMappings(createBsiNextBestActionTableMappings())
            .withJoinKeyColumn(BsiNextBestAction_.CUSTOMER_KEY).build())
        .withTableJoin(new TimemachineOneToManyTableJoinMapping.Builder<CustomerKey>()
            .withUuid("08340854-5540-4864-b69d-1c8634dcfe9f-documents")
            .withClassIds("6833c4d9-4ab3-45cc-8232-4dee0a35d8fe_8d89418c-493e-46a9-bb02-cd544a2225e5")
            .withDefaultLabelTextKey("Documents")
            .withJoinTableClass(BsiDocument.class)
            .withJoinKeyColumnTypeChecked(BsiDocument_.ITEM_KEY, CustomerKey.class).build())
        .withContentJoin(new TimemachineOneToManyContentJoinMapping.Builder<CustomerKey>()
            .withUuid("9a7d079d-c52e-4b99-9c68-b144140306c9-portalIdentities")
            .withClassIds("6062fb9e-adec-404f-b6fa-4f8d08fc6b12")
            .withDefaultLabelTextKey("PortalIdentities")
            .withChildMappings(createBsiPortalIdentityTableMappings())
            .withJoinKeyColumn(BsiPortalIdentity_.CUSTOMER_KEY).build())
        .withTableJoin(new TimemachineOneToManyTableJoinMapping.Builder<CustomerKey>()
            .withUuid("e2308517-f2fd-43c8-9beb-9429ebf84c43-partitions")
            .withClassIds("9e6876fb-e236-4779-a482-f4adcf2f3187_cea0c212-5ac0-4758-ac62-80b6ce1f08ef")
            .withDefaultLabelTextKey("Partitions")
            .withJoinTableClass(BsiMatrixPartition.class)
            .withJoinKeyColumnTypeChecked(BsiMatrixPartition_.ITEM_KEY, CustomerKey.class).build());
  }












