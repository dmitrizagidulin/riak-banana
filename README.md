riak-banana
===========

Riak 2.0 + Riak Search/Solr + LucidWorks/banana

#### Introduction
Making sense of system log entries is the perfect task for a text search and indexing engine like Solr. 
In addition to the obvious use case of searching for particular error messages, the search engine's indexing 
and aggregation capabilities allow for near-real-time graphing, analysis and statistics functionality, 
which greatly helps the task of system administration.

Logstash is a general purpose tool for ingesting, transforming and outputting log messages from a variety of 
sources (for example ```syslog``` entries, Apache access logs, or Riak or other database logs).

The LucidWorks/[Banana](https://github.com/LucidWorks/banana) project is a port of the 
ElasticSearch/[Kibana](http://www.elasticsearch.org/overview/kibana/) graphing dashboard, converted and enhanced
to make it work with Solr (instead of ElasticSearch). It uses Logstash for capturing, transforming, and posting
log messages to Solr, and provides a friendly GUI to visualize and query the aggregated messages stored.

This project (Riak-Banana) provides Riak-specific installation and configuration instructions, 
for using the Logstash/Banana stack with Riak Seach 2.0.


### Installation (full stack, using Vagrant)
requires: [Vagrant](https://www.vagrantup.com/) (and therefore VirtualBox).

The goal is to hook in LucidWorks/banana into Riak2.0's solr interface, use Riak to store dashboards, etc, and riak to submit log data.

Currently Functional, needs cleaning/testing.

#### Status: WIP. Issues:

- dashboards should be stored in Riak
- actual entry values should be pulled from Riak instead of Solr
- break out riak, riakbanana, and java modules
- add example multi-node deployment
- add how-to without vagrant
- add OS tunings
- ~~nginx & logstash need to be restarted appropriately via puppet~~
- ~~hacky librarian-puppet issues due to windows /vagrant mounts should be worked around~~
- ~~race condition during 'vagrant up', need to run 'vagrant provision' after~~
- ~~uses ugly 'files' directory, referencing "/vagrant/files" in puppet modules, need to clean up~~
- ~~hitting local solr instead of Riak solr query interface, due to Banana requesting Solr Admin API calls~~

##### Creates 2 Nodes:

###### Rihanna01 - Server:
Installs and configures:
- Riak2.0, sets up default search index for bucket 'logstash_logs'
- Nginx to serve static banana files & route solr non-query api endpoints for banana
- https://github.com/LucidWorks/banana/

###### Client02 - Client (creates logs):
Installs and configures:
- Logstash
- Logstash contribs
- Syslog -> Riak logstash output plugin

###### Requirements

requires: vagrant, virtualbox

Vagrant box is based on Ubuntu

Vagrantfile tested on Windows & Mac

#### Usage:

```
git clone https://github.com/glickbot/riak-banana
cd riak-banana
vagrant up
```

Navigate to ```http://http://10.42.0.6/```

#### Configuration:

Configuration can be specified in riak-banana/puppet/hiera/common.yaml

Uses "roles" and "profiles" modules to apply modules to nodes.

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
[Banana](https://github.com/LucidWorks/banana) provides a Solr dashboard to visualize and query
aggregated log messages stored in and indexed by Solr. In the example below, we will be using it to
track the ```logstash_logs``` index.

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
    wget https://raw.githubusercontent.com/glickbot/riak-banana/master/puppet/modules/riakbanana/templates/riakbanana_schema.xml.erb -O riakbanana_schema.xml
    curl -XPUT -i 'http://localhost:8098/search/schema/logstash_logs' -H 'content-type: application/xml' --data-binary @riakbanana_schema.xml
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
sources.

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

#### Configuring Syslog
The intricacies of ```syslog``` configuration are beyond the scope of this document. The general idea, with 
syslog configuration, is to specify **which** events syslog should be logging, and **where** it should be logging
them. The following sample ```/etc/rsyslog.conf``` simply says to forward *all* events on a local machine
to port ```5140```:

```
*.*         @localhost:5140
```

#### Configuring Logstash Inputs and Outputs
Logstash requires configuration files, to specify the source of the log messages, which transformations (if any)
to apply to them, and where to output them.
In this example, we will use it to consume new ```syslog``` entries (that are incoming on port ```5140```) and 
insert them into Riak/Solr for indexing (and display via Banana). 

1. (Optional) Create a config directory for Logstash. This is where the config files with
    ```input``` and ```output``` directives will go:

    ```bash
    mkdir -p /etc/logstash
    ```
2. Create a Logstash config file, which tells it to listen for incoming ```syslog``` events, and 
    insert them into Riak (where they'll be indexed by Solr).

    ```/etc/logstash/syslog-riak.conf```

    ```ruby
input {
    syslog { port => 5140 }
}
output {
    riak {
        bucket => ["logstash_logs"]
        nodes => {"localhost" => "8098"}
    }
}
    ```

4. To launch Logstash, pass it in a particular configuration file:

    ```bash
    bin/logstash agent -v -f /etc/logstash/syslog-riak.conf
    ```

#### Usage:

Navigate to ```http://localhost:8093/internal_solr/banana/src/index.html```

Use ```http://localhost:8093/internal_solr``` for solr webapp

