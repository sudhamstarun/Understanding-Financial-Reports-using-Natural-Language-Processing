import csv

with open('temp.txt') as input_file:
    lines = input_file.readlines()
    newLines = []
    for line in lines:
        newLine = line.strip().split()
        newLines.append(newLine)

with open('output.csv', 'wb') as test_file:
    file_writer = csv.writer(test_file)
    file_writer.writerows(newLines)
