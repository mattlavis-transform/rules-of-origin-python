with cte as (
    select distinct on (qd.quota_definition_sid)
    qd.quota_definition_sid, quota_order_number_id, qbe.occurrence_timestamp,
    qbe.new_balance, qbe.old_balance, qbe.imported_amount 
    from quota_definitions qd, quota_balance_events qbe 
    where qd.quota_definition_sid = qbe.quota_definition_sid
    and validity_end_date > '2020-12-31'
    and left(quota_order_number_id, 2) = '05'
    order by quota_definition_sid, occurrence_timestamp desc
) select * from cte order by quota_order_number_id, occurrence_timestamp;

select * from quota_definitions qd where quota_order_number_id = '050053'
order by 1;

select * from utils.materialized_measures_real_end_dates mmred where measure_sid = 20125019;

select * from quota_order_numbers qon where quota_order_number_id = '051101';
select * from quota_definitions qd where quota_order_number_id = '051101';

select * from utils.materialized_measures_real_end_dates m
where ordernumber is not null
and validity_end_date is null 
and right(goods_nomenclature_item_id, 6) = '000000';

select distinct on (gnd.goods_nomenclature_item_id)
gnd.goods_nomenclature_item_id, gnd.description
from goods_nomenclature_descriptions gnd,
goods_nomenclature_description_periods gndp,
goods_nomenclatures gn 
where gnd.goods_nomenclature_sid = gndp.goods_nomenclature_sid 
and gn.goods_nomenclature_sid = gnd.goods_nomenclature_sid 
and gn.validity_end_date is null
and right(gnd.goods_nomenclature_item_id, 4) = '0000'
and right(gnd.goods_nomenclature_item_id, 8) != '00000000'
order by gnd.goods_nomenclature_item_id,  gndp.validity_start_date desc

select * from roo.rules where id_rule = 252526

select *
from roo.rules where country_code = 'KR'
and heading = '6306'
order by key_first;

select heading, rule
from roo.rules where country_code = 'CA'
and rule like '%wholly obtained%'
order by key_first;


select distinct left(gn.goods_nomenclature_item_id, 4)
from goods_nomenclatures gn
where right(gn.goods_nomenclature_item_id, 6) = '000000'
and gn.validity_end_date is null
order by 1;

select * from goods_nomenclature_descriptions gnd,
goods_nomenclatures gn
where description like '%wordfish%'
and gn.goods_nomenclature_sid = gnd.goods_nomenclature_sid 
and gn.validity_end_date is null;

select m.measure_sid, m.goods_nomenclature_item_id, gn.description,
mc.duty_amount, mc.duty_expression_id, mc.measurement_unit_code 
from utils.materialized_measures_real_end_dates m, measure_components mc,
utils.materialized_commodities gn
where validity_end_date is null
and m.measure_sid = mc.measure_sid 
and measure_type_id = '306'
and m.goods_nomenclature_sid = gn.goods_nomenclature_sid 
and additional_code in (
	'X431',
	'X433',
	'X435',
	'X422',
	'X423',
	'X412',
	'X413',
	'X421',
	'X411',
	'X425',
	'X415',
	'X429',
	'X419'
)
order by goods_nomenclature_item_id, measure_sid, duty_expression_id

select * from measurement_unit_descriptions mud where measurement_unit_code = 'HLT'


select m.additional_code, m.measure_sid, m.goods_nomenclature_item_id, gn.description,
mc.duty_amount, mc.duty_expression_id, mc.measurement_unit_code 
from utils.materialized_measures_real_end_dates m, measure_components mc,
utils.materialized_commodities gn
where m.validity_end_date is null
and m.measure_sid = mc.measure_sid 
and measure_type_id = '306'
and m.goods_nomenclature_sid = gn.goods_nomenclature_sid 
and additional_code in (
'X571',
'X572',
'X589',
'X595',
'X99A',
'X99B',
'X99C',
'X99D',
'X540',
'X541',
'X542',
'X551',
'X556',
'X561',
'X570',
'X511',
'X520',
'X521',
'X522',
'X591',
'X592'
)
order by goods_nomenclature_item_id, measure_sid, duty_expression_id


