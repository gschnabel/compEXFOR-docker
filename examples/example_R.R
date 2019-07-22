library(ongolite)

db <- mongo(collection = "entries",
            db = "exfor",
            url = "mongodb://user:password@localhost:27017")

it <- db$iterate('{ "ID": "11701004" }')
subent <- it$one()

regex <- "^\\\\(26-FE-56\\\\(N,[^)]+\\\\)[^,]*,,SIG\\\\)" 
query <- paste0('{ "BIB.REACTION" : { "$regex": "', regex, '", "$options" : "" }, "DATA.TABLE.DATA" : { "$exists": 1}}')
fields <- '{ "ID": 1, "BIB.AUTHOR": 1, "DATA.TABLE.DATA": 1, "_id": 0 }' 
it <- db$iterate(query, fields)

while (!is.null(subent <- it$one())) {
   print(subent) 
}


regex <- "^\\\\(26-FE-56\\\\(N,[^)]+\\\\)[^,]*,,SIG\\\\)" 
query <- paste0('{ "BIB.REACTION" : { "$regex": "', regex, '", "$options" : "" }}')
fields <- '{ "ID": 1, "BIB.AUTHOR": 1, "DATA.TABLE.DATA": 1, "_id": 0 }' 
it <- db$find(query, fields)


