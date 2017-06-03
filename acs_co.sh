#!/bin/bash

mkdir acs
cd acs

echo "downloading CO all geo not tracts and bgs"
curl --progress-bar https://www2.census.gov/programs-surveys/acs/summary_file/2015/data/5_year_by_state/Colorado_All_Geographies_Not_Tracts_Block_Groups.zip -O
echo "downloading CO all tracts and bgs"
curl --progress-bar https://www2.census.gov/programs-surveys/acs/summary_file/2015/data/5_year_by_state/Colorado_Tracts_Block_Groups_Only.zip -O

unzip Colorado_All_Geographies_Not_Tracts_Block_Groups.zip -d group1
unzip Colorado_Tracts_Block_Groups_Only.zip -d group2

mkdir staged
mkdir combined
mkdir sorted

mkdir geostaged
mkdir geocombined
mkdir geosorted

mkdir joined

cd group1
for file in *20155**0***000.txt ; do mv $file ${file//.txt/a.csv} ; done
for i in *20155**0***000*.csv; do echo "writing p_$i"; while IFS=, read f3 f6; do echo "$f3$f6,"; done < $i > p_$i; done
mv p_* ../staged/

cd ../group2
for file in *20155**0***000.txt ; do mv $file ${file//.txt/b.csv} ; done
for i in *20155**0***000*.csv; do echo "writing p_$i"; while IFS=, read f3 f6; do echo "$f3$f6,"; done < $i > p_$i; done
mv p_* ../staged/

cd ../staged

for i in $(seq -f "%03g" 1 122); do cat p_e20155**0"$i"000*.csv >> eseq"$i".csv; done;
for i in $(seq -f "%03g" 1 122); do cat p_m20155**0"$i"000*.csv >> mseq"$i".csv; done;
mv *seq* ../combined/

cd ../combined

for file in *.csv; do echo "sorting $file"; sort $file > ../sorted/$file; done;


cd ../group1
for file in g20155**.csv; do mv $file ../geostaged/$file; done;

cd ../geostaged
for file in *.csv; do cat $file >> ../geocombined/geo_concat.csv; done;

cd ../geocombined
awk -F "\"*,\"*" '{print $2 $5}' geo_concat.csv > geo_key.csv
tr A-Z a-z < geo_key.csv > geo_key_lowercase.csv
paste -d , geo_key_lowercase.csv geo_concat.csv > acs_geo_2015.csv
sort acs_geo_2015.csv > ../geosorted/acs_geo_2015.csv

cd ../sorted
for file in *.csv; do echo "joining $file with geography"; join -t , -1 1 -2 1 ../geosorted/acs_geo_2015.csv ./$file > ../joined/$file; done;