select goods_nomenclature_item_id, description 
from utils.materialized_commodities mc where right(goods_nomenclature_item_id, 8) = '00000000' order by 1;



select * from measure_type_series_descriptions mtd 

-- Get all condition codes
select condition_code, count(mc.*)
from measure_conditions mc, utils.materialized_measures_real_end_dates m 
where m.measure_sid = mc.measure_sid
and m.validity_end_date is null
group by condition_code
order by 1;

-- Get all action codes
select mc.action_code, mad.description as mad_desc, mt.measure_type_id, mtd.description as mtd_desc, count(mc.*)
from measure_conditions mc, utils.materialized_measures_real_end_dates m, measure_action_descriptions mad, 
measure_types mt, measure_type_descriptions mtd 
where m.measure_sid = mc.measure_sid
and mt.measure_type_id = mtd.measure_type_id 
and m.validity_end_date is null
and m.measure_type_id = mt.measure_type_id 
and mt.measure_component_applicable_code != '2'
and mc.action_code in ('11', '14', '10', '30')
and mc.action_code = mad.action_code 
group by mc.action_code, mad.description, mt.measure_type_id, mtd.description 
order by 1;

11 -- 552 * 70
14 -- 552 * 3

select * from utils.materialized_measures_real_end_dates m, measure_conditions mc 
where m.measure_sid = mc.measure_sid 
and mc.action_code = '11'
and m.measure_type_id = '552'
and m.validity_end_date is null
;

select * from measure_type_descriptions where measure_type_id > '480' order by 1;


select * from utils.materialized_measures_real_end_dates mmred
where measure_type_id = '490'
and (validity_end_date is null or validity_end_date > '2021-01-01');


select br.base_regulation_id, information_text, count(m.*)
from base_regulations br, utils.materialized_measures_real_end_dates m
where br.base_regulation_id = m.measure_generating_regulation_id 
and br.base_regulation_role = m.measure_generating_regulation_role 
and m.validity_end_date is null
group by br.base_regulation_id, information_text
order by 1;



select br.base_regulation_id, information_text, m.goods_nomenclature_item_id, m.measure_type_id, m.geographical_area_id 
from base_regulations br, utils.materialized_measures_real_end_dates m
where br.base_regulation_id = m.measure_generating_regulation_id 
and br.base_regulation_role = m.measure_generating_regulation_role 
and m.validity_end_date is null
order by 1;

select * from goods_nomenclature_descriptions gnd where goods_nomenclature_item_id = '3920690070';

Transparent film consisting of polyester coated with a layer of indium and silver
Film of a copolymer of ethane-1,2-diol and naphthalene-2,6-dicarboxylic acid, of a thickness of less than 10 micrometres, for the manufacture of video-cassettes with a playing-time of 300 minutes at a tape-speed of 24 mm per second
Non-metallised reflecting film, consisting of outside layers of poly(ethylene terephthalate) or poly(ethylene naphthalate) and multiple layers of poly(methyl methacrylate), of a reflectance coefficient of 95 % or more (as determined by the ASTM E 1164-94 and ASTM E 387-95 methods) and a total thickness not exceeding 70 μm
Mono- or multilayer, biaxially oriented film:<br> <br>-composed of more than 85 % by weight of polylactic acid, not more than 5 % by weight of inorganic or organic additives, and not more than 10 % by weight of additives based on biodegradable polyesters,<br> <br>-with a thickness of 9 ?m or more but not more than 120 ?m,<br> <br>-with a length of 1 395 m or more but not more than 21 560 m,<br> <br>-biodegradable and compostable (as determined by the method EN 13432)<br>

select * from goods_nomenclature_descriptions gnd where description like '%?%';

