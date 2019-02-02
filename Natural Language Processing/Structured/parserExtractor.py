from bs4 import BeautifulSoup as bs
from bs4 import NavigableString
from collections import namedtuple
import itertools

import pprint
import csv
import urllib
import re
import sys

program_name = sys.argv[0]
arguments = sys.argv[1:]
count = len(arguments)

# ## Defining the get table functions and supporting functions


def get_tables(soup, length):
    """
    Extracts each table on the page and places it in a dictionary.
    Converts each dictionary to a Table object. Returns a list of
    pointers to the respective Table object(s).
    """
    table_list = []
    for iterator in range(0, length):
        # Find the first <p> tag with the search text
        table_tag = soup.find("p", {"class": iterator})
        # Find the first <table> tag that follows it
        table = table_tag.findNext('table')
        # empty dictionary each time represents our table
        table_dict = {}
        rows = table.findAll("tr")
        # count will be the key for each list of values
        count = 0
        for row in rows:
            value_list = []
            entries = row.findAll("td")
            for entry in entries:
                # fix the encoding issues with utf-8
                entry = entry.text.encode("utf-8", "ignore")
                strip_unicode = re.compile(
                    "([^-_a-zA-Z0-9!@#%&=,/'\";:~`\$\^\*\(\)\+\[\]\.\{\}\|\?\<\>\\]+|[^\s]+)")
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


def append_classID(filepath):
    # Reading Files
    f = open(filepath, 'r')
    data = f.read()
    f.close()

    # Making soup
    soup = bs(data, "lxml")
    searchtext = "Credit Default"

    # Find the first <p> tag with the search text
    all_tags = []
    counter = 0
    all_tags = soup.find_all("p")
    lengthFoundText = len(all_tags)
    print("Number of p tags founds are: ", lengthFoundText)
    for i in range(lengthFoundText):
        if searchtext in all_tags[i].text:
            all_tags[i]['class'] = i
            counter += 1

    print("Number of CDS p tags founds are: ", counter)
    return soup, counter


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
            num_cols=num_cols,
            num_entries=num_entries
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


program_name = arguments[0]
print("making the soup.........")
soup, length = append_classID(program_name)
print("Soup is ready.........")
# get the tables
tables = get_tables(soup, length)
print("got the tables.......")
# save the tables
save_tables(tables)
print("tables saved.......")
