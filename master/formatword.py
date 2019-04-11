import csv
import sys

my_file_name =sys.argv[1]
cleaned_file =sys.argv[2]
remove_words = ['Total','TOTAL']

with open(my_file_name, 'r', newline='') as infile, \
     open(cleaned_file, 'w',newline='') as outfile:
    writer = csv.writer(outfile)
    for line in csv.reader(infile, delimiter=','):
        if not any(remove_word in element
                      for element in line
                      for remove_word in remove_words):
            writer.writerow(line)