-- 3920690070
update goods_nomenclature_descriptions
set description = 'Mono- or multilayer, biaxially oriented film:<br> <br>-composed of more than 85 % by weight of polylactic acid, not more than 5 % by weight of inorganic or organic additives, and not more than 10 % by weight of additives based on biodegradable polyesters,<br> <br>-with a thickness of 9 μm or more but not more than 120 μm,<br> <br>-with a length of 1 395 m or more but not more than 21 560 m,<br> <br>-biodegradable and compostable (as determined by the method'
where goods_nomenclature_description_period_sid = 151136 and goods_nomenclature_sid = 105447;

-- 3920690030
update goods_nomenclature_descriptions
set description = 'Mono- or multilayer, transverse oriented, shrink film:<br> <br>-composed of more than 85 % by weight of polylactic acid, not more than 5 % by weight of inorganic or organic additives and not more than 10 % by weight of additives based on biodegradable polyesters,<br> <br>-with a thickness of 20 μm or more but not more than 100 μm,<br> <br>-with a length of 2 385 m or more but not more than 9 075 m,<br> <br>-biodegradable and compostable (as determined by the method EN 13432)'
where goods_nomenclature_description_period_sid = 151135 and goods_nomenclature_sid = 105446;

-- 3920102530
update goods_nomenclature_descriptions
set description = 'Mono-layered High-Density Polyethylene film:<br> <br>-containing by weight 99 % or more of polyethylene,<br> <br>-with a thickness of 12 μm or more but not more than 20 μm,<br> <br>-with a length of 4000 m or more but not more than 7000 m,<br> <br>-with a width of 600 mm or more but not more than 900 mm'
where goods_nomenclature_description_period_sid = 151060 and goods_nomenclature_sid = 105371;

-- 2903898045
update goods_nomenclature_descriptions
set description = '1,6,7,8,9,14,15,16,17,17,18,18-Dodecachloropentacyclo [12.2.1.1⁶,⁹.0²,¹³.0⁵,¹⁰]octadeca-7,15-diene (CAS RN 13560-89-9) with a purity by weight of 99 % or more'
where goods_nomenclature_description_period_sid = 151145 and goods_nomenclature_sid = 105456;

-- 8714109010
update goods_nomenclature_descriptions
set description = 'Motorcycle fork rod inner tubes:<br>- of SAE1541 carbon steel,<br>- with a hard chromium layer of 20μm (+ 15μm/ – 5μm),<br>- having a wall thickness of 1.3mm or more, but not more than 1.6mm,<br>- having an elongation at break of 15%,<br>- perforated<br>'
where goods_nomenclature_description_period_sid = 151206 and goods_nomenclature_sid = 99628;

select * from utils.materialized_measures_real_end_dates mmred where measure_generating_regulation_id = 'X2007070'; -- Iraq
select * from utils.materialized_measures_real_end_dates mmred where measure_generating_regulation_id = 'X2007070'; -- Iraq

select * from utils.materialized_measures_real_end_dates m, measure_types mt 
where m.measure_type_id = mt.measure_type_id 
and mt.trade_movement_code = 1
and geographical_area_id not in ('1011', '1008')
and m.validity_end_date is null;

select * from goods_nomenclature_descriptions gnd where description ilike '%brazing%';

select * from measure_action_descriptions mad order by 1;

select * from certificate_descriptions cd
where certificate_type_code = 'Y'
and certificate_code = '978';


-- Get a full list of document codes
select distinct mc.certificate_type_code, mc.certificate_code, (mc.certificate_type_code || mc.certificate_code) as code
from utils.materialized_measures_real_end_dates m, measure_types mt, measure_conditions mc 
where m.measure_type_id = mt.measure_type_id 
and m.validity_end_date is null
and mt.trade_movement_code != 1
and mt.measure_type_series_id in ('A', 'B')
and m.measure_sid = mc.measure_sid
order by 1, 2;


