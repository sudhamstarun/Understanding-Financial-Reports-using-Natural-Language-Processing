#%% Change working directory from the workspace root to the ipynb file location. Turn this addition off with the DataScience.changeDirOnImportExport setting
import os
try:
	os.chdir(os.path.join(os.getcwd(), 'Natural Language Processing/Structured'))
	print(os.getcwd())
except:
	pass
#%% [markdown]
# ## Introduction
#%% [markdown]
# The aim is to extract all the possible tables from the structured and unstructured SEC filings with minimal use of RegEx and try to aggregate all the tables which may or may not contain CDS information. Once that is comepletely, filtering method should be in place which would filter out the tables which do not have Credit Default Swap information
#%% [markdown]
# ## Declaring libraries required to run our implementation

#%%
from bs4 import BeautifulSoup as bs
from bs4 import NavigableString
from collections import namedtuple
import itertools

import pprint
import csv
import urllib
import re
import sys

#%% [markdown]
# ## Defining the get table functions and supporting functions

#%%
def get_tables(soup):
    """
    Extracts each table on the page and places it in a dictionary.
    Converts each dictionary to a Table object. Returns a list of
    pointers to the respective Table object(s).
    """
    table_list = []

    for tag in soup.find_all("table"):
        if tag.previous_element == "p" or tag.previous_element == "b" and tag.previous_element.text == "Credit Default":
            print("Found CDS table boi")
            # empty dictionary each time represents our table
            table_dict = {}
            rows = tag.findAll("tr")
            # count will be the key for each list of values
            count = 0
            for row in rows:
                value_list = []
                entries = row.findAll("td")
                for entry in entries:
                    # fix the encoding issues with utf-8
                    entry = entry.text.encode("utf-8","ignore")
                    strip_unicode = re.compile("([^-_a-zA-Z0-9!@#%&=,/'\";:~`\$\^\*\(\)\+\[\]\.\{\}\|\?\<\>\\]+|[^\s]+)")
                    entry = entry.decode("utf-8")
                    entry = strip_unicode.sub(" ", entry)
                    value_list.append(entry)
                # we don't want empty data packages
                if len(value_list) > 0:
                    table_dict[count] = value_list
                    count += 1

            table_obj = Table(table_dict)
            table_list.append(table_obj)

    return table_list

def save_tables(tables):
    """
    Takes an input a list of table objects and saves each
    table to csv format.
    """
    counter = 1
    for table in tables:
        name = "table" + str(counter)
        table.save_table(name)
        counter += 1

#%% [markdown]
# ## Defining table function to get the table data and store it

#%%
Metadata = namedtuple("Metadata", "num_cols num_entries")

class Table:

    def __init__(self, data):
        """
        Stores a given table as a dictionary. The keys are the headings and the
        values are the data, represented as lists.
        """
        self.table_data = data

    def get_metadata(self):
        """
        Returns a Metadata object that contains the number of columns
        and the total number of entries.
        """

        col_headings = self.table_data.keys()
        num_cols = len(col_headings)
        num_entries = 0

        for heading in col_headings:
            num_entries += len(self.table_data[heading])

        return Metadata(
            num_cols = num_cols,
            num_entries = num_entries
        )

    def save_table(self, name):
        """
        Saves a table to csv format under the given file name.
        File name should omit the extension.
        """
        fname = name + ".csv"

        with open(fname, 'w', encoding='utf8') as outf:
            w = csv.writer(outf, dialect="excel")
            li = self.table_data.values()
            w.writerows(li)

    def show_table(self):
        """
        Prints a formatted table to the command line using pprint
        """
        pprint.pprint(self.table_data, width=1)

#%% [markdown]
# ## Driver Function

#%%
# enter the file we want
f = open("0001193125-17-056504 2.txt", 'r')
data = f.read()
f.close()

print("making the soup.........")
soup = bs(data,"lxml")
print("Soup is ready.........")
# get the tables

tables = get_tables(soup)
print("got the tables.......")

table_object = Table(tables)
table_object.show_table()
# save the tables
save_tables(tables)
print("tables saved.......")



#%%



