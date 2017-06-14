#!/bin/bash


#configure these variables
currentbigqueryschema=acs1115;
bigquerytableschema=acs1115tables;

dir=$(pwd)
LOG_FILE="$dir/acs1115tables_logfile.txt"
exec > >(tee -a ${LOG_FILE} )
exec 2> >(tee -a ${LOG_FILE} >&2)


starttime="start: `date +"%T"`"


mkdir acstemp

cd acstemp

mkdir schemas

basestr="SELECT a.KEY AS KEY,a.FILEID AS FILEID,a.STUSAB AS STUSAB,a.SUMLEVEL AS SUMLEVEL,a.COMPONENT AS COMPONENT,a.LOGRECNO AS LOGRECNO,a.US AS US,a.REGION AS REGION,a.DIVISION AS DIVISION,a.STATECE AS STATECE,a.STATE AS STATE,a.COUNTY AS COUNTY,a.COUSUB AS COUSUB,a.PLACE AS PLACE,a.TRACT AS TRACT,a.BLKGRP AS BLKGRP,a.CONCIT AS CONCIT,a.AIANHH AS AIANHH,a.AIANHHFP AS AIANHHFP,a.AIHHTLI AS AIHHTLI,a.AITSCE AS AITSCE,a.AITS AS AITS,a.ANRC AS ANRC,a.CBSA AS CBSA,a.CSA AS CSA,a.METDIV AS METDIV,a.MACC AS MACC,a.MEMI AS MEMI,a.NECTA AS NECTA,a.CNECTA AS CNECTA,a.NECTADIV AS NECTADIV,a.UA AS UA,a.BLANK1 AS BLANK1,a.CDCURR AS CDCURR,a.SLDU AS SLDU,a.SLDL AS SLDL,a.BLANK2 AS BLANK2,a.BLANK3 AS BLANK3,a.ZCTA5 AS ZCTA5,a.SUBMCD AS SUBMCD,a.SDELM AS SDELM,a.SDSEC AS SDSEC,a.SDUNI AS SDUNI,a.UR AS UR,a.PCI AS PCI,a.BLANK4 AS BLANK4,a.BLANK5 AS BLANK5,a.PUMA5 AS PUMA5,a.BLANK6 AS BLANK6,a.GEOID AS GEOID,a.NAME AS NAME,a.BTTR AS BTTR,a.BTBG AS BTBG,a.BLANK7 AS BLANK7"

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

for file in *.csv; do sed -i -e "s/,/ FROM $currentbigqueryschema\./g" $file; done

echo "writing lookup columns"


unique=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1);

for file in *.txt; do sed -i "1s;^;bq query --nosync --job_id=${file:0:1}${file:7:-4}$unique --destination_table=$bigquerytableschema.${file:0:1}${file:7:-4} \"SELECT KEY,FILEID,STUSAB,SUMLEVEL,COMPONENT,LOGRECNO,US,REGION,DIVISION,STATECE,STATE,COUNTY,COUSUB,PLACE,TRACT,BLKGRP,CONCIT,AIANHH,AIANHHFP,AIHHTLI,AITSCE,AITS,ANRC,CBSA,CSA,METDIV,MACC,MEMI,NECTA,CNECTA,NECTADIV,UA,BLANK1,CDCURR,SLDU,SLDL,BLANK2,BLANK3,ZCTA5,SUBMCD,SDELM,SDSEC,SDUNI,UR,PCI,BLANK4,BLANK5,PUMA5,BLANK6,GEOID,NAME,BTTR,BTBG,BLANK7;" $file; done;

mkdir ../sql

echo "writing output files to sql"
for file in *.txt; do cat $file "_$file_${file:0:-4}.csv" > "../sql/${file:0:1}${file:7:-4}.sql"; done;


# tables b24121 to b24126 span multiple sequence files, so above technique won't work.
# shells for these files must be created manually

echo "creating special case tables B24121 to B24126"


