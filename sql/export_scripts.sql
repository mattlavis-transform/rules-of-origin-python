-- Script for extracting the rules into a single file

/*
Where the scope in the database is 'xi' and the country
is not eu, japan, south korea or turkey, show as 'both', i.e. applicable to UK and XI

For the others, show as applicable to the individual country only
*/

select 
case
	when "scope" = 'xi' and lower(country_prefix) in ('japan', 'south-korea', 'turkey', 'eu') then 'xi'
	when "scope" = 'xi' and lower(country_prefix) not in ('japan', 'south-korea', 'turkey', 'eu') then 'both'
	else 'uk'
end as "scope",
id_rule, country_prefix as scheme_code, heading,
description,
quota_amount, quota_unit,
rule,
alternate_rule
from roo.rules
order by "scope" desc, country_prefix, id_rule;

-- To query on the above
with cte as (
...
)
select distinct(country_prefix) from cte where scope = 'both';


-- Script for extracting the rules to commodities into a single file

select id,
case
	when "scope" = 'xi' and lower(country_prefix) in ('japan', 'south-korea', 'turkey', 'eu', 'gb') then 'xi'
	when "scope" = 'xi' and lower(country_prefix) not in ('japan', 'south-korea', 'turkey', 'eu', 'gb') then 'both'
	else 'uk'
end as "scope",
country_prefix as scheme_code, id_rule, sub_heading 
from roo.rules_to_commodities rtc
order by 2, 3, 5, 4;


select m.*
from utils.materialized_measures_real_end_dates m, measure_types mt 
where mt.trade_movement_code = '1' and m.additional_code_type_id is not null
and m.measure_type_id = mt.measure_type_id 
and (m.validity_end_date is null or m.validity_end_date::date > current_date)
order by m.validity_end_date desc;

select * from measure_action_descriptions mad order by 1;

select * from utils.measures_real_end_dates m
where m.validity_start_date = '2022-01-01'
and measure_type_id in ('103', '142', '145', '143', '122', '123');




select * from utils.materialized_commodities  mc
where  description ilike '%meat%'



with certs as (
	select distinct on (cdp.validity_end_date, c.certificate_type_code, c.certificate_code)
	c.certificate_type_code, c.certificate_code, cd.description 
	from certificates c, certificate_descriptions cd, certificate_description_periods cdp 
	where c.certificate_type_code = cd.certificate_type_code 
	and c.certificate_code = cd.certificate_code 
	and c.certificate_type_code = cdp.certificate_type_code 
	and c.certificate_code = cdp.certificate_code 
	order by cdp.validity_end_date desc, c.certificate_type_code, c.certificate_code
)
select c.certificate_type_code, c.certificate_code, c.description, count(m.*)
from utils.materialized_measures_real_end_dates m, measure_conditions mc, certs c
where m.validity_end_date is null 
and m.measure_sid = mc.measure_sid 
and c.certificate_type_code = mc.certificate_type_code 
and c.certificate_code = mc.certificate_code
and c.certificate_type_code != 'Y'
group by c.certificate_type_code, c.certificate_code, c.description
order by c.certificate_type_code, c.certificate_code


select * from goods_nomenclatures where goods_nomenclature_item_id = '3808940000';

select * from utils.measures_real_end_dates m
where goods_nomenclature_item_id like '0702%'
and measure_type_id = '103'
order by validity_start_date desc;

select * from measurement_units_oplog
order by operation_date desc;

select * from measurement_unit_qualifiers muq 
order by operation_date desc;

select mc.measurement_unit_code, mc.measurement_unit_qualifier_code, *
from utils.materialized_measures_real_end_dates m, measure_components mc
where goods_nomenclature_item_id like '2203%'
and m.measure_sid = mc.measure_sid 
order by 1, 2, m.validity_start_date desc;

select * from measurement_units mu 

select * from measure_components mc where measurement_unit_code = 'FC1X';

select * from measure_conditions where measure_condition_sid = -574015;

select * from measure_type_descriptions mtd where measure_type_id like 'DD%'

select * from goods_nomenclature_descriptions gnd order by length(description) desc limit 10;





