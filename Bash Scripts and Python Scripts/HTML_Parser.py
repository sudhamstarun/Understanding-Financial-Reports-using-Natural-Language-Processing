"""
import simplejson
import sys
import nltk
import sys 
import string

from HTMLParser import HTMLParser
from nltk.corpus import stopwords
from nltk.tokenize import sent_tokenize, word_tokenize

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
text = ' '.join(parsed_output.split())

#write the parsed output to the same document
f = open(arguments[0], 'w')
f.write(text)
f.close()

#open same file to remove stop words
f = open(arguments[0], 'r')
text = f.read()

tokenized = word_tokenize(text)
stop_words = set(stopwords.words('english'))

#tfidf = TfidfVectorizer(tokenizer=tokenize, stop_words='english')
#tfs = tfidf.fit_transform(token_dict.values())

filtered_sentence = [w for w in tokenized if not w in stop_words] 
filtered_sentence = [] 
  
for w in tokenized: 
    if w not in stop_words: 
        filtered_sentence.append(w) 
  
#print(tokenized) 
#print(filtered_sentence) 

final_text = ' '.join(filtered_sentence)

f = open('outputs.txt', 'w')
f.write(final_text)
f.close()
"""

"""
Parser for an SEC file format.
Outputs two documents: a 'document.txt' file
with the text information of the document
and a 'paragraphs.txt' file with the paragraphs
in the file that contain at least one '$' symbol.
"""

import json
import re
from bs4 import BeautifulSoup
from bs4.element import NavigableString
from sys import argv
from time import time   



class SECParser(object):
    def __init__(self, file):
        self.text = file.read()
        self.soup = None
        self.search_chars = 20

    def preprocess(self):
        """
        Two steps to preprocess the file:
        1) Style information takes up the majority of the text in the file; it can be
           removed using regular expressions before further processing takes place
        2) <br> tags will be replaced with '\n' so that text may be more uniformly
           extracted
        """
        html1 = re.sub(r' style=".*?"', '', self.text)
        html2 = re.sub(r'<br>', '', html1)
        self.soup = BeautifulSoup(html2,"lxml")

    def generate_document(self):
        """
        The plan for 'document.txt' is to iterate through the children tags in
        the body; getting the text content from them should be straightforward
        """
        if not self.soup:
            self.soup = BeautifulSoup(self.text,"lxml")
        body = self.soup.find('body')
        with open('document.txt', 'wb') as f1:
            for tag in body.children:
                text = (str(tag) if isinstance(tag, NavigableString) else tag.get_text())
                f1.write(text.encode())

        with open('document.txt', 'rb') as f1:
            document_txt = f1.read().decode()
            document_txt = i.rstrip('\n')
        
        with open('document.txt', 'wb') as f1:
            f1.write(i.rstrip('\n'))



if __name__ == '__main__':
    try:
        filename = argv[1]
    except IndexError:
        print('Usage: python3 sec_parser.py <filename>')
        print("fucked")
        exit(1)

    with open(filename) as file:
        parser = SECParser(file)

    t1 = time()
    parser.preprocess()
    parser.generate_document()  
    print('Finished in', time() - t1, 'secs')



