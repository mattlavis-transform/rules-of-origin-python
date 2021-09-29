-- COPY ROO WHERE THE EU DATA IS IN THE OLD STYLE ONLY (classic)

-- Add 2 million for XI copies into the id_rule section

/* Create KENYA data

   This does the copy of Cote d'Ivoire rules for Kenya
   Needed for UK and XI, but that is dealt with in the multi-code export mechanism
 */

delete from roo.rules where scope = 'xi' and country_code = 'KE';
delete from roo.rules_to_commodities where scope = 'xi' and country_prefix = 'kenya';


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
