import simplejson
from bs4 import BeautifulSoup

cleantext = BeautifulSoup(raw_html, "lxml").text

oneline_text = " ".join(line.strip() for line in cleantext) 

f = open('output.txt', 'w')
simplejson.dump(lol, f)
f.close