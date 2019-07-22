#!/bin/sh

# The MIT License
# 
# Copyright (c) 2019 Georg Schnabel
# 
# Permission is hereby granted, free of charge, 
# to any person obtaining a copy of this software and 
# associated documentation files (the "Software"), to 
# deal in the Software without restriction, including 
# without limitation the rights to use, copy, modify, 
# merge, publish, distribute, sublicense, and/or sell 
# copies of the Software, and to permit persons to whom 
# the Software is furnished to do so, 
# subject to the following conditions:
# 
# The above copyright notice and this permission notice 
# shall be included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR 
# ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

##################################################
#       CONFIGURATION VARIABLES
##################################################

db_user=""
db_password=""

instpath="/home/install"

# installation files to keep
keep_Rcodes="no"
keep_exfor="no"

##################################################
#       SPECIFIC INSTALLATION PATHS 
##################################################

instpath_R="$instpath/Rpackages"
instpath_R2="$instpath/Rcode"
instpath_DL="$instpath/downloads"
instpath_exfor="$instpath/exfor"
instpath_exfor_text="$instpath_exfor/text"

repourl_R="https://cran.rstudio.com"
gitrepo="https://github.com/gschnabel"

##################################################
#       CONFIGURE OPTIONS
##################################################

savewd=$(pwd)

export DEBIAN_FRONTEND=noninteractive
apt update

##################################################
#       CREATE DIRECTORIES
##################################################

mkdir -p "$instpath"
mkdir "$instpath_DL"
mkdir "$instpath_R"
mkdir "$instpath_R2"

##################################################
#       INSTALL BASIC OS PACKAGES
##################################################

apt install -yq apt-utils
apt install -yq lib32readline7
apt install -yq libssl-dev
apt install -yq libsasl2-dev
apt install -yq gnupg

apt install -yq wget
apt install -yq curl

apt install -yq screen
apt install -yq vim

apt install -yq git

apt install -yq locales
sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
echo "deb [ arch=amd64 ] https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/" | tee /etc/apt/sources.list.d/r-project-3.5.list

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.0.list
apt update

apt install -yq mongodb-org
apt install -yq r-base

##################################################
#       INSTALL REQUIRED R PACKAGES
##################################################

instpkg_cran() {
    R --no-save -e "install.packages(\"$1\", repos=\"$repourl_R\")"
}

instpkg_cust() {
    git clone "$gitrepo/${1}.git"
    R CMD INSTALL "$1"
}

cd "$instpath_R"

# install packages available on cran

instpkg_cran data.table
instpkg_cran Rcpp
instpkg_cran mongolite

# install custom packages not on cran

instpkg_cust exforParser

##################################################
#       SET UP THE MONGODB DATABASE
##################################################

download_exfor() {
    curl -O "$1"
    tar -C text -xf "$(basename "$1")"
}

mkdir "$instpath_exfor"
mkdir "$instpath_exfor_text"
cd "$instpath_exfor"

download_exfor "http://www.nucleardata.com/storage/repos/exfor/entries_10001-10535.tar.xz"
download_exfor "http://www.nucleardata.com/storage/repos/exfor/entries_10536-11690.tar.xz"
download_exfor "http://www.nucleardata.com/storage/repos/exfor/entries_11691-13569.tar.xz"
download_exfor "http://www.nucleardata.com/storage/repos/exfor/entries_13570-13768.tar.xz"
download_exfor "http://www.nucleardata.com/storage/repos/exfor/entries_13769-14239.tar.xz"
download_exfor "http://www.nucleardata.com/storage/repos/exfor/entries_14240-20118.tar.xz"
download_exfor "http://www.nucleardata.com/storage/repos/exfor/entries_20119-21773.tar.xz"
download_exfor "http://www.nucleardata.com/storage/repos/exfor/entries_21774-22412.tar.xz"
download_exfor "http://www.nucleardata.com/storage/repos/exfor/entries_22413-22921.tar.xz"
download_exfor "http://www.nucleardata.com/storage/repos/exfor/entries_22922-23129.tar.xz"
download_exfor "http://www.nucleardata.com/storage/repos/exfor/entries_23130-23250.tar.xz"
download_exfor "http://www.nucleardata.com/storage/repos/exfor/entries_23251-23324.tar.xz"
download_exfor "http://www.nucleardata.com/storage/repos/exfor/entries_23325-23415.tar.xz"
download_exfor "http://www.nucleardata.com/storage/repos/exfor/entries_23416-A0099.tar.xz"
download_exfor "http://www.nucleardata.com/storage/repos/exfor/entries_A0100-C1030.tar.xz"
download_exfor "http://www.nucleardata.com/storage/repos/exfor/entries_C1031-D0487.tar.xz"
download_exfor "http://www.nucleardata.com/storage/repos/exfor/entries_D0488-E1841.tar.xz"
download_exfor "http://www.nucleardata.com/storage/repos/exfor/entries_E1842-F1045.tar.xz"
download_exfor "http://www.nucleardata.com/storage/repos/exfor/entries_F1046-O0678.tar.xz"
download_exfor "http://www.nucleardata.com/storage/repos/exfor/entries_O0679-V1002.tar.xz"

# populate the database

mkdir -p "/data/db"
mkdir "$instpath_R2"
cd "$instpath_R2"

# start the mongodb server
mongod --fork --logpath /var/log/mongod.log

Rfile="$instpath_R2/createExforDb/create_exfor_mongodb.R"
git clone https://github.com/gschnabel/createExforDb.git
sed -i -e "s|<PATH TO DIRECTORY WITH EXFOR ENTRIES>|$instpath_exfor_text|" "$Rfile"
Rscript --no-save --vanilla "$Rfile" 

##################################################
#       ENABLE MONGODB AUTHENTIFICATION 
##################################################

autharg=""
if [ ! -z "$db_user" ] && [ ! -z "$db_password" ]; then
    autharg="--auth"
fi

[ ! -z "$autharg" ] && mongo <<EOF
con = new Mongo();
db = con.getDB("admin");
db.createUser(
  {
    user: "$db_user",
    pwd: "$db_password",
    roles: [ { role: "userAdminAnyDatabase", db: "admin" },
             "readWriteAnyDatabase" ]
  }
)
EOF

##################################################
#       SET UP THE STARTUP SCRIPT 
##################################################

cat > /home/startup.sh <<EOF
#!/bin/bash
mongod $autharg --bind_ip_all --fork --logpath /var/log/mongod.log
export LANG=en_US.UTF-8
export LANGUAGE=en_US:en
export LC_ALL=en_US.UTF-8
/bin/bash
EOF

chmod 744 /home/startup.sh

##################################################
#       FINAL ACTIONS 
##################################################

# delete installation files
rm -rf "$instpath_DL"
if [ "$keep_exfor" != "yes" ]; then
    rm -rf "$instpath_exfor"
else
    mv "$instpath_exfor_text" "$instpath/exfortmp"
    rm -rf "$instpath_exfor"
    mv "$instpath/exfortmp" "$instpath_exfor"
fi

if [ "$keep_Rcodes" != "yes" ]; then
    rm -rf "$instpath_R"
    rm -rf "$instpath_R2"
fi

if [ "$keep_Rcodes" != "yes" ] && [ "$keep_exfor" != "yes" ]; then
    rm -rf "$instpath"
fi
