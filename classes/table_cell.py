import sys
import re
from classes.lookup import Lookup
from classes.database import Database


class TableCell(object):
    def __init__(self, id, fetch_descriptions, country_code, country_prefix, index):
        self.index = index
        self.id = id
        self.country_code = country_code
        self.country_prefix = country_prefix
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
        self.column_count = 0
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
                    goods_nomenclature_item_id = part.replace("ex.", "")
                    goods_nomenclature_item_id = goods_nomenclature_item_id.replace("ex", "")
                    goods_nomenclature_item_id = goods_nomenclature_item_id.replace(" ", "")
                    goods_nomenclature_item_id = goods_nomenclature_item_id + ("0" * (10 - len(goods_nomenclature_item_id)))
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
                        # identifier = ex_string + "Heading " + part
                        identifier = ex_string + part

                    elif len(part) == 6: # Subheading
                        identifier = ex_string + part[0:4] + "." + part[-2:]

                    else:
                        identifier = ""
                        
                    identifier = identifier.strip()
                    if identifier != "":
                        self.description += identifier + ": " + self.get_goods_nomenclature_description(goods_nomenclature_item_id) + "\n"
                    else:
                        self.description += self.get_goods_nomenclature_description(goods_nomenclature_item_id) + "\n"

                    if self.cell_specific != "":
                        self.cell_specific = self.cell_specific.replace("\u2013", "-")
                        self.description += "\n" + self.cell_specific.strip(":")
                        self.description = self.cell_specific.strip(":")

                    self.description += "\n"

            self.description = self.description.strip("\n")
            
    def get_chapter_extents(self):
        chapter = self.cell_classification.replace("Chapter", "")
        chapter = chapter.replace("ex", "")
        chapter = chapter.strip()
        chapter = chapter.rjust(2, "0")
        chapter_comm_code = chapter + "00000000"
        
        # Get the minimal heading
        sql = """
        select left(goods_nomenclature_item_id, 4) as min_heading
        from goods_nomenclatures gn
        where producline_suffix = '80'
        and left(goods_nomenclature_item_id, 2) = %s
        and goods_nomenclature_item_id != %s
        order by goods_nomenclature_item_id 
        limit 1;
        """
        d = Database()
        params = [
            chapter,
            chapter_comm_code
        ]
        rows = d.run_query(sql, params)
        if len(rows) > 0:
            self.key_first = rows[0][0] + "000000"
            
        # Get the maximal heading
        sql = """
        select left(goods_nomenclature_item_id, 4) as min_heading
        from goods_nomenclatures gn
        where producline_suffix = '80'
        and left(goods_nomenclature_item_id, 2) = %s
        and goods_nomenclature_item_id != %s
        order by goods_nomenclature_item_id desc
        limit 1;
        """
        d = Database()
        params = [
            chapter,
            chapter_comm_code
        ]
        rows = d.run_query(sql, params)
        if len(rows) > 0:
            self.key_last = rows[0][0] + "999999"

    def get_goods_nomenclature_description(self, goods_nomenclature_item_id):
        description = self.cell_classification # This used to say "Missing description"
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
        self.cell_classification = self.cell_classification.replace("to", "-")
        if "Column 1" in self.cell_classification or "SECTION" in self.cell_classification:
            self.valid = False
        else:
            self.valid = True
            self.set_commodity_range()
        if self.valid:
            self.parse_cell_psr()

    def remove_unnecessary_fields(self):
        self.heading = self.cell_classification

        del self.product_specific_rules
        # del self.cell_classification
        del self.cell_description
        del self.cell_psr
        del self.fetch_descriptions
        del self.cell_specific
        del self.cell_psr_original
        del self.lookup

    def set_commodity_range(self):
        # Check for hyphens - if there is a hyphen, then there is a range already
        if "Chapter" in self.cell_classification:
            self.get_chapter_extents()
            
        elif "-" in self.cell_classification:
            parts = self.cell_classification.split("-")
            if len(parts) == 2:
                for i in range(0, 2):
                    parts[i] = parts[i].strip()
                    parts[i] = parts[i].replace(".", "")
                    parts[i] = parts[i].replace(" ", "")
                    parts[i] = parts[i].replace("ex", "")

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
            self.cell_classification = self.cell_classification.strip()
            self.cell_classification = self.cell_classification.replace(".", "")
            self.cell_classification = self.cell_classification.replace(" ", "")
            self.cell_classification = self.cell_classification.replace("ex.", "")
            self.cell_classification = self.cell_classification.replace("ex", "")
            self.key_first = self.cell_classification
            self.key_first += "0" * (10 - len(self.key_first))
            self.key_last = None
            
            if self.key_first[-6:] == "000000":
                self.key_last = self.key_first[0:4] + "999999"
            elif self.key_first[-4:] == "0000":
                self.key_last = self.key_first[0:6] + "9999"

        if "84.25" in self.cell_classification:
            a = 1
        print(self.mstr(self.index, 4), self.mstr(self.column_count, 3), "Classification:", self.mstr(self.cell_classification, 20), "Key first:", self.mstr(self.key_first, 20), "Key last:", self.mstr(self.key_last, 20))
        a = 1
        
    def mstr(self, s, count = None):
        if s is None:
            s = ""
        else:
            s = str(s)
            s = s.strip()
            
        if count is None:
            return s
        else:
            return s.ljust(count)
        
    def write_table_cell_to_db(self):
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
            self.country_code,
            self.country_prefix,
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
        self.cell_psr = self.cell_psr.replace(" %", "%")
        self.cell_psr = self.cell_psr.replace("; and\n", " _and_\n")
        self.cell_psr_original = self.cell_psr
        
        # Get rid of footnote references
        self.cell_psr = re.sub(r'\([0-9]{1,3}\)', " ", self.cell_psr)

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

    def pick_out_key_terms(self):
        # EXW
        if "EXW" in self.rule_of_origin:
            self.rule_of_origin += "{{EXW}}"
            
        # Max NOM
        if "MaxNOM" in self.rule_of_origin:
            self.rule_of_origin = self.rule_of_origin.replace("MaxNOM", "Maximum of non-originating materials - MaxNOM")
            
        # CC
        if "CC" in self.rule_of_origin:
            self.rule_of_origin = self.rule_of_origin.replace("CC", "Change of chapter - CC")
            self.rule_of_origin += "{{CC}}"
            
        # For Canada - CTH
        if "A change from any other heading" in self.rule_of_origin:
            self.rule_of_origin = self.rule_of_origin.replace("A change from any other heading", "A change from any other heading - CTH")
            self.rule_of_origin += "{{CTH}}"
            
        # For Japan - CTH
        elif "CTH" in self.rule_of_origin:
            self.rule_of_origin = self.rule_of_origin.replace("CTH", "A change from any other heading  - CTH")
            self.rule_of_origin += "{{CTH}}"

        # For Canada - CTSH
        if "A change from any other subheading" in self.rule_of_origin:
            self.rule_of_origin = self.rule_of_origin.replace("A change from any other subheading", "A change from any other subheading - CTSH")
            self.rule_of_origin += "{{CTSH}}"
            
        # For Japan - CTSH
        elif "CTSH" in self.rule_of_origin:
            self.rule_of_origin = self.rule_of_origin.replace("CTSH", "A change from any other subheading - CTSH")
            self.rule_of_origin += "{{CTSH}}"

        # For Japan - RVC
        if "RVC" in self.rule_of_origin:
            self.rule_of_origin = self.rule_of_origin.replace("RVC", "Regional Value Content - RVC")
            
        if "wholly obtained" in self.rule_of_origin:
            self.rule_of_origin += "{{WO}}"

        # if self.rules[i]["quota"]["amount"] != None:
        #     self.rules[i]["description_string"] = self.rules[i]["description_string"] + "{{RELAX}}"

        self.rule_of_origin = self.rule_of_origin.replace(" ;", ";")
        self.rule_of_origin = self.rule_of_origin.replace("; ", ";\n\n")


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
            self.id_rule = None
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
            self.id_rule = row[9]

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
            'key_last': self.key_last,
            'id_rule': self.id_rule
        }