-- Get a full list of document codes and their assignments to comm codes
select distinct mc.certificate_type_code, mc.certificate_code,
(mc.certificate_type_code || mc.certificate_code) as code, m.goods_nomenclature_item_id, m.measure_type_id 
from utils.materialized_measures_real_end_dates m, measure_types mt, measure_conditions mc 
where m.measure_type_id = mt.measure_type_id 
and m.validity_end_date is null
and mt.trade_movement_code != 1
and mt.measure_type_series_id in ('A', 'B')
and m.measure_sid = mc.measure_sid
order by 1, 2;



-- Get individual document codes
select m.*, mc.certificate_type_code, mc.certificate_code, (mc.certificate_type_code || mc.certificate_code) as code
from utils.materialized_measures_real_end_dates m, measure_types mt, measure_conditions mc 
where m.measure_type_id = mt.measure_type_id 
and m.validity_end_date is null
and mt.measure_type_series_id in ('A', 'B')
and m.measure_sid = mc.measure_sid
and mc.certificate_type_code = 'E' and mc.certificate_code = '010'
order by 1, 2;



-- Gets the missing certificates
with cte as (
	select cd.certificate_type_code || cd.certificate_code as code, cd.description 
	from certificate_descriptions cd, certificate_description_periods cdp 
	where cdp.certificate_type_code = cd.certificate_type_code 
	and cdp.certificate_code = cd.certificate_code
) select * from cte
where code in (
'E010',
'L097',
'Y067',
'Y229',
'Y978'
)
order by 1;

select * from utils.materialized_measures_real_end_dates m, measure_types mt 
where m.measure_type_id = mt.measure_type_id 
and m.validity_end_date is null 
and mt.measure_type_series_id in ('A', 'xB')
order by 1;

select distinct measure_generating_regulation_id
from utils.materialized_measures_real_end_dates m, measure_types mt 
where m.measure_type_id = mt.measure_type_id 
and m.geographical_area_id = 'SY'
and m.validity_end_date is null 
and mt.measure_type_series_id in ('A', 'B')
order by 1;

select measure_generating_regulation_id, * from measures where measure_sid = 3136870;

select * from measure_type_descriptions mtd where measure_type_id >= '488' order by 1 

select * from measures where measure_type_id = '465'
and validity_start_date >= '2021-01-01'
and geographical_area_id in ('1011', '1008')
order by validity_start_date desc;

select * from utils.materialized_measures_real_end_dates m
where measure_type_id = '712'
and validity_end_date is null;

select * from goods_nomenclatures where goods_nomenclature_item_id = '3926909700';

select distinct *
from utils.materialized_measures_real_end_dates m, measure_conditions mc 
where m.measure_sid = mc.measure_sid 
and m.validity_end_date is null 
and mc.certificate_type_code = 'C'
and mc.certificate_code = '693';


select * from utils.materialized_measures_real_end_dates m, measure_partial_temporary_stops mpts 
where goods_nomenclature_item_id like '940340%'
and m.validity_end_date is null
and m.measure_generating_regulation_id = mpts.partial_temporary_stop_regulation_id 
order by measure_type_id;

select * from base_regulations br where base_regulation_id = 'D1908540';



select * from measure_partial_temporary_stops mpts 

select * from measure_type_descriptions mtd order by 1;

with cte as (
	select (mc.certificate_type_code || mc.certificate_code) as code, m.goods_nomenclature_item_id,
	m.measure_sid 
	from utils.materialized_measures_real_end_dates m, measure_conditions mc 
	where measure_type_id = '724'
	and validity_end_date is null
	and m.measure_sid = mc.measure_sid 
	order by goods_nomenclature_item_id
)
select measure_sid, goods_nomenclature_item_id, string_agg(code, ', ' order by code) as code_combinations
from cte
group by measure_sid, goods_nomenclature_item_id
order by code_combinations, goods_nomenclature_item_id;

-- USA item 
select *
from utils.materialized_measures_real_end_dates m
where measure_type_id = '465'
and geographical_area_id = 'US'
and validity_end_date is null
order by measure_generating_regulation_id, goods_nomenclature_item_id;

