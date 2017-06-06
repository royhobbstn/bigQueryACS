# bigQueryACS
Automate loading of American Community Survey data into Google BigQuery


## Prerequisites:

You will need to have the gsutil and bq tools pre-installed.  You can get the by installing the Google Cloud SDK on the machine you wish to run the bigQueryACS script from.

If you are running this script from a Google Compute instance (VERY highly recomended for performance reasons), these tools are already pre-installed.
ALLOW FULL ACCESS TO ALL CLOUD APIs

Other than that, you will need to make sure you have unzip installed (the Google Compute instances I've tested with did not have it.)

```sudo apt-get install unzip```

## Installation:

Grab the script from my Github.

```wget https://raw.githubusercontent.com/royhobbstn/bigQueryACS/master/acs_co.sh```

Edit the environmental variables at the top of the code block:

```sudo vi acs_co.sh```

You'll see something like:

```
#configure these variables
databucket=acs1115_stage;
bigqueryschema=acs1115;
```

These correspond to the Google Storage Bucket and Google Big Query Schemas you would like to use.  Give them unique names that make sense to you (if unfamiliar with VIM, press the 'i' key to start editing).  

Then [exit VIM]((https://stackoverflow.blog/2017/05/23/stack-overflow-helping-one-million-developers-exit-vim/).


## Using the Script

Like this:
```
bash acs_co.sh de
```

More than one State?
```
bash acs_co.sh de co hi
```

All the States?
```
bash acs_co.sh
```

TODO: special instructions for running all states


# Benchmarks

These were not made to brag about how fast the script is (it's not!).  Rather, it should give you an idea of how long you can expect to wait for processing to complete.

All Benchmarks were run using Delaware as a sample State with Debian GNU/Linux 8 (jessie) and 20GB SSD:

f1-micro (SharedCPU, 0.6GB): *23min 04sec*

n1-standard-4 (4CPU, 15GB): **23min 07sec*

...hmmm the bottleneck appears to be the network.

# How do I use this data?

TODO: basic GUI query

TODO: Show NodeJS example


# Sequence Number Tables?

TODO: SQL to convert Seq Tables into logical tables.


# This code sucks

If it looks like I've never written a bash script before in my life, it's because I haven't.
I'd be interested in any help I can get to make this faster or improve platform compatibility.  Any advice on bash script best practices are also welcome.