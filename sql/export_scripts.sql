-- Script for extracting the rules into a single file

/*
Where the scope in the database is 'xi' and the country
is not japan, south korea or turkey, show as 'both', i.e. applicable to UK and XI

For the others, show as applicable to the individual country only
*/

select 
case
	when "scope" = 'xi' and country_prefix in ('japan', 'south-korea', 'turkey', 'eu') then 'xi'
	when "scope" = 'xi' and country_prefix not in ('japan', 'south-korea', 'turkey', 'eu') then 'both'
	else 'uk'
end as "scope",
id_rule, country_prefix as scheme_code, heading,
description,
quota_amount, quota_unit,
rule,
alternate_rule
from roo.rules
order by "scope" desc, country_prefix, id_rule

-- To query on the above
with cte as (
...
)
select distinct(country_prefix) from cte where scope = 'both';


-- Script for extracting the rules to commodities into a single file

select id,
case
	when "scope" = 'xi' and country_prefix in ('japan', 'south-korea', 'turkey') then 'xi'
	when "scope" = 'xi' and country_prefix not in ('japan', 'south-korea', 'turkey') then 'both'
	else 'uk'
end as "scope",
country_prefix as scheme_code, id_rule, sub_heading 
from roo.rules_to_commodities rtc
order by 2, 3, 5, 4


with cte as (
...
)
select distinct(scheme_code) from cte where scope != 'both';



-- OLD rules extraction - do not use

with cte as (
select "scope" as old_scope,
case
	when "scope" = 'xi' and country_prefix in ('japan', 'south-korea', 'turkey') then 'xi'
	when "scope" = 'xi' and country_prefix not in ('japan', 'south-korea', 'turkey') then 'both'
	else 'uk'
end as "scope",
id_rule, country_prefix, heading,
--regexp_replace(description, E'[\\n\\r]+', '<br>', 'g' ) as description,
description,
quota_amount, quota_unit,
--regexp_replace("rule", E'[\\n\\r]+', ' ', 'g' ) as rule,
--regexp_replace(alternate_rule, E'[\\n\\r]+', '<br>', 'g' ) as alternate_rule
rule,
alternate_rule
from roo.rules
order by "scope" desc, country_prefix, id_rule
)
select distinct(country_prefix) from cte where scope = 'both';

select goods_nomenclature_item_id, count(*)
from utils.materialized_measures_real_end_dates m
where validity_end_date is null
and measure_type_id = '305'
and additional_code is not null
group by goods_nomenclature_item_id
order by 2 desc;


select ordernumber, * from measures m 
where ordernumber is not null
and ordernumber not  like '054%'
and ordernumber  like '05%'
--and ordernumber = '057236'
and validity_end_date is not null;

select * from quota_definitions qd where quota_order_number_id = '057236';


select * from measures where goods_nomenclature_item_id = '1006101000'
q;


select * from measures_oplog where measure_sid = 20087857

select * from measure_type_series_descriptions mtsd order by 1

select * from roo.rules order by length("rule") desc;

select * from roo.rules where id_rule = 13000375;

select certificate_type_code, certificate_code, m.goods_nomenclature_item_id 
from measure_conditions mc, utils.materialized_measures_real_end_dates m
where m.measure_sid = mc.measure_sid 
and m.validity_end_date is null 
and m.goods_nomenclature_item_id like '93%'
and mc.certificate_code = '104';

select * from certificate_descriptions cd where certificate_code = '104'
and certificate_type_code = '9';

select distinct country_prefix from roo.rules_of_origin roo;


select * from roo.rules where heading is null;

select 
case
	when "scope" = 'xi' and country_prefix in ('japan', 'south-korea', 'turkey') then 'xi'
	when "scope" = 'xi' and country_prefix not in ('japan', 'south-korea', 'turkey') then 'both'
	else 'uk'
end as "scope",
id_rule, country_prefix as scheme_code, heading,
description,
quota_amount, quota_unit,
rule,
alternate_rule
from roo.rules
order by "scope" desc, country_prefix, id_rule


select id,
case
	when "scope" = 'xi' and country_prefix in ('japan', 'south-korea', 'turkey') then 'xi'
	when "scope" = 'xi' and country_prefix not in ('japan', 'south-korea', 'turkey') then 'both'
	else 'uk'
end as "scope",
country_prefix as scheme_code, id_rule, sub_heading 
from roo.rules_to_commodities rtc
order by 2, 3, 5, 4


select * from roo.rules r where heading like '3505%' and country_prefix like 'south%'

-- ROEIFC - Goods from Turkey
select left(goods_nomenclature_item_id, 2), count(*)
from utils.materialized_measures_real_end_dates m
where measure_type_id = '475' and geographical_area_id = 'TR'
and validity_end_date is null
group by left(goods_nomenclature_item_id, 2);

select m.goods_nomenclature_item_id, mc.description 
from utils.materialized_measures_real_end_dates m, utils.materialized_commodities mc 
where measure_type_id = '475' and geographical_area_id = 'TR'
and m.goods_nomenclature_sid = mc.goods_nomenclature_sid 
and validity_end_date is null
order by 1

