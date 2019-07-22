library(mongolite)

db <- mongo(collection = "entries",
            db = "exfor",
            url = "mongodb://user:pw@localhost:27017")

# retrieve subentry with specific ID
it <- db$iterate('{ "ID": "11701004" }')
subent <- it$one()

# explore the subentry a bit
subent$BIB$AUTHOR
subent$DATA$UNIT
subent$DATA$TABLE

# search for subentry whose REACTION string
# matches a specific regular expression
regex <- "^\\\\(26-FE-56\\\\(N,[^)]+\\\\)[^,]*,,SIG\\\\)" 
query <- paste0('{ "BIB.REACTION" : { "$regex": "', regex, '", "$options" : "" }, "DATA.TABLE.DATA" : { "$exists": 1}}')
fields <- '{ "ID": 1, "BIB.AUTHOR": 1, "DATA.TABLE.DATA": 1, "_id": 0 }' 
it <- db$iterate(query, fields)

# loop over the found subentries
while (!is.null(subent <- it$one())) {
   print(subent$BIB$AUTHOR) 
}

# consider using the R package at
# https://github.com/gschnabel/MongoEXFOR
# for a shallow wrapper around mongolite
# with convenience functions

