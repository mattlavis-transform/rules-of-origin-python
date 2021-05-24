from classes.table_cell import TableCell
import docx
import json
import sys
import os
import shutil

class RooDocument(object):
    def __init__(self):
        self.get_paths()
        self.get_args()

    def get_paths(self):
        path = os.getcwd()
        self.path_resources = os.path.join(path, "resources")
        self.path_source = os.path.join(self.path_resources, "source")
        self.path_dest = os.path.join(self.path_resources, "dest")

    
    def get_args(self):
        if len(sys.argv) < 3:
            print("Please specify a source file and the name of the agreement")
            sys.exit()
        else:
            filename = sys.argv[1]
            self.agreement = sys.argv[2]
            self.source = os.path.join(self.path_source, filename + ".docx")
            self.dest = os.path.join(self.path_dest, self.agreement + ".json")
    
    def create(self):
        self.document = docx.Document(self.source)
        table = self.document.tables[0]
        table_cells = []
        table_cells2 = []

        keys = None
        for i, row in enumerate(table.rows):
            table_cell = TableCell()
            table_cell.cell1 = row.cells[0].text
            table_cell.cell2 = row.cells[1].text
            table_cell.parse()
            if table_cell.valid:
                del table_cell.valid
                table_cells.append(table_cell)

        # Sort the rules by low code
        table_cells.sort(key=lambda x: x.code_low, reverse=False)

        # Fill in the missing code_high values
        for i in range(0, len(table_cells) - 1):
            tc = table_cells[i]
            tc2 = table_cells[i + 1]
            if tc.code_high is None:
                tc.code_high = str(int(tc2.code_low) - 1).ljust(10, "0")

        # Create the JSON object
        for tc in table_cells:
            table_cells2.append(tc.__dict__)


        json_string = json.dumps(table_cells2, indent=2)
        f = open(self.dest, "w+")
        f.write(json_string)
        f.close()

        shutil.copy(self.dest, "/Users/matt.admin/sites and projects/1. Online Tariff/ott prototype/app/data/roo/eu.json")
