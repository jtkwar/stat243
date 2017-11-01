#Question 3 Problem Set 6

dir          = '/global/scratch/paciorek/wikistats_full/dated/'
home_dir = '/global/home/users/kwarsick/'
#Import necessary packages/libraries
from pyspark import SparkContext
sc = SparkContext()
import re
from operator import add

##Function to find search item of interest
def find(line, regex = "Subprime_lending", language = None):
    vals = line.split(' ')
    if len(vals) < 6:
        return(False)
    tmp = re.search(regex, vals[3])
    if tmp is None or (language != None and vals[2] != language):
        return(False)
    else:
        return(True)

# find the file names
lines = sc.textFile(dir) 		


#Collect search results in an object
subprime_lending = lines.filter(find).repartition(480)

# map-reduce step to sum hits across date-time-language triplets #
    
def stratify(line):
    # create key-value pairs where:
    #   key = date-time-language
    #   value = number of website hits
    vals = line.split(' ')
    return(vals[0] + '-' + vals[1] + '-' + vals[2], int(vals[4]))
	
	
spl_counts = subprime_lending.map(stratify).reduceByKey(add)  # 5 minutes
# 128889 for full dataset

# map step to prepare output #

def transform(vals):
    # split key info back into separate fields
    key = vals[0].split('-')
    return(",".join((key[0], key[1], key[2], str(vals[1]))))

# output to file #

# have one partition because one file per partition is written out
outputDir = home_dir + '/' + 'spark-output'
spl_counts.map(transform).repartition(1).saveAsTextFile(outputDir) # 5 sec.