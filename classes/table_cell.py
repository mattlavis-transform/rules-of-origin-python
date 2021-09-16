import sys
import re
from classes.lookup import Lookup
from classes.database import Database


class TableCell(object):
    def __init__(self, id, fetch_descriptions):
        self.id = id
        self.fetch_descriptions = fetch_descriptions
        self.cell_classification = None
        self.cell_description = None
        self.cell_specific = None
        self.description = None
        self.cell_psr = None
        self.cell_psr_original = None
        self.rule_of_origin = None
        self.key_first = None
        self.key_last = None
        self.valid = False
        self.product_specific_rules = []
        self.lookup = Lookup().lookup

    def parse(self):
        self.parse_cell_classification()
        if self.fetch_descriptions:
            self.parse_description()
    
    def parse_description(self):
        if self.cell_description == "":
            self.cell_description = self.cell_classification
            
        if self.cell_description != "":
            parts = self.cell_description.split("\n")
            self.description = ""
            for part in parts:
                if (len(part) > 0):
                    part = part.replace(".", "").strip()
                    goods_nomenclature_item_id = part + ("0" * (10 - len(part)))
                    part = part.replace("ex.", "ex")
                    if "ex" in part.lower():
                        is_ex = True
                        ex_string = "ex. "
                    else:
                        is_ex = False
                        ex_string = ""
                    
                    part = part.replace("ex", "").strip()
                        
                    if "Chapter" in part: # Chapter
                        goods_nomenclature_item_id = part.replace("Chapter", ""). strip().zfill(2) + "00000000"
                        identifier = self.cell_description

                    elif len(part) == 4: # Heading
                        identifier = ex_string + "Heading " + part
                    elif len(part) == 6: # Subheading
                        identifier = ex_string + part[0:4] + "." + part[-2:]
                        a = 1
                    else:
                        identifier = ""
                        
                    self.description += identifier + ": " + self.get_goods_nomenclature_description(goods_nomenclature_item_id)
                    if self.cell_specific != "":
                        self.description += "\n" + self.cell_specific.strip(":")
                    self.description += "\n"
                    a = 1
            
            self.description = self.description.strip("\n")

    def get_goods_nomenclature_description(self, goods_nomenclature_item_id):
        description = "Missing description"
        d = Database()
        sql = """
        select gnd.description, gnd.productline_suffix
        from goods_nomenclature_descriptions gnd, goods_nomenclature_description_periods gndp 
        where gnd.goods_nomenclature_sid = gndp.goods_nomenclature_sid 
        and gnd.goods_nomenclature_item_id = %s
        order by gnd.productline_suffix, gndp.validity_start_date
        limit 1;
        """
        params = [
            goods_nomenclature_item_id
        ]
        rows = d.run_query(sql, params)
        if len(rows) > 0:
            description = rows[0][0].capitalize()

        return description

    def parse_cell_classification(self):
        if "Column 1" in self.cell_classification or "SECTION" in self.cell_classification or "Chapter" in self.cell_classification:
            self.valid = False
        else:
            self.valid = True
            self.set_commodity_range()
        if self.valid:
            self.parse_cell_psr()

    def remove_unnecessary_fields(self):
        self.heading = self.cell_classification

        del self.product_specific_rules
        del self.cell_classification
        del self.cell_description
        del self.cell_psr
        del self.fetch_descriptions
        del self.cell_specific
        del self.cell_psr_original
        del self.lookup

    def set_commodity_range(self):
        # Check for hyphens - if there is a hyphen, then there is a range already
        if "-" in self.cell_classification:
            parts = self.cell_classification.split("-")
            if len(parts) == 2:
                for i in range(0, 2):
                    parts[i] = parts[i].strip()
                    parts[i] = parts[i].replace(".", "")
                    parts[i] = parts[i].replace(" ", "")

                parts[0] += "0" * (10 - len(parts[0]))
                parts[1] += "9" * (10 - len(parts[1]))

                self.key_first = parts[0]
                self.key_last = parts[1]
                self.validity_start_date = "2021-01-01"
                self.validity_end_date = None
                a = 1
            else:
                single_part = True
            hyphen = True
        else:
            a = 1
            self.cell_classification = self.cell_classification.strip()
            self.cell_classification = self.cell_classification.replace(".", "")
            self.cell_classification = self.cell_classification.replace(" ", "")
            self.key_first = self.cell_classification
            self.key_first += "0" * (10 - len(self.key_first))
            self.key_last = None
        print("Classification:", self.cell_classification, "First key:", self.key_first, "Last key:", self.key_last)
        
    def write_to_db(self):
        d = Database()
        sql = """
        insert into roo.rules
        (
            scope,
            country_code,
            country_prefix,
            heading,
            description,
            key_first,
            key_last,
            id_rule,
            rule
        ) values (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        params = [
            "uk",
            "eu",
            "eu",
            self.heading,
            self.description,
            self.key_first,
            self.key_last,
            self.id,
            self.rule_of_origin
        ]
        d.run_query(sql, params)

    def parse_cell_psr(self):
        self.cell_psr = self.cell_psr.replace("\t", " ")
        # self.cell_psr = re.sub("\s+", " ", self.cell_psr)
        self.cell_psr = self.cell_psr.replace(" %", "%")
        self.cell_psr = self.cell_psr.replace("; and\n", " _and_\n")
        self.cell_psr_original = self.cell_psr

        self.rule_of_origin = self.cell_psr

        self.get_product_specific_rules()

    def get_product_specific_rules(self):
        self.product_specific_rules = self.cell_psr_original.split(";")
        terms = ["CTH", "CTSH", "CC"]
        for i in range(len(self.product_specific_rules)):
            for term in terms:
                self.product_specific_rules[i] = self.product_specific_rules[i].replace(
                    term, self.lookup[term])
                self.product_specific_rules[i] = self.product_specific_rules[i].strip()
                self.product_specific_rules[i] = re.sub(r'^or', ' ', self.product_specific_rules[i])
                self.product_specific_rules[i] = re.sub(r'MaxNOM ([0-9]{1,3})%', 'The maximum value of non-originating materials (MaxNOM) is no more than \\1%', self.product_specific_rules[i])

class Rule(object):
    def __init__(self, row = None):
        if row is None:
            self.sub_heading = None
            self.heading = None
            self.description = None
            self.rule = None
            self.alternate_rule = None
            self.quota_amount = None
            self.quota_unit = None
            self.key_first = None
            self.key_last = None
        else:
            self.sub_heading = row[0]
            self.heading = row[1]
            self.description = row[2]
            self.rule = row[3]
            self.alternate_rule = row[4]
            self.quota_amount = row[5]
            self.quota_unit = row[6]
            self.key_first = row[7]
            self.key_last = row[8]

    def equates_to(self, rule):
        equal = True
        if self.sub_heading != rule.sub_heading:
            equal = False
        elif self.heading != rule.heading:
            equal = False
        elif self.description != rule.description:
            equal = False
        elif self.description != rule.description:
            equal = False
        elif self.rule != rule.rule:
            equal = False
        elif self.alternate_rule != rule.alternate_rule:
            equal = False
        elif self.key_first != rule.key_first:
            equal = False
        elif self.key_last != rule.key_last:
            equal = False
        
        return equal
    
    def asdict(self):
        return {
            'sub_heading': self.sub_heading,
            'heading': self.heading,
            'description': self.description,
            'rule': self.rule,
            'alternate_rule': self.alternate_rule,
            'quota_amount': self.quota_amount,
            'quota_unit': self.quota_unit,
            'key_first': self.key_first,
            'key_last': self.key_last
        }
