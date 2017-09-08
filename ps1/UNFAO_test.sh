function UNFAO(){
code=$1;
wget -O $code.zip "http://data.un.org/Handlers/DownloadHandler.ashx?DataFilter=itemCode:$1&DataMartId=FAO&Format=csv&c=2,3,4,5,6,7&s=countryName:asc,elementCode:asc,year:desc";
unzip -c $code.zip > $code.csv;
less $code.csv
}
