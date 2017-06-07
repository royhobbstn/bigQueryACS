# bigQueryACS
Automate loading of American Community Survey data into Google BigQuery


## Prerequisites:

I VERY highly recommend running this from a Google Compute Instance for performance reasons.

If you insist on running this elsewhere, you will need to have the gsutil and bq tools pre-installed.  You can get them by installing the Google Cloud SDK on the machine you wish to run the bigQueryACS script from.
I haven't tested on anything other than Debian, so your mileage may vary on other OS's.


If you plan on loading the entire ACS, allocate an Instance with *300GB*.  Also make sure to check the box that says *'ALLOW FULL ACCESS TO ALL CLOUD APIs'*.


Other than that, you will need to make sure you have unzip installed (the Google Compute instances I've tested with did not have it.)

```sudo apt-get install unzip```


## Installation:

Grab the script from my Github.

```wget https://raw.githubusercontent.com/royhobbstn/bigQueryACS/master/acs_co.sh```


## Using the Script

Like this for Colorado:
```
bash acs_co.sh co
```

More than one State?
```
bash acs_co.sh de co hi
```

All the States?  That's the default (will take a very long time, see below)
```
bash acs_co.sh
```


## Customization

By default, this script will load the data files into a bucket called ```acs1115_stage```.  It will create a BigQuery schema named ```acs1115```.
To change these defaults, edit the environmental variables at the top of the code block:

```sudo vi acs_co.sh```

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

*Using Delaware as a sample State with Debian GNU/Linux 8 (jessie) and 20GB SSD:*

f1-micro (SharedCPU, 0.6GB): *23min 04sec*

n1-standard-4 (4CPU, 15GB): *23min 07sec*

...hmmm the bottleneck appears to be the network.


*All US States with Debian GNU/Linux 8 (jessie) and 300GB SSD:*

n1-standard-1 (1 vCPU, 3.75 GB memory): 


# How do I use this data?

TODO: basic GUI query

You can use BigQuery through APIs written in [many different languages](https://cloud.google.com/bigquery/create-simple-app-api).
Here's some boilerplate NodeJS: [example.js](example.js)


# Sequence Number Tables?

Yeah, I know.  But the good thing about having the data already in BigQuery is that it's fairly easy to create individual table files.

TODO: SQL to convert Seq Tables into logical tables.


## Note: I'm probably doing it wrong

If it looks like I've never written a bash script before in my life, it's because I haven't.
I'd be interested in any help I can get to make this faster or improve platform compatibility.  Any advice on bash script best practices are also welcome.

In all honestly the script should probably be re-written in a language that can take more easily take advantage of multithreading and async io. (in due time)