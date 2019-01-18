import simplejson
import sys
from HTMLParser import HTMLParser

program_name = sys.argv[0]
arguments = sys.argv[1:]
count = len(arguments)

class TagStripper(HTMLParser):
    def __init__(self):
        self.reset()
        self.fed = []
    def handle_data(self, d):
        self.fed.append(d)
    def get_data(self):
        return ''.join(self.fed)

def strip_tags(html):
    s = TagStripper()
    s.feed(html)
    return s.get_data()

#read input for each file
#maybe change it to accept files on argument basis

f = open(arguments[0], 'r')
text = f.read()
f.close()
parsed_output = strip_tags(text)

f = open(arguments[0], 'w')
f.write(parsed_output)
f.close()

with open(arguments[0]) as f:
   text = ''.join(line.strip() for line in f)

f = open(arguments[0], 'w')
f.write(text)
f.close()


