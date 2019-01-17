import simplejson
import sys
from HTMLParser import HTMLParser

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

f = open('0001193125-17-056504 2.txt', 'r')
text = f.read()
parsed_output = strip_tags(text)

f = open('0001193125-17-056504 2.txt', 'w')
f.write(parsed_output)

#with open('0001193125-17-056504 2.txt') as f:
   # text = ' '.join(line.strip() for line in f)

# = open('0001193125-17-056504 2.txt', 'w')
#f.write(text)


