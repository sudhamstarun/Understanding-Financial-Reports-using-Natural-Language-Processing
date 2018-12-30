import requests
import httplib
import os
import sys
import errno
from bs4 import BeautifulSoup
from config import DEFAULT_DATA_PATH
import gzip
import time
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry

def requests_retry_session(retries=3, backoff_factor=0.3, status_forcelist=range (400, 600), session=None,):
    session = session or requests.Session()
    retry = Retry(
        total=retries,
        read=retries,
        connect=retries,
        backoff_factor=backoff_factor,
        status_forcelist=status_forcelist,
    )
    adapter = HTTPAdapter(max_retries=retry)
    session.mount('http://', adapter)
    session.mount('https://', adapter)
    return session

def get_data(base_url):
    flag = 1
    wait = 0
    retry = 3
    while flag:
      flag = 0
      try:
          r = requests_retry_session().get(base_url, timeout=5)
      except:
          pass
      try: r
      except NameError: r = None
      if r != None:
        if r.status_code != 200:
            print >> sys.stderr, "Status_code: %d" % (r.status_code)
            if r.status_code != 429:
                retry -= 1
            if retry:
                flag = 1
            wait += 10
            time.sleep(wait)
      else:
            retry -= 1
            if retry:
                flag = 1
            wait += 10
            time.sleep(wait)
    return r

class SecCrawler():

    def __init__(self):
        self.hello = "Don't worry, be happy!"
        print("The directory where data will be saved: " + DEFAULT_DATA_PATH)


    def make_directory(self, company_code, cik, priorto, filing_type):
        # Making the directory to save comapny filings
        path = os.path.join(DEFAULT_DATA_PATH, company_code, cik, filing_type)

        if not os.path.exists(path):
            try:
                os.makedirs(path)
            except OSError as exception:
                if exception.errno != errno.EEXIST:
                    raise


    def save_in_directory(self, company_code, cik, priorto, doc_list,
        doc_name_list, filing_type):
        # Save every text document into its respective folder

        if len(doc_list) > 0:
            try:
                self.make_directory(company_code,cik, priorto, filing_type)
            except Exception as e:
                print (str(e))

        for j in range(len(doc_list)):
            base_url = doc_list[j]
            r = get_data(base_url)
            data = r.text
            path = os.path.join(DEFAULT_DATA_PATH, company_code, cik,
                filing_type, doc_name_list[j])
            path += ".gz"

            with gzip.open(path, "wb", 3) as f:
                f.write(data.encode('ascii', 'ignore'))


    def filing_NCSR(self, company_code, cik, priorto, count):
        # generate the url to crawl
        base_url = "http://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK="+str(cik)+"&type=N-CSR&dateb="+str(priorto)+"&owner=exclude&output=xml&count="+str(count)

        print ("N-CSR: " + str(company_code))
        r = get_data(base_url)
        data = r.text

        # get doc list data
        doc_list, doc_name_list = self.create_document_list(data)

        try:
            self.save_in_directory(company_code, cik, priorto, doc_list, doc_name_list, 'N-CSR')
        except Exception as e:
            print (str(e))


    def filing_NCSRS(self, company_code, cik, priorto, count):
        # generate the url to crawl
        base_url = "http://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK="+str(cik)+"&type=N-CSRS&dateb="+str(priorto)+"&owner=exclude&output=xml&count="+str(count)

        print ("N-CSRS: " + str(company_code))
        r = get_data(base_url)
        data = r.text

        # get doc list data
        doc_list, doc_name_list = self.create_document_list(data)

        try:
            self.save_in_directory(company_code, cik, priorto, doc_list, doc_name_list, 'N-CSRS')
        except Exception as e:
            print (str(e))


    def filing_NQ(self, company_code, cik, priorto, count):
        # generate the url to crawl
        base_url = "http://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK="+str(cik)+"&type=N-Q&dateb="+str(priorto)+"&owner=exclude&output=xml&count="+str(count)

        print ("N-Q: " + str(company_code))
        r = get_data(base_url)
        data = r.text

        # get doc list data
        doc_list, doc_name_list = self.create_document_list(data)

        try:
            self.save_in_directory(company_code, cik, priorto, doc_list, doc_name_list, 'N-Q')
        except Exception as e:
            print (str(e))


    def create_document_list(self, data):
        # parse fetched data using beatifulsoup
        soup = BeautifulSoup(data)
        # store the link in the list
        link_list = list()

        # If the link is .htm convert it to .html
        for link in soup.find_all('filinghref'):
            url = link.string
            if link.string.split(".")[len(link.string.split("."))-1] == "htm":
                url += "l"
            link_list.append(url)
        link_list_final = link_list

        print ("Number of files to download {0}".format(len(link_list_final)))

        # List of url to the text documents
        doc_list = list()
        # List of document names
        doc_name_list = list()

        # Get all the doc
        for k in range(len(link_list_final)):
            required_url = link_list_final[k].replace('-index.html', '')
            txtdoc = required_url + ".txt"
            docname = txtdoc.split("/")[-1]
            doc_list.append(txtdoc)
            doc_name_list.append(docname)
        return doc_list, doc_name_list

