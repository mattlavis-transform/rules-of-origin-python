import sys
import re
from classes.lookup import Lookup


class TableCell(object):
    def __init__(self):
        self.cell1 = None
        self.cell2 = None
        self.cell2_original = None
        self.rule_of_origin = None
        self.code_low = None
        self.code_high = None
        self.valid = False
        self.product_specific_rules = []
        self.lookup = Lookup().lookup

    def parse(self):
        self.parse_cell1()
        pass

    def parse_cell1(self):
        if "Column 1" in self.cell1 or "SECTION" in self.cell1 or "Chapter" in self.cell1:
            self.valid = False
        else:
            self.valid = True
            self.set_commodity_range()
        if self.valid:
            self.parse_cell2()

        self.reduce()

    def reduce(self):
        del self.cell1
        del self.cell2
        del self.cell2_original
        del self.lookup

    def set_commodity_range(self):
        # Check for hyphens - if there is a hyphen, then there is a range already
        if "-" in self.cell1:
            parts = self.cell1.split("-")
            if len(parts) == 2:
                for i in range(0, 2):
                    parts[i] = parts[i].strip()
                    parts[i] = parts[i].replace(".", "")
                    parts[i] = parts[i].replace(" ", "")

                parts[0] += "0" * (10 - len(parts[0]))
                parts[1] += "9" * (10 - len(parts[1]))

                self.code_low = parts[0]
                self.code_high = parts[1]
                self.validity_start_date = "2021-01-01"
                self.validity_end_date = None
                a = 1
            else:
                single_part = True
            hyphen = True
        else:
            a = 1
            self.cell1 = self.cell1.strip()
            self.cell1 = self.cell1.replace(".", "")
            self.cell1 = self.cell1.replace(" ", "")
            self.code_low = self.cell1
            self.code_low += "0" * (10 - len(self.code_low))
            self.code_high = None
        print(self.code_low, self.code_high)
        pass

    def parse_cell2(self):
        self.cell2 = self.cell2.replace("\t", " ")
        # self.cell2 = re.sub("\s+", " ", self.cell2)
        self.cell2 = self.cell2.replace(" %", "%")
        self.cell2 = self.cell2.replace("; and\n", " _and_\n")
        self.cell2_original = self.cell2

        self.rule_of_origin = self.cell2

        self.get_product_specific_rules()

    def get_product_specific_rules(self):
        self.product_specific_rules = self.cell2_original.split(";")
        terms = ["CTH", "CTSH", "CC"]
        for i in range(len(self.product_specific_rules)):
            for term in terms:
                self.product_specific_rules[i] = self.product_specific_rules[i].replace(
                    term, self.lookup[term])
                self.product_specific_rules[i] = self.product_specific_rules[i].strip()
                self.product_specific_rules[i] = re.sub(r'^or', ' ', self.product_specific_rules[i])
                self.product_specific_rules[i] = re.sub(r'MaxNOM ([0-9]{1,3})%', 'The maximum value of non-originating materials (MaxNOM) is no more than \\1%', self.product_specific_rules[i])
