#!/bin/bash

mkdir acstemp

cd acstemp

mkdir schemas

basestr="SELECT a.KEY AS KEY,a.FILEID AS KEY,a.STUSAB AS KEY,a.SUMLEVEL AS KEY,a.COMPONENT AS KEY,a.LOGRECNO AS KEY,a.US AS KEY,a.REGION AS KEY,a.DIVISION AS KEY,a.STATECE AS KEY,a.STATE AS KEY,a.COUNTY AS KEY,a.COUSUB AS KEY,a.PLACE AS KEY,a.TRACT AS KEY,a.BLKGRP AS KEY,a.CONCIT AS KEY,a.AIANHH AS KEY,a.AIANHHFP AS KEY,a.AIHHTLI AS KEY,a.AITSCE AS KEY,a.AITS AS KEY,a.ANRC AS KEY,a.CBSA AS KEY,a.CSA AS KEY,a.METDIV AS KEY,a.MACC AS KEY,a.MEMI AS KEY,a.NECTA AS KEY,a.CNECTA AS KEY,a.NECTADIV AS KEY,a.UA AS KEY,a.BLANK1 AS KEY,a.CDCURR AS KEY,a.SLDU AS KEY,a.SLDL AS KEY,a.BLANK2 AS KEY,a.BLANK3 AS KEY,a.ZCTA5 AS KEY,a.SUBMCD AS KEY,a.SDELM AS KEY,a.SDSEC AS KEY,a.SDUNI AS KEY,a.UR AS KEY,a.PCI AS KEY,a.BLANK4 AS KEY,a.BLANK5 AS KEY,a.PUMA5 AS KEY,a.BLANK6 AS KEY,a.GEOID AS KEY,a.NAME AS KEY,a.BTTR AS KEY,a.BTBG AS KEY,a.BLANK7 AS KEY"

echo "downloading list of columns from census"
curl --progress-bar https://www2.census.gov/programs-surveys/acs/summary_file/2015/documentation/user_tools/ACS_5yr_Seq_Table_Number_Lookup.txt -O
sed 1d ACS_5yr_Seq_Table_Number_Lookup.txt > no_header.csv

awk -F, '$4 ~ /^[0-9]+$/' no_header.csv > columns_list.csv

echo "creating individual table shells"
while IFS=',' read f1 f2 f3 f4 f5; do echo -n ","`printf $f2`"_"`printf %03d $f4` >> "./schemas/eseq"`printf $f3 | tail -c 3`"$f2.txt"; done < columns_list.csv;

echo "creating margin of error shells"
while IFS=',' read f1 f2 f3 f4 f5; do echo -n ","`printf $f2`"_"`printf %03d $f4` >> "./schemas/mseq"`printf $f3 | tail -c 3`"$f2.txt"; done < columns_list.csv;

cd schemas

for file in *.txt; do echo ",${file:0:7};\"" > _${file:0:-4}.csv; done

for file in *.csv; do sed -i -e 's/,/ FROM acs1115\./g' $file; done

echo "writing lookup columns"

for file in *.txt; do sed -i "1s;^;bq query --destination_table=acs1115tables.${file:0:1}${file:7:-4} \"SELECT KEY,FILEID,STUSAB,SUMLEVEL,COMPONENT,LOGRECNO,US,REGION,DIVISION,STATECE,STATE,COUNTY,COUSUB,PLACE,TRACT,BLKGRP,CONCIT,AIANHH,AIANHHFP,AIHHTLI,AITSCE,AITS,ANRC,CBSA,CSA,METDIV,MACC,MEMI,NECTA,CNECTA,NECTADIV,UA,BLANK1,CDCURR,SLDU,SLDL,BLANK2,BLANK3,ZCTA5,SUBMCD,SDELM,SDSEC,SDUNI,UR,PCI,BLANK4,BLANK5,PUMA5,BLANK6,GEOID,NAME,BTTR,BTBG,BLANK7;" $file; done;

mkdir ../sql

echo "writing output files to sql"
for file in *.txt; do cat $file "_$file_${file:0:-4}.csv" > "../sql/${file:0:1}${file:7:-4}.sql"; done;


# tables b24121 to b24126 span multiple sequence files, so above technique won't work.
# shells for these files must be created manually

