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

