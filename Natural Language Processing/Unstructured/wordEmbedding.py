# %% Change working directory from the workspace root to the ipynb file location. Turn this addition off with the DataScience.changeDirOnImportExport setting
import os
try:
    os.chdir(os.path.join(os.getcwd(), 'Natural Language Processing/Unstructured'))
    print(os.getcwd())
except:
    pass
# %% [markdown]
# ## Importing all the required libraries

# %%
import pandas
import numpy
import gensim
import logging
import sys
import os
import nltk
import re
import string
import unicodedata
import multiprocessing
import tensorflow as tf

from time import time  # To time our operations
from gensim.models import Word2Vec
from gensim.utils import simple_preprocess
from tensorflow.contrib.tensorboard.plugins import projector

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


# Checking tensorflow installation
print('TensorFlow version: \t%s' % tf.__version__)

# %% [markdown]
# ## Defining directories for reading text files and saving checkpoints

# %%
# For displaying gensim logs
logging.basicConfig(format='%(levelname)s : %(message)s', level=logging.INFO)

# Directory with raw txt-files
TEXT_DIR = 'Train/'

# Directory for saving checkpoint and metadata
MODEL_DIR = 'Checkpoints/'

# Word2vec
EMBEDDING_SIZE = 300

# %% [markdown]
# ## Reading all the text files in the corpus and tokeniztion

# %%


def read_files(path):
    """
    Read in text files
    """
    documents = list()
    def tokenize(x): return simple_preprocess(x)

    # Read in all files in directory
    if os.path.isdir(path):
        for filename in os.listdir(path):
            with open('%s/%s' % (path, filename), encoding='utf-8') as f:
                doc = f.read()
                doc = clean_doc(doc)
                documents.append(tokenize(doc))
    return documents


def clean_doc(doc):
    """
    Cleaning a document by several methods
    """
    # Lowercase
    doc = doc.lower()
    # Remove numbers
    doc = re.sub(r"[0-9]+", "", doc)
    # Split in tokens
    tokens = doc.split()
    # Remove punctuation
    tokens = [w.translate(str.maketrans('', '', string.punctuation))
              for w in tokens]
    # Tokens with less then two characters will be ignored
    tokens = [word for word in tokens if len(word) > 1]
    return ' '.join(tokens)


# %%
docs = read_files(TEXT_DIR)
print('Number of documents: %i' % len(docs))

# %% [markdown]
# ## Building and training our Word2Vec model
# %% [markdown]
# Listing the necessary hyperparameteres to tunr our word2Vec model

# %%
cores = multiprocessing.cpu_count()  # Count the number of cores in a computer

# %% [markdown]
# Now defining and training our Word2Vec model

# %%
model = gensim.models.Word2Vec(docs, size=EMBEDDING_SIZE)

# %% [markdown]
# Let's save our trained model as a checkpoint

# %%
if not os.path.exists(MODEL_DIR):
    os.makedirs(MODEL_DIR)
model.save(os.path.join(MODEL_DIR, 'word2vec'))

# %% [markdown]
# Creating metadata and checkpoint

# %%
weights = model.wv.vectors
index_words = model.wv.index2word

vocab_size = weights.shape[0]
embedding_dim = weights.shape[1]

print('Shape of weights:', weights.shape)
print('Vocabulary size: %i' % vocab_size)
print('Embedding size: %i' % embedding_dim)

with open(os.path.join(MODEL_DIR, 'metadata.tsv'), 'w') as f:
    f.writelines("\n".join(index_words))

# Required if you re-run without restarting the kernel
tf.reset_default_graph()

W = tf.Variable(tf.constant(
    0.0, shape=[vocab_size, embedding_dim]), trainable=False, name="W")
embedding_placeholder = tf.placeholder(tf.float32, [vocab_size, embedding_dim])

embedding_init = W.assign(embedding_placeholder)
writer = tf.summary.FileWriter(MODEL_DIR, graph=tf.get_default_graph())
saver = tf.train.Saver()

config = projector.ProjectorConfig()
embedding = config.embeddings.add()
embedding.tensor_name = W.name
embedding.metadata_path = './metadata.tsv'
projector.visualize_embeddings(writer, config)

with tf.Session() as sess:
    sess.run(embedding_init, feed_dict={embedding_placeholder: weights})
    save_path = saver.save(sess, os.path.join(MODEL_DIR, "model.cpkt"))


# %%
model.wv.most_similar(positive=['notional'], topn=10)
