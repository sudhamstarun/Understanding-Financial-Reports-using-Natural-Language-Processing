import os

try:
	os.chdir(os.path.join(os.getcwd(), 'Natural Language Processing/Unstructured'))
	print(os.getcwd())
except:
	pass

#%%
import pandas 
import numpy
import glob
import gensim
import logging
import sys, os
import nltk
import inflect
import itertools
import re, string, unicodedata
import multiprocessing 

from nltk.tokenize import TweetTokenizer, sent_tokenize
from time import time  # To time our operations
from gensim.models import Word2Vec
from gensim.models import FastText
from gensim.models.phrases import Phraser, Phrases

# */site-packages is where your current session is running its python out of
site_path = ''
for path in sys.path:
    if 'site-packages' in path.split('/')[-1]:
        print(path)
        site_path = path
# search to see if gensim in installed packages
if len(site_path) > 0:
    if not 'gensim' in os.listdir(site_path):
        print('package not found')
    else:
        print('gensim installed')    

# ## Reading all the text files in the corpus and tokeniztion

def readCorpus(filename):
    with open(filename, 'rb') as f:
        line = f.read().decode('utf-8')
    return line


def normalize():
    final_words = []
    for filename in glob.glob('/home2/vvsaripalli/Final_Corpus_N-CSRS/*.txt'):
        print(filename)
        words = readCorpus(filename)
        final_words = ''.join(final_words) + words
    tokenizer_words = TweetTokenizer()
    tokens_sentences = [tokenizer_words.tokenize(t) for t in 
    nltk.sent_tokenize(final_words)]
    return final_words

data = normalize()

# ## Building and training our Word2Vec model
# Listing the necessary hyperparameteres to tunr our word2Vec model

cores = multiprocessing.cpu_count() # Count the number of cores in a computer



num_features = 200 # dimensions of each word embedding
min_word_count = 1 # this is not advisable but since we need to extract
# feature vector for each word we need to do this
num_workers = multiprocessing.cpu_count() # number of threads running in parallel
context_size = 7 # context window length
downsampling = 1e-3 # downsampling for very frequent words
seed = 1 # seed for random number generator to make results reproducible

# Now defining our Word2Vec model with the above declared hyperparameters

word2vec_ = Word2Vec(
    sg = 1, seed = seed,
    workers = num_workers,
    size = num_features,
    min_count = min_word_count,
    window = context_size,
    sample = downsampling
)

# It's important that we train our vocabulary first before training the model

word2vec_.build_vocab(data)

# Now training the Word2Vec model with the vocabulary generated above
word2vec_.train(data, total_examples = word2vec_.corpus_count, epochs = word2vec_.iter)

print(word2vec_.most_similar('credit'))

#%% [markdown]
# ### Iterate through the entire vocabulary

#%%
vocab = list(word2vec_.wv.vocab.keys())
vocab[:100]


