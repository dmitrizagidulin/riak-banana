riak-banana
===========

Riak2.0 + LucidWorks/banana

#### Introduction
Making sense of system log entries is the perfect task for a text search and indexing engine like Solr. 
In addition to the obvious use case of searching for particular error messages, the search engine's indexing 
and aggregation  capabilities allow for near-real-time graphing, analysis and statistics functionality, 
which greatly helps the task of system administration.

#### Status: WIP

##### Issues:
- race condition during 'vagrant up', need to run 'vagrant provision' after
- uses ugly 'files' directory, referencing "/vagrant/files" in puppet modules, need to clean up
- hitting local solr instead of Riak solr query interface, due to Banana requesting Solr Admin API calls
- dashboards should be stored in Riak
- actual entry values should be pulled from Riak instead of Solr

#### Notes
The goal is to hook in LucidWorks/banana into Riak2.0's solr interface, use Riak to store dashboards, etc, and riak to submit log data.

Currently Functional, needs cleaning/testing

Installs and configures Riak2.0, sets up default search index for bucket 'logstash_logs'

Installs and configures Logstash + Logstash contribs, configures riak logstash plugin

Installs banana

### Installation (full stack, using Vagrant)
requires: [vagrant](https://www.vagrantup.com/)

Vagrant box is based on Ubuntu

```
git clone https://github.com/glickbot/riak-banana
cd riak-banana
vagrant up
ssh-with-fwds
```

### Manual Installation (existing Riak+YZ)
If you have an existing Riak 2.0 + Solr installed (including Oracle Java 7), and would like to install Banana
and Logstash, follow the directions below.

Riak/Banana checklist:

1. Ensure Riak 2.0 is installed (we recommend using it with Oracle Java 7), and Search is enabled.
2. Install Banana into the Solr webapp dir and create a Solr index on a Riak bucket for the log messages
3. Install Logstash and Logstash-Contrib
4. Configure a log input source (such as ```syslog```), and an output (here, inserted into Riak + Solr)
5. Use the Banana dashboard to view and query the log messages (once Riak and Logstash are up and running)

#### Installing Banana 
The [Banana](https://github.com/LucidWorks/banana) project, by LucidWorks, is a port of the 
ElasticSearch [Kibana](http://www.elasticsearch.org/overview/kibana/) graphing dashboard, converted and enhanced
to make it work with Solr (instead of ElasticSearch). It provides a friendly GUI to visualize and query
aggregated log messages stored in and indexed by Solr. In the example below, we will be using it to
track a Solr index called ```logstash_logs```.

1. Locate the Riak Solr webapp directory.
    Generally located in ```<riak lib dir>/yokozuna-2.0.../priv/solr/solr-webapp/webapp/```.

2. ```cd``` to the Solr webapp directory, and clone the [banana](https://github.com/LucidWorks/banana) repo. 
    For example:

    ```bash
    cd /usr/lib/riak/lib/yokozuna-2.0.0-0-geb4919c/priv/solr/solr-webapp/webapp
    git clone https://github.com/LucidWorks/banana.git
    ```

3. (Still in the solr webapp directory) Copy the Dashboard .json file into the banana dashboard directory:

    ```bash
    wget https://raw.githubusercontent.com/glickbot/riak-banana/master/puppet/modules/riakbanana/templates/dashboard.json.erb
    mv dashboard.json.erb banana/src/app/dashboards/default.json
    ```
4. Download and install the Logstash Solr schema:

    ```bash
    wget https://raw.githubusercontent.com/glickbot/riak-banana/master/files/logstash_logs.xml
    curl -XPUT -i 'http://localhost:8098/search/schema/logstash_logs' -H 'content-type: application/xml' --data-binary @logstash_logs.xml
    ```
5. Create the index (and use the uploaded schema):
    ```bash
    curl -XPUT -i 'http://localhost:8098/search/index/logstash_logs' -H 'content-type: application/json' -d '{"schema":"logstash_logs"}'
    ```

6. Configure the bucket to use the ```logstash_logs``` index:
    ```bash
    curl -i -H 'content-type: application/json' -XPUT 'http://localhost:8098/buckets/logstash_logs/props' -d'{"props":{"search_index":"logstash_logs"}}'
    ```

#### Installing Logstash
Logstash is a general purpose tool for ingesting, transforming and outputting log messages from a variety of 
sources (for example ```syslog``` entries, Apache access logs, or Riak logs). In this example, we will use it
to consume new ```syslog``` entries and insert them into Riak/Solr for indexing (and display via Banana).

1. Download the Logstash base package, install it to ```/opt/logstash-1.4.0``` (you might have to adjust 
    directory permissions accordingly):

    ```bash
    wget https://download.elasticsearch.org/logstash/logstash/logstash-1.4.0.tar.gz
    tar -xvzf logstash-1.4.0.tar.gz -C /opt/
    ```
2. Go into the logstash directory and install logstash-contrib

    ```bash
    cd /opt/logstash-1.4.0
    bin/plugin install contrib
    ```
3. (Optional) Create a config directory for Logstash. This is where the config files with
    ```input``` and ```output``` directives will go:

    ```bash
    mkdir -p /etc/logstash
    ```
4. To launch Logstash, pass it in a particular configuration file (in this case, ```syslog-riak.conf``` -
    see Configuring Logstash section below for discussion):

    ```bash
    bin/logstash agent -v -f /etc/logstash/syslog-riak.conf
    ```

#### Configuring Logstash Inputs and Outputs

#### Usage:

Navigate to ```http://localhost:8093/internal_solr/banana/src/index.html```

Use ```http://localhost:8093/internal_solr``` for solr webapp
