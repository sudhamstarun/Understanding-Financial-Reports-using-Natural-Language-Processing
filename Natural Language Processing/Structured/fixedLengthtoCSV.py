"""
This script will convert Fixed width File into Delimiter File, tried on Python 3.5 only
Sample run: (Order of argument doesnt matter)
python ConvertFixedToDelimiter.py -i SrcFile.txt -o TrgFile.txt -c Config.txt -d "|"
Inputs are as follows
1. Input FIle - Mandatory(Argument -i) - File which has fixed Width data in it
2. Config File - Optional (Argument -c, if not provided will look for Config.txt file on same path, if not present script will not run)
    Should have format as
    FieldName,fieldLength
    eg:
    FirstName,10
    SecondName,8
    Address,30
    etc:
3. Output File - Optional (Argument -o, if not provided will be used as InputFIleName plus Delimited.txt)
4. Delimiter - Optional (Argument -d, if not provided default value is "|" (pipe))
"""

import argparse
import os.path
import sys

from collections import OrderedDict
from argaparse import ArgumentParser

def
