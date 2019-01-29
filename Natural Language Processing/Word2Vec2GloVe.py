
#import required 
import os
import argparse
from gensim.models import KeyedVectors

def changeFormat():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('-w','--word2vec',type = str, required = True, help='Word2Vec Model')
    args = parser.parse_args()

    intermediate_storage = ".intermediate.txt"
    changedFormatFileName = args.word2vec
    