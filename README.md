# bigQueryACS
Automate loading of American Community Survey data into Google BigQuery


## Prerequisites:

I VERY highly recommend running this from a Google Compute Instance for performance reasons.

Make sure to check the box that says:
*ALLOW FULL ACCESS TO ALL CLOUD APIs*

If you plan on loading the entire ACS, allocate an Instance with **325GB**.  

If you insist on running this elsewhere, you will need to have the **gsutil** and **bq** tools pre-installed.  You can get them by installing the [Google Cloud SDK](https://cloud.google.com/sdk/downloads) on the machine you wish to run the bigQueryACS script from.
I haven't tested on anything other than Google Compute Engine Debian and Ubuntu 16.04, so your mileage may vary on other OS's.

Other than that, you will need to make sure you have unzip installed (the Google Compute instances I've tested with did not have it.)

```sudo apt-get install unzip```


## Installation:

Grab the script from my Github.

```
wget https://raw.githubusercontent.com/royhobbstn/bigQueryACS/master/acs1115_bq.sh
```


## Using the Script

Like this for Colorado:
```
bash acs1115_bq.sh co
```

More than one State?
```
bash acs1115_bq.sh de co hi
```

All the States?  That's the default (will take a very long time, see below)
```
bash acs1115_bq.sh
```

**Warning:** To avoid the unfortunate situation of the script dying when the terminal unexpectedly disconnects (trust me, it will!), I would advise running larger jobs through [screen](https://kb.iu.edu/d/acuy).
```
screen
bash acs1115_bq.sh
```

Then press Ctrl-a, followed by 'd' (without the quotes) to go about your normal business.

When you want to check back in, type:
```
screen -r
```

When finished, exit a screen like you would with a normal session:
```
exit
```



## Customization

By default, this script will load the data files into a bucket called ```acs1115_stage```.  It will create a BigQuery schema named ```acs1115```.
To change these defaults, edit the environmental variables at the top of the code block:

```sudo vi acs1115_bq.sh```

You'll see something like:

```
#configure these variables
databucket=acs1115_stage;
bigqueryschema=acs1115;
```

These correspond to the Google Storage Bucket and Google Big Query Schemas you would like to use.  Give them unique names that make sense to you (if unfamiliar with VIM, press the 'i' key to start editing).  

Then [exit VIM](https://stackoverflow.blog/2017/05/23/stack-overflow-helping-one-million-developers-exit-vim/).



# Benchmarks

These were not made to brag about how fast the script is (it's not!).  Rather, it should give you an idea of how long you can expect to wait for processing to complete.

*Using Delaware as a sample State with Debian GNU/Linux 8 (jessie) and 20GB Standard Disk:*

n1-standard-1 (1 vCPU, 3.75 GB memory): *17min 27sec*
n1-highmem-8 (8 vCPUs, 52 GB memory): *17min 11sec*

*All US States with Debian GNU/Linux 8 (jessie) and 325GB Standard Disk:*

n1-standard-1 (1 vCPU, 3.75 GB memory): **
n1-highmem-8 (8 vCPUs, 52 GB memory): *5hr 48min 46sec*


# How do I use this data?

Google has a [GUI](https://bigquery.cloud.google.com/queries/) if you have any one-off or exploratory queries you'd like to run.

Here's an example query for finding the Median Household Income for all counties in Colorado.

```
select NAME, B19013_001 from acs1115.eseq059 where STATE = '08' and SUMLEVEL = '050' order by NAME asc;
```

As you may have noticed from the above query, I have purposely [denormalized](https://cloud.google.com/bigquery/preparing-data-for-loading) the data for improved query performance.  In the vast majority of cases, you should not need any JOINs in your data.


You can also use BigQuery through APIs written in [many different languages](https://cloud.google.com/bigquery/create-simple-app-api).
Here's some boilerplate NodeJS: [example.js](example.js).  It was created for a serverless function, but the format is such that it can be nearly cut and pasted into an existing ExpressJS application without much hassle.


# Sequence Number Tables?

Yeah, I know.  It's a pain to have to look up not only the field that corresponds to the statistic that you're looking for, but also the sequence table.  [Here's a document that can help.](https://www2.census.gov/programs-surveys/acs/summary_file/2015/documentation/user_tools/ACS_5yr_Seq_Table_Number_Lookup.xls)  

However, the good thing about having the data already in BigQuery is that it's fairly easy to create individual table files.

TODO: SQL to convert Seq Tables into logical tables.


## Note: I'm probably doing it wrong

If it looks like I've never written a bash script before in my life, it's because I haven't.
I'd be interested in any help I can get to make this faster or improve platform compatibility.  Any advice on bash script best practices are also welcome.
