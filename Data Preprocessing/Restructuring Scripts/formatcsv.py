import csv
import sys
  
in_file = sys.argv[1]
out_file= sys.argv[2]

row_reader = csv.reader(open(in_file, "rt", encoding="utf-8"    ))
row_writer = csv.writer(open(out_file, "wt", encoding="utf-8"))


#csv_reader = csv.reader(f)

data = []
for row in row_reader:
    data.append(row) 

#print(data[2][4])
for i in range(len(data)):
	for j in range(len(data[i])):
		if data[i][j] == '\n\xa0\n' or data[i][j] == '\xa0' or data[i][j] == '\xa0\n':
			data[i][j] = ' ' 

r=[]
column=0
while(column<18):
#	r = []
	l=''
	for i in range(6):
		try:
			l+=str(data[i][column])
#			l.append(data[i][column])
			l = l.strip('\n')
			l = l.replace('\n','')
			l = l.strip('    ')
			
		except:
			pass
#	print(l)
	r.append(l)		
	column+=1
print(r)
#row_writer.writerow(r)

#print(len(r))
for x in range(len(r)):
	i=0
	y=[]
#	print(type(r[x]))
#	print(r[x].split())
	if r[x] ==" \'\'":
		if(i+1!=(len(r)-1)):
			i+=1
	else:
		y.append(r[x])
		if(i+1!=(len(r))):
			i+=1
row_writer.writerow(r)

for x in range(6,len(data)): 
    i=0;
    new_row=[]
    for y in range(len(data[x])):
      if not data[x][y] or data[x][y] == ' ':
          # new_row.append(row[i+1])
          if(i+1 != (len(data[x])-1)):
              i+=1
      else:
          new_row.append(data[x][y])
          if(i+1 != len(data[x])):
              i+=1
    print (data[x], "->", new_row ) 
    row_writer.writerow(new_row)


#for x in range(6,len(data)):
#    i=0;
#    new_row=[]    
#    for y in range(len(data[x])):
#        if not data[x][y] or data[x][y] == '\xa0' or data[x][y] == '$' or data[x][y] == ')%' or data[x][y] ==')' or data[x][y] == '\xa0\xa0' or data[x][y] == '\n\xa0\n' or data[x][y] == '\xa0\n':
                # new_row.append(row[i+1])
#                if(i+1 != (len(data[x])-1)):
#                        i+=1
#        else:
#                new_row.append(data[x][y])
#                if(i+1 != len(data[x])):
#                        i+=1
#    print (data[x], "->", new_row )
#    if(len(new_row)>4):
#         row_writer.writerow(new_row)