-- Fluorinated
select *
from utils.materialized_measures_real_end_dates m
where measure_type_id = '724'
--and geographical_area_id = 'US'
and validity_end_date is null
order by measure_generating_regulation_id, goods_nomenclature_item_id;

select * from utils.materialized_measures_real_end_dates m
where goods_nomenclature_item_id like '87085020%'
-- and validity_end_date is null
and measure_type_id in ('103', '105');


select * from utils.materialized_measures_real_end_dates m
where measure_type_id = '490'
--and goods_nomenclature_item_id = '0805220020'
and measure_sid = 3753097

update measures_oplog
set validity_end_date = '2020-02-26'
where measure_sid = 3753097;


delete from roo.rules where scope = 'uk';
delete from roo.rules_to_commodities where scope = 'uk';

select * from roo.rules where scope = 'uk'
order by id_rule;

select * from roo.rules where scope = 'uk' and id_rule = 10000341
order by id_rule;

select mac.additional_code,
mtcc.row_column_code, mht.description as heading_description, mtcc.subheading_sequence_number 
from meursing_additional_codes mac, meursing_table_cell_components mtcc,
meursing_heading_texts mht
where mac.meursing_additional_code_sid = mtcc.meursing_additional_code_sid
and mtcc.row_column_code = mht.row_column_code
and mtcc.heading_number = mht.meursing_heading_number
and mtcc.heading_number = 10
order by mht.row_column_code, mtcc.subheading_sequence_number, mac.additional_code





select count(*) from roo.rules_to_commodities
where scope = 'uk'
and country_prefix = 'eu';


select distinct on (gnd.goods_nomenclature_item_id)
gnd.goods_nomenclature_item_id, gnd.description
from goods_nomenclature_descriptions gnd, goods_nomenclature_description_periods gndp 
where gnd.goods_nomenclature_sid = gndp.goods_nomenclature_sid 
and right(gnd.goods_nomenclature_item_id, 4) = '0000'
-- and right(gnd.goods_nomenclature_item_id, 8) != '00000000'
and gnd.goods_nomenclature_item_id >= '7000000000'
order by gnd.goods_nomenclature_item_id,  gndp.validity_start_date desc;


select * from goods_nomenclature_descriptions gnd where goods_nomenclature_item_id = '7001000000';


select distinct on (gnd.goods_nomenclature_item_id)
gnd.goods_nomenclature_item_id, coalesce(gnd.description, '') as description
from goods_nomenclature_descriptions gnd, goods_nomenclature_description_periods gndp 
where gnd.goods_nomenclature_sid = gndp.goods_nomenclature_sid 
and right(gnd.goods_nomenclature_item_id, 4) = '0000'
-- and right(gnd.goods_nomenclature_item_id, 8) != '00000000'
and gnd.goods_nomenclature_item_id >= '7000000000'
order by gnd.goods_nomenclature_item_id,  gndp.validity_start_date desc

select * from goods_nomenclature_descriptions gnd where description is null;


select * from goods_nomenclature_descriptions gnd
where goods_nomenclature_item_id >= '0301'
order by goods_nomenclature_item_id;



select r.id_rule, sub_heading, heading, description, rule,
alternate_rule, quota_amount, quota_unit, key_first, key_last
from roo.rules_to_commodities rtc, roo.rules r
where r.id_rule = rtc.id_rule 
and r.country_prefix = 'ke'
and r.scope = 'xi'
and rtc.scope = 'xi'
--and sub_heading = '210111'
order by sub_heading;

delete from roo.rules_to_commodities where country_prefix = 'japan' and scope = 'uk';
delete from roo.rules where country_prefix = 'japan' and scope = 'uk';

       
-- This is useful: keep this, as it shows the similarities
-- Should run a compare on the similarities - Python program
select country_code, country_prefix, scope, count(*)
from roo.rules
--where "scope" = 'uk'
group by country_code, country_prefix, "scope"
order by country_code, scope;

select * from roo.rules r
where scope = 'uk'
and country_code = 'JP'
order by id_rule ;

