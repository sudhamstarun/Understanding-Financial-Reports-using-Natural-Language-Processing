import os
import glob
import pandas as pd
#set working directory
os.chdir("/home2/vvsaripalli/usefulTables/PROPERLYFORMATTEDTABLES/0000729968_N-CSRS_0001434991-09-000182")
pd.set_option('display.expand_frame_repr', False)


#find all csv files in the folder
#use glob pattern matching -> extension = 'csv'
#save result in list -> all_filenames
extension = 'csv'
all_filenames = [i for i in glob.glob('*.{}'.format(extension))]
#print(all_filenames)
#print(all_filenames)
combined_csv = pd.concat([pd.read_csv(f) for f in all_filenames ], sort=False)

#combine all files in the list
#for f in all_filenames:
#	print (pd.read_csv(f))

#print(combined_csv)
# print(combined_csv) > "1.csv"
#export to csv
combined_csv.to_csv( "combined.csv", index=False, encoding='utf-8-sig')
