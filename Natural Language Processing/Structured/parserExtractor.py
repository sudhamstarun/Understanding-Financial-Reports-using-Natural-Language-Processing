from bs4 import BeautifulSoup as bs
from bs4 import NavigableString
from collections import namedtuple
import itertools

import pprint
import csv
import urllib
import re
import sys
import os
import time

# Reading in the arguments supplied to the program
program_name = sys.argv[0]
arguments = sys.argv[1:]
count = len(arguments)

# ## Defining the get table functions and supporting functions


def get_tables(soup, p_counter, div_counter):
    """
    Extracts each table on the page and places it in a dictionary.
    Converts each dictionary to a Table object. Returns a list of
    pointers to the respective Table object(s).
    """
    table_list = []
    print("The value of p_counter is: ",  p_counter)
    print("The value of div_counter is: ", div_counter)

    # Extracting tables after a certain p tag
    for iterator in range(1, p_counter+1):
        # Find the first <p> tag with the search text
        table_tag = soup.find("p", {"class": str(iterator)})
        # Find the first <table> tag that follows it
        table = table_tag.findNext("table")
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
                if entry.find("p"):
                    entry = entry.find(
                        "p").text.encode("utf-8", "ignore")
                    strip_unicode = re.compile(
                        "([^-_a-zA-Z0-9!@#%&=,/'\";:~`\$\^\*\(\)\+\[\]\.\{\}\|\?\<\>\\]+|[^\s]+)")
                    entry = entry.decode("utf-8")
                    entry = strip_unicode.sub(" ", entry)
                    value_list.append(entry)

                else:
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

        print("Number of p_tables done: ", iterator)

    # Extracting tables from the div tag

    for iterator in range(1, div_counter+1):
        # Find the first <p> tag with the search text
        table_tag = soup.find("div", {"class": str(iterator)})
        # Find the first <table> tag that follows it
        table = table_tag.findNext("table")
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

        print("Number of div_tables done: ", iterator)

    # Extracting tables from the page tag

    for iterator in range(1, page_counter):
        # Find the first <p> tag with the search text
        table_tag = soup.find("page", {"class": str(iterator)})
        # Find the first <table> tag that follows it
        table = table_tag.findNext("table")
        # empty dictionary each time represents our table
        div_dict = {}
        caption_text = table.findAll("caption")

        for captions in caption_text:
            print (captions.text)

        # if caption_text != None:
        """
        # else:
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
                div_dict[count] = value_list
                count += 1

        table_obj = Table(div_dict)
        table_list.append(table_obj)
        """
        print("Number of page_tables done: ", iterator)

    return table_list


def tag_closer(filepath):
    lines = []
    with open(filepath) as f:
        lines = f.readlines()

    ins_at = find_occurences_of('<PAGE>', lines)

    for i in ins_at:
        lines.insert(i, '</PAGE>')

    with open(filepath, 'w') as f:
        f.writelines(lines)


def find_occurences_of(needle, haystack):
    ret = []
    for i, line in enumerate(haystack):
        if line.startswith(needle):
            ret.append(i)
    return ret


def append_classID(filepath):
    """
    Append the classID to the p or div(or any tag found in future inspection)
    tags which contain the different ways of calling CDS and returning the respective
    tag counters for further processing
    """
    # Reading Files
    f = open(filepath, 'r')
    data = f.read()
    f.close()

    # Making soup
    soup = bs(data, "lxml")
    soup.prettify()
    # Adding multiple reporting styles used in reoprts to mention CDS information
    searchtext = ["Credit Default", "CDS Contract",
                  "Default Swap", "Default Contract", "Default Protection", "Credit Derivative", "credit default swap", "credit default"]

    searchtext_pageTable = {"NOTIONAL AMOUNT", "REFERENCE ENTITY"}

    p_counter = 0
    div_counter = 0
    page_counter = 0
    table_counter = 0

    # Find the first <p> tag with the search text
    all_p_tags = soup.find_all("p")
    all_div_tags = soup.find_all("div")
    all_page_tags = soup.findAll("page")

    # Renname all <page> tags to <div> since there is no such thing as a <page>

    plengthFoundText = len(all_p_tags)
    divlengthFoundText = len(all_div_tags)
    pagelengthFoundText = len(all_page_tags)

    print("Length of divLengthFoundtext is: ", divlengthFoundText)

    if pagelengthFoundText > 0:
        print("Length of pageTableLengthFoundtext is: ", pagelengthFoundText)
        all_table_tags = soup.findAll("table")
        tablelengthFoundText = len(all_table_tags)
        print("Length of tableLengthFoundtext is: ", tablelengthFoundText)

        for b in range(pagelengthFoundText):
            for a in range(len(searchtext)):
                if searchtext_pageTable[a] in all_page_tags[b].text:
                    page_counter += 1
                    all_page_tags[b]['class'] = page_counter
                    break

    if plengthFoundText > 0:
        print("Length of pLengthFoundtext is: ", plengthFoundText)
        for i in range(plengthFoundText):
            for k in range(len(searchtext)):
                if searchtext[k] in all_p_tags[i].text:
                    p_counter += 1
                    all_p_tags[i]['class'] = p_counter
                    break

    if divlengthFoundText > 0:
        print("Length of divLengthFoundtext is: ", divlengthFoundText)
        for j in range(divlengthFoundText):
            for l in range(len(searchtext)):
                if searchtext[l] in all_div_tags[j].text:
                    div_counter += 1
                    all_div_tags[j]['class'] = div_counter
                    break

    print("The value of p_counter is: ",  p_counter)
    print("The value of div_counter is: ", div_counter)
    print("The value of page_counter is: ", page_counter)

    return soup, p_counter, div_counter, table_counter


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

        mypath = arguments[0].strip(".txt")
        fname = name + ".csv"
        # Creating directory if it doesn't exist
        if not os.path.isdir(mypath):
            os.makedirs(mypath)
        fname = os.path.join(mypath, fname)
        with open(fname, 'w', encoding='utf8') as outf:
            w = csv.writer(outf, dialect="excel")
            li = self.table_data.values()
            w.writerows(li)

    def show_table(self):
        """
        Prints a formatted table to the command line using pprint
        """
        pprint.pprint(self.table_data, width=1)


# Initiate the start time of the program
start = time.time()

# Read the filepath
program_name = arguments[0]

# close <page> tag
tag_closer(program_name)
# Souping
print("making the soup.........")
soup, p_counter, div_counter = append_classID(program_name)
print(soup)
exit()
print("Soup is ready.........")

# get the tables
tables = get_tables(soup, p_counter, div_counter)
print("got the tables.......")

# save the tables
save_tables(tables)
print("tables saved.......")

# Printing time taken
end = time.time()
print("The total time taken for CDS tables extraction is: ", end - start, "s")