select * from measure_type_descriptions mtd
where description ilike '%waste%'
order by 1;

refresh materialized view utils.materialized_commodities;

select count (distinct additional_code) from meursing_additional_codes mac 

select * from measure_type_descriptions mtd order by 1;

select * from utils.materialized_measures_real_end_dates m
where goods_nomenclature_item_id like '7606%'
and measure_type_id = '119'
and validity_end_date is null;

select id_rule, * from roo.rules roo where description like '%issing%'

select distinct country_prefix 
from roo.rules_to_commodities rtc where id_rule is null;


select count(*)
from roo.rules_to_commodities rtc where id_rule is null;

delete from roo.rules_to_commodities where id_rule is null

select *
from roo.rules r 
where id_rule is null;

select distinct country_code, country_prefix, scope
from roo.rules order by 1, 2;

select * from quota_balance_events qbe where quota_definition_sid = 20207;

select * from quota_definitions qd where quota_order_number_id = '058866';


with cte as (
	select m.goods_nomenclature_item_id, (mc.certificate_type_code || mc.certificate_code) as code,
	m.geographical_area_id, m.additional_code_sid, count(mc.measure_condition_sid)
	from utils.materialized_measures_real_end_dates m, measure_conditions mc, measure_types mt 
	where m.measure_sid = mc.measure_sid 
	and m.measure_type_id = mt.measure_type_id 
	and (m.validity_end_date is null or m.validity_end_date::date > current_date)
	and mc.certificate_code is not null
	and mt.measure_type_series_id in ('A', 'B')
	and mt.trade_movement_code != 1
	group by m.goods_nomenclature_item_id, mc.certificate_type_code, certificate_code, m.geographical_area_id, m.additional_code_sid 
	order by 5 desc
) select * from cte where count > 1;


with cte as (
	select m.goods_nomenclature_item_id, (mc.certificate_type_code || mc.certificate_code) as code,
	case
		when m.geographical_area_id in ('1008', '1011') then 'Whole world'
		else m.geographical_area_id
	end as geographical_area_id,
m.additional_code_sid, count(mc.measure_condition_sid)
	from utils.materialized_measures_real_end_dates m, measure_conditions mc, measure_types mt 
	where m.measure_sid = mc.measure_sid 
	and m.measure_type_id = mt.measure_type_id 
	and (m.validity_end_date is null or m.validity_end_date::date > current_date)
	and m.validity_start_date::date <= current_date 
	and mc.certificate_code is not null
	and mt.measure_type_series_id in ('A', 'B')
	and m.measure_type_id not in ('410', '755')
	and mt.trade_movement_code != 1
	and m.goods_nomenclature_item_id = '1302130010'
	group by m.goods_nomenclature_item_id, mc.certificate_type_code, certificate_code, m.geographical_area_id, m.additional_code_sid 
	order by 5 desc
)
select distinct goods_nomenclature_item_id, code
from cte where count > 1
order by 1;



select m.goods_nomenclature_item_id, (mc.certificate_type_code || mc.certificate_code) as code,
case
	when m.geographical_area_id in ('1008', '1011') then 'Whole world'
		else m.geographical_area_id
	end as geographical_area_id,
m.additional_code_sid, mc.measure_condition_sid 
from utils.materialized_measures_real_end_dates m, measure_conditions mc, measure_types mt 
where m.measure_sid = mc.measure_sid 
and m.measure_type_id = mt.measure_type_id 
and (m.validity_end_date is null or m.validity_end_date::date > current_date)
and m.validity_start_date::date <= current_date 
and mc.certificate_code is not null
and mt.measure_type_series_id in ('A', 'B')
and m.measure_type_id not in ('410', '755')
and mt.trade_movement_code != 1
--and m.goods_nomenclature_item_id = '1302130010'
order by 1;


with cte as (
	select goods_nomenclature_item_id, code,
		geographical_area_id,
	additional_code_sid, count(measure_condition_sid) as condition_count
	from utils.temp_for_chieg tfc
	group by goods_nomenclature_item_id, code, geographical_area_id, additional_code_sid
)
select * from cte where condition_count > 1
order by 1;



select m.goods_nomenclature_item_id, (mc.certificate_type_code || mc.certificate_code) as code,
	m.geographical_area_id, m.additional_code_sid, m.measure_sid, m.validity_start_date, m.validity_end_date, m.measure_type_id 
	from utils.materialized_measures_real_end_dates m, measure_conditions mc, measure_types mt 
	where m.measure_sid = mc.measure_sid 
	and m.measure_type_id = mt.measure_type_id 
	and (m.validity_end_date is null or m.validity_end_date::date > current_date)
	and m.validity_start_date::date <= current_date 
	and mc.certificate_code is not null
	and mt.measure_type_series_id in ('A', 'B')
	and m.measure_type_id not in ('410', '755')
	and mt.trade_movement_code != 1
	and m.goods_nomenclature_item_id = '0100000000'
	
select * from measure_type_descriptions mtd where measure_type_id = '750';
