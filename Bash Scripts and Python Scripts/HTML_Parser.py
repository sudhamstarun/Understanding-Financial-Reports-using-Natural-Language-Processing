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
        html1 = re.sub(r' style=".*?"', ' ', self.text)
        html2 = re.sub(r'<br>', ' ', html1)
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
                text = (str(tag)
                        if isinstance(tag, NavigableString)
                        else tag.get_text())
                if not text.endswith('\n'):
                    text += ' '
                f1.write(text.encode())

        with open('document.txt', 'rb') as f1:
            document_txt = f1.read().decode()


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