for j in $(seq 24121 24126); do
echo -n "bq query --maximum_billing_tier 2 --nosync --job_id=eB$j$unique --destination_table=$bigquerytableschema.eB$j \"$basestr" > ../sql/eB$j.sql;
for i in $(seq -f "%03g" 1 245); do echo -n ",a.B$j""_""$i as B$j""_""$i" >> ../sql/eB$j.sql; done;
for i in $(seq -f "%03g" 246 490); do echo -n ",b.B$j""_""$i as B$j""_""$i" >> ../sql/eB$j.sql; done;
for i in $(seq -f "%03g" 491 526); do echo -n ",c.B$j""_""$i as B$j""_""$i" >> ../sql/eB$j.sql; done;
echo -n "bq query --maximum_billing_tier 2 --nosync --job_id=mB$j$unique --destination_table=$bigquerytableschema.mB$j \"$basestr" > ../sql/mB$j.sql;
for i in $(seq -f "%03g" 1 245); do echo -n ",a.B$j""_""$i as B$j""_""$i" >> ../sql/mB$j.sql; done;
for i in $(seq -f "%03g" 246 490); do echo -n ",b.B$j""_""$i as B$j""_""$i" >> ../sql/mB$j.sql; done;
for i in $(seq -f "%03g" 491 526); do echo -n ",c.B$j""_""$i as B$j""_""$i" >> ../sql/mB$j.sql; done;
done;

echo -n " FROM [$currentbigqueryschema.eseq085] a JOIN [$currentbigqueryschema.eseq086] b ON a.KEY = b.KEY JOIN [$currentbigqueryschema.eseq087] c ON a.KEY = c.KEY;\"" >> ../sql/eB24121.sql;
echo -n " FROM [$currentbigqueryschema.mseq085] a JOIN [$currentbigqueryschema.mseq086] b ON a.KEY = b.KEY JOIN [$currentbigqueryschema.mseq087] c ON a.KEY = c.KEY;\"" >> ../sql/mB24121.sql;

echo -n " FROM [$currentbigqueryschema.eseq088] a JOIN [$currentbigqueryschema.eseq089] b ON a.KEY = b.KEY JOIN [$currentbigqueryschema.eseq090] c ON a.KEY = c.KEY;\"" >> ../sql/eB24122.sql;
echo -n " FROM [$currentbigqueryschema.mseq088] a JOIN [$currentbigqueryschema.mseq089] b ON a.KEY = b.KEY JOIN [$currentbigqueryschema.mseq090] c ON a.KEY = c.KEY;\"" >> ../sql/mB24122.sql;

echo -n " FROM [$currentbigqueryschema.eseq091] a JOIN [$currentbigqueryschema.eseq092] b ON a.KEY = b.KEY JOIN [$currentbigqueryschema.eseq093] c ON a.KEY = c.KEY;\"" >> ../sql/eB24123.sql;
echo -n " FROM [$currentbigqueryschema.mseq091] a JOIN [$currentbigqueryschema.mseq092] b ON a.KEY = b.KEY JOIN [$currentbigqueryschema.mseq093] c ON a.KEY = c.KEY;\"" >> ../sql/mB24123.sql;

echo -n " FROM [$currentbigqueryschema.eseq094] a JOIN [$currentbigqueryschema.eseq095] b ON a.KEY = b.KEY JOIN [$currentbigqueryschema.eseq096] c ON a.KEY = c.KEY;\"" >> ../sql/eB24124.sql;
echo -n " FROM [$currentbigqueryschema.mseq094] a JOIN [$currentbigqueryschema.mseq095] b ON a.KEY = b.KEY JOIN [$currentbigqueryschema.mseq096] c ON a.KEY = c.KEY;\"" >> ../sql/mB24124.sql;

echo -n " FROM [$currentbigqueryschema.eseq097] a JOIN [$currentbigqueryschema.eseq098] b ON a.KEY = b.KEY JOIN [$currentbigqueryschema.eseq099] c ON a.KEY = c.KEY;\"" >> ../sql/eB24125.sql;
echo -n " FROM [$currentbigqueryschema.mseq097] a JOIN [$currentbigqueryschema.mseq098] b ON a.KEY = b.KEY JOIN [$currentbigqueryschema.mseq099] c ON a.KEY = c.KEY;\"" >> ../sql/mB24125.sql;

echo -n " FROM [$currentbigqueryschema.eseq100] a JOIN [$currentbigqueryschema.eseq101] b ON a.KEY = b.KEY JOIN [$currentbigqueryschema.eseq102] c ON a.KEY = c.KEY;\"" >> ../sql/eB24126.sql;
echo -n " FROM [$currentbigqueryschema.mseq100] a JOIN [$currentbigqueryschema.mseq101] b ON a.KEY = b.KEY JOIN [$currentbigqueryschema.mseq102] c ON a.KEY = c.KEY;\"" >> ../sql/mB24126.sql;

cd ../sql

echo "executing sql"

bq mk $bigquerytableschema

for file in *.sql; do bash $file; done;


#cleanup
echo "cleaning up temp files on hard drive"
cd ../..

# rm -r acstemp

echo "all done."


echo $starttime
echo "end: `date +"%T"`"