select rtc.id_rule, rtc.sub_heading, r.heading, r.description, r.*
from roo.rules_to_commodities rtc, roo.rules r 
where rtc.scope = 'uk'
and r.id_rule = rtc.id_rule 
and rtc.country_prefix = 'south-korea'
and rtc.sub_heading like '15%'
order by rtc.sub_heading;


select left(goods_nomenclature_item_id, 4) as min_heading
from goods_nomenclatures gn
where producline_suffix = '80'
and left(goods_nomenclature_item_id, 2) = '01'
and goods_nomenclature_item_id != '0100000000'
order by goods_nomenclature_item_id 
limit 1;




select * from roo.rules where country_code = 'TR' and scope = 'uk';


"scope","id_rule","scheme_code","heading","description","quota_amount","quota_unit","rule","alternate_rule"


with cte as (
select "scope" as old_scope,
case
	when "scope" = 'xi' and country_prefix in ('japan', 'south-korea', 'turkey') then 'xi'
	when "scope" = 'xi' and country_prefix not in ('japan', 'south-korea', 'turkey') then 'xi,uk'
	else 'uk'
end as "scope",
id_rule, country_prefix, heading,
regexp_replace(description, E'[\\n\\r]+', '<br>', 'g' ) as description,
quota_amount, quota_unit,
regexp_replace("rule", E'[\\n\\r]+', ' ', 'g' ) as rule,
regexp_replace(alternate_rule, E'[\\n\\r]+', '<br>', 'g' ) as alternate_rule
from roo.rules
order by "scope" desc, country_prefix, id_rule
)
select distinct(country_prefix) from cte where scope = 'xi';

select * from roo.rules
where country_code = 'MX'
order by date_created desc;

select * from roo.rules where rule ilike '%CTH}%'

select rule 
from roo.rules
where rule like '%CTH%'
and country_code = 'GB';


select current_timestamp 


select * from roo.rules where country_prefix = 'eu';


-- COPY ROO WHERE THE EU DATA IS IN THE OLD STYLE ONLY (classic)

-- Add 2 million for XI copies into the id_rule section

/* Create KENYA data

   This does the copy of Cote d'Ivoire rules for Kenya
   Needed for UK and XI, but that is dealt with in the multi-code export mechanism
 */

delete from roo.rules where scope = 'xi' and country_code = 'KE';
delete from roo.rules_to_commodities where scope = 'xi' and country_prefix = 'turkey';


insert into roo.rules
("scope", country_code, country_prefix, heading, description, quota_amount, quota_unit, key_first, key_last, id_rule, "rule", alternate_rule)
select "scope", 'KE', 'kenya', heading, description, quota_amount, quota_unit, key_first, key_last, (2000000 + id_rule), "rule", alternate_rule 
from roo.rules
where country_code = 'CI'
and scope = 'xi';

insert into roo.rules_to_commodities
(id_rule, sub_heading, country_prefix, "scope")
select id_rule, sub_heading, 'kenya', "scope"
from roo.rules_to_commodities
where country_prefix = 'cotedivoire'
and scope = 'xi';

/* Create TURKEY data

   This does the copy of Albania rules for Turkey
   Needed for XI only, as the UK has its own Turkey rules
 */

delete from roo.rules where scope = 'xi' and country_code = 'TR';
delete from roo.rules_to_commodities where scope = 'xi' and country_prefix = 'turkey';

insert into roo.rules
("scope", country_code, country_prefix, heading, description, quota_amount, quota_unit, key_first, key_last, id_rule, "rule", alternate_rule)
select "scope", 'TR', 'turkey', heading, description, quota_amount, quota_unit, key_first, key_last, (2000000 + id_rule), "rule", alternate_rule 
from roo.rules
where country_code = 'AL'
and scope = 'xi';

insert into roo.rules_to_commodities
(id_rule, sub_heading, country_prefix, "scope")
select id_rule, sub_heading, 'turkey', "scope"
from roo.rules_to_commodities
where country_prefix = 'albania'
and scope = 'xi';