echo "creating special case tables B24121 to B24126"

for j in $(seq 24121 24126); do
echo -n "bq query --destination_table=acs1115tables.e$j \"$basestr" > ../sql/eB$j.sql;
for i in $(seq -f "%03g" 1 245); do echo -n ",a.B$j_$i as B$j_$i" >> ../sql/eB$j.sql; done;
for i in $(seq -f "%03g" 246 490); do echo -n ",b.B$j_$i as B$j_$i" >> ../sql/eB$j.sql; done;
for i in $(seq -f "%03g" 491 526); do echo -n ",c.B$j_$i as B$j_$i" >> ../sql/eB$j.sql; done;
echo -n "bq query --destination_table=acs1115tables.mB$j \"$basestr" > ../sql/mB$j.sql;
for i in $(seq -f "%03g" 1 245); do echo -n ",a.B$j_$i as B$j_$i" >> ../sql/mB$j.sql; done;
for i in $(seq -f "%03g" 246 490); do echo -n ",b.B$j_$i as B$j_$i" >> ../sql/mB$j.sql; done;
for i in $(seq -f "%03g" 491 526); do echo -n ",c.B$j_$i as B$j_$i" >> ../sql/mB$j.sql; done;
done;

echo -n " FROM [acs1115.eseq085] a JOIN [acs1115.eseq086] b ON a.KEY = b.KEY JOIN [acs1115.eseq087] c ON a.KEY = c.KEY;\"" >> ../sql/eB24121.sql;
echo -n " FROM [acs1115.mseq085] a JOIN [acs1115.mseq086] b ON a.KEY = b.KEY JOIN [acs1115.mseq087] c ON a.KEY = c.KEY;\"" >> ../sql/mB24121.sql;

echo -n " FROM [acs1115.eseq088] a JOIN [acs1115.eseq089] b ON a.KEY = b.KEY JOIN [acs1115.eseq090] c ON a.KEY = c.KEY;\"" >> ../sql/eB24122.sql;
echo -n " FROM [acs1115.mseq088] a JOIN [acs1115.mseq089] b ON a.KEY = b.KEY JOIN [acs1115.mseq090] c ON a.KEY = c.KEY;\"" >> ../sql/mB24122.sql;

echo -n " FROM [acs1115.eseq091] a JOIN [acs1115.eseq092] b ON a.KEY = b.KEY JOIN [acs1115.eseq093] c ON a.KEY = c.KEY;\"" >> ../sql/eB24123.sql;
echo -n " FROM [acs1115.mseq091] a JOIN [acs1115.mseq092] b ON a.KEY = b.KEY JOIN [acs1115.mseq093] c ON a.KEY = c.KEY;\"" >> ../sql/mB24123.sql;

echo -n " FROM [acs1115.eseq094] a JOIN [acs1115.eseq095] b ON a.KEY = b.KEY JOIN [acs1115.eseq096] c ON a.KEY = c.KEY;\"" >> ../sql/eB24124.sql;
echo -n " FROM [acs1115.mseq094] a JOIN [acs1115.mseq095] b ON a.KEY = b.KEY JOIN [acs1115.mseq096] c ON a.KEY = c.KEY;\"" >> ../sql/mB24124.sql;

echo -n " FROM [acs1115.eseq097] a JOIN [acs1115.eseq098] b ON a.KEY = b.KEY JOIN [acs1115.eseq099] c ON a.KEY = c.KEY;\"" >> ../sql/eB24125.sql;
echo -n " FROM [acs1115.mseq097] a JOIN [acs1115.mseq098] b ON a.KEY = b.KEY JOIN [acs1115.mseq099] c ON a.KEY = c.KEY;\"" >> ../sql/mB24125.sql;

echo -n " FROM [acs1115.eseq100] a JOIN [acs1115.eseq101] b ON a.KEY = b.KEY JOIN [acs1115.eseq102] c ON a.KEY = c.KEY;\"" >> ../sql/eB24126.sql;
echo -n " FROM [acs1115.mseq100] a JOIN [acs1115.mseq101] b ON a.KEY = b.KEY JOIN [acs1115.mseq102] c ON a.KEY = c.KEY;\"" >> ../sql/mB24126.sql;

cd ../sql

echo "executing sql"

for file in *.sql; do bash $file; done;


