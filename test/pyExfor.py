import pymongo
import numpy as np
from pymongo import MongoClient
import pandas as pd
from pandas.io.json import json_normalize
import re

client = MongoClient()

client = MongoClient('localhost', 27017,
        username = "user", password = "pw")

db = client["exfor"]
entries = db["entries"]

subent = entries.find_one({ 'ID': '11701004' })



regex = re.compile("^\(26-FE-56\(N,[^)]+\)[^,]*,,SIG\)")
subents = entries.find({ 'BIB.REACTION' : regex })


tst = entries.find({'BIB.REACTION' : regex, 'DATA.TABLE.DATA': { '$exists' : True}}, 
        {'ID': 1, 'BIB.AUTHOR': 1, 'DATA.TABLE.DATA': 1, '_id': 0 })

df = json_normalize(list(tst))
# do some search operatoins
lst_col = 'DATA.TABLE.DATA'
rep_len = df[lst_col].str.len()
rep_len[np.isnan(rep_len)] = 1
rep_len = rep_len.astype(int)

r = pd.DataFrame({
          col: np.repeat(df[col].values, rep_len)
               for col in df.columns.drop(lst_col) }
                ).assign(**{lst_col:np.hstack(df[lst_col].values)})[df.columns]


tst = entries.find_one({'ID' : '10238034'})

df['DATA.TABLE.DATA']
