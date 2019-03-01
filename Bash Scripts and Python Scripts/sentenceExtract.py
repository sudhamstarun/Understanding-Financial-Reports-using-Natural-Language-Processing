import sys
import re


def find(infile, outfile):
    with open(infile) as a, open(outfile, 'a') as b:
        for line in a:
            # matches = re.finditer(r"([^.]*?due([^\.]|\.(\d))*\.)",line, re.MULTILINE | re.IGNORECASE) )
            # matches = re.finditer(r"( [^.]*?credit default swap([^\.]|\.(\d))*\.| [^.]*?counterparty([^\.]|\.(\d))*\.| [^.]*?receives([^\.]|\.(\d))*\.| [^.]*?buy([^\.]|\.(\d))*\.| [^.]*?pays([^\.]|\.(\d))*\.| [^.]*?receive([^\.]|\.(\d))*\.| [^.]*?notional amount([^\.]|\.(\d))*\.| [^.]*?due([^\.]|\.(\d))*\. )",line, re.MULTILINE | re.IGNORECASE) )
            matches = re.finditer(r"([^.]*?receives([^\.]|\.(\d)|\.(\,))*\.| [^.]*?buy([^\.]|\.(\d)|\.(\,))*\.| [^.]*?sell([^\.]|\.(\d)|\.(\,))*\.|[^.]*?pays([^\.]|\.(\d)|\.(\,))*\.| [^.]*?\bpay\b([^\.]|\.(\d)|\.(\,))*\.|  [^.]*?reference entity([^\.]|\.(\d)|\.(\,))*\.| [^.]*?receive([^\.]|\.(\d)|\.(\,))*\.| [^.]*?expires([^\.]|\.(\d)|\.(\,))*\.|  [^.]*?fixed rate([^\.]|\.(\d)|\.(\,))*\.| [^.]*?quarterly([^\.]|\.(\d)|\.(\,))*\.|[^.]*?notional amount([^\.]|\.(\d)|\.(\,))*\.| [^.]*?due([^\.]|\.(\d)|\.(\,))*\. )", line, re.MULTILINE | re.IGNORECASE)

            for matchNum, match in enumerate(matches, start=1):

                b.write(" {match}".format(
                    matchNum=matchNum, start=match.start(), end=match.end(), match=match.group()))


find(sys.argv[1], sys.argv[2])
