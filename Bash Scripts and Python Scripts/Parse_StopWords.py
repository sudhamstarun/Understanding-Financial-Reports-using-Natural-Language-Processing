import nltk
import sys 
import string

#from sklearn.feature_extraction.text import TfidfVectorizer
from nltk.corpus import stopwords
from nltk.tokenize import sent_tokenize, word_tokenize

def tokenize(text):
    tokens = nltk.word_tokenize(text)
    stems = []
    for item in tokens:
        stems.append(PorterStemmer().stem(item))
    return stems

program_name = sys.argv[0]
arguments = sys.argv[1:]
count = len(arguments)

#read file
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
