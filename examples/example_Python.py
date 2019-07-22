# load modules
import pymongo
from pymongo import MongoClient

import numpy as np
import pandas as pd
from pandas.io.json import json_normalize

import re

# connect to MongoDB 
client = MongoClient()

client = MongoClient('localhost', 27017,
        username = "user", password = "pw")

# choose database exfor
db = client["exfor"]
# and collection entries
entries = db["entries"]

# retrieve dataset with a specific subentry ID
subent = entries.find_one({ 'ID': '11701004' })

# explore a bit
subent["BIB"]["AUTHOR"]
subent["DATA"]["UNIT"]
subent["DATA"]["TABLE"]

# retrieve datasets whose REACTION string
# matches a regular expression
regex = re.compile("^\(26-FE-56\(N,[^)]+\)[^,]*,,SIG\)")
subents = entries.find({ 'BIB.REACTION' : regex })

# loop over the subents
for subent in subents:
    print(subent["BIB"]["AUTHOR"])

# impose additional requirement that
# fields ID, BIB.AUTHOR and DATA.TABLE.DATA must be present
# but not field _id
query_spec = {'BIB.REACTION' : regex, 'DATA.TABLE.DATA': { '$exists' : True}}
filter_spec = {'ID': 1, 'BIB.AUTHOR': 1, 'DATA.TABLE.DATA': 1, '_id': 0 }
subents = entries.find(query_spec, filter_spec) 
        
# convert a subselection of the information
# in the matching subentries to a pandas DataFrame
rawdf = json_normalize(list(subents))
# do some search operatoins
lst_col = 'DATA.TABLE.DATA'
rep_len = rawdf[lst_col].str.len()
rep_len[np.isnan(rep_len)] = 1
rep_len = rep_len.astype(int)

df = pd.DataFrame({
          col: np.repeat(rawdf[col].values, rep_len)
               for col in rawdf.columns.drop(lst_col) }
                ).assign(**{lst_col:np.hstack(rawdf[lst_col].values)})[rawdf.columns]

print(df)

