import json
import sys
import os
import shutil
import requests
from classes.database import Database


class FlagList(object):
    def __init__(self):
        self.flag_path = os.getcwd()
        self.flag_path = os.path.join(self.flag_path, "resources", "flags")
        self.get_countries()
        self.get_flags()
        
    def get_countries(self):
        d = Database()
        sql = """
        select geographical_area_id
        from geographical_areas ga
        where validity_end_date is null
        and geographical_code != '1' order by 1;
        """
        self.countries = d.run_query(sql)

    def get_flags(self):
        for item in self.countries:
            country = item[0].lower()
            print("Getting {}".format(country.upper()))
            url = "https://flagcdn.com/h40/{{x}}.png".replace("{{x}}", country)
            response = requests.get(url)
            if response.status_code != 404:
                path = os.path.join(self.flag_path, country + ".png")
                file = open(path, "wb")
                file.write(response.content)
                file.close()    