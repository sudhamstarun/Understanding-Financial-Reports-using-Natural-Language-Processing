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




