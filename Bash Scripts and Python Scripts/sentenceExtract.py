from nltk.tokenize import sent_tokenize
from nltk.tokenize import word_tokenize

# reading and tokenizing the file
f = open("test_data.json").read()
sentences = sent_tokenize(f)

# defining word list

word_list = ["Notional Amount", "notional amount",
             "reference entity", "expires", "due"]


def sentenceFinder(sentences, word_list):
    for word in word_list:
        my_sentence = [
            sent for sent in sentences if word in word_tokenize(sent)]

    return my_sentence


sentences = sentenceFinder(sentences, word_list)

# writing the output to the file
with open("output.txt", "w") as f:
    f.write(sentences)
