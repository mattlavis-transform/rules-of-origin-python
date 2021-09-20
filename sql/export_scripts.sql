-- Script for extracting the rules into a single file

/*
Where the scope in the database is 'xi' and the country
is not japan, south korea or turkey, show as 'both', i.e. applicable to UK and XI

For the others, show as applicable to the individual country only
*/

select 
case
	when "scope" = 'xi' and country_prefix in ('japan', 'south-korea', 'turkey') then 'xi'
	when "scope" = 'xi' and country_prefix not in ('japan', 'south-korea', 'turkey') then 'both'
	else 'uk'
end as "scope",
id_rule, country_prefix, heading,
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