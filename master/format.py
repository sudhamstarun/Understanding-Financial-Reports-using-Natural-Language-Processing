import csv
import sys
  
in_file = sys.argv[1]
out_file= sys.argv[2]

row_reader = csv.reader(open(in_file, "rt", encoding="utf-8"    ))
row_writer = csv.writer(open(out_file, "wt", encoding="utf-8"))

for row in row_reader:
    i=0;
    new_row=[]    
    for val in row:
        if not val or val == '\xa0' or val == '$' or val == ')%' or val ==')' or val == '\xa0\xa0' or val == '\n\xa0\n' or val == '\xa0\n' or val == '\n\xa0' or val == '\n$' or val == '\n) $' or val == '\n)' or val == '\n)%' or val == ')\xa0' or val == 'USD' or val == '\n    0\n' or val == '\n    $\n' or val == '\n    )\n' or val == '\n    %\n' or val == '\n\xa0\t' or val == '\n\n' or val == '\xa0\n\t' or val == '%' or val == ' ' or val == '\nUSD\n' or val == '1' or val == '2' or val == '3' or val == '4' or val == '5' or val == '6' or val == '7' or val == '8' or val == '\nUSD\n' or val == '\xa0USD' or val == '\n\xa0USD\n' or val == '\n$\n' or val == '\n)\n' or val == '\n%' or val == '\nUSD ' or val == '\n$' or val == '\xa0\xa0\xa0\xa0\xa0\xa0$' or val == '\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0$' or val == '\xa0$' or val == ' \xa0' or val == '\nUSD ' or val == '\n%' or val == '\nJPY ' or val == '\n ' or val == '\xa0 ' or val == '$\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0 ' or val == '\xa0 ' or val == '\nRUB ' or val == '\nCHF ' or val == '\nCOP ' or val == '\nMXN ' or val == '\nUSD  ' or val == '%\xa0' or val == '\nJPY' or val == '\nGBP' or val == '\nCHF' or val == '\nUSD' or val == '\n%+' or val == '\xa0\n      ' or val == '\n%)' or val == '\xa0\xa0\xa0' or val == '\xa0\xa0\xa0\xa0' or val == '$ ' or val == '\xa0\xa0\xa0\n' or val == ')%\xa0' or val == '\n   ' or val == 'Currency' or val == '\n' or val == '\xa0\n\n\t' or val == '%)' or val == '(13)' or val == '(11)' or val == '($' or val == '\n\xa0\n      \n' or val == '\n%\n' or val == '\n)\xa0\xa0\n' or val == 'USD\xa0' or val == ') $' or val == '\xa0\xa0\xa0\xa0\xa0' or val == '\xa0\xa0\xa0\xa0\xa0\xa0\xa0' or val == '\n\xa0 ' or val == '\n) ' or val == '\n$ ' or val == '\n% ' or val == '\n\n\xa0  ' or val == '\n\nUSD  ' or val == ' \n\xa0\n\n' or val == '\n\n                            \xa0\n' or val == '\n\n\nUSD\n\n' or val == '\n\n\n                                \xa0\n\n' or val == '\n)%\n' or val == '\xa0\xa0\xa0\xa0\xa0\xa0' or val == '\n\n\t\t\t\t\t\t\xa0\n' or val == ' \n\n\t\t\t\t\t\t\t)\n\n' or val == ' \n$\n\n' or val == '\n\n\t\t\t\t\t\t)\n' or val == '\n\n\t\t\t\t\t\t$\n' or val == ' \n\n' or val == '\xa0\xa0 ' or val == 'USD ' or val == ')\xa0 ' or val == '\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\n' or val == ' \n\n\t\t\t\t\t\t\t\xa0\n\n' or val == ' \n\n\t\t\t\t\t\t\t$\n\n' or val == ' \n%\n\n' or val == ' \n)\n\n' or val == '\n \n' or val == '\xa0\n\n ' or val == '\n                                \xa0' or val == '\n                                \xa0' or val == '\n\xa0\n)\n' or val == 'USD \xa0' or val == '(@ ' or val == '\n  ' or val == '\nUSD   ' or val == '\n  \xa0 \xa0' or val == '\n  \xa0' or val == '\n\xa0\n        ' or val == '\n\xa0  ' or val == '\n\xa0   ' or val == '\n\xa0\n         ' or val == '\n\xa0\n\t' or val == '%)\xa0':
                # new_row.append(row[i+1])
                if(i+1 != (len(row)-1)):
                        i+=1
        else:
                new_row.append(val)
                if(i+1 != len(row)):
                        i+=1
    print (row, "->", new_row )
    if(len(new_row)>3):
         row_writer.writerow(new_row)

