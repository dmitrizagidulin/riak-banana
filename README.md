riak-banana
===========

Riak2.0 + LucidWorks/banana

#### Status: WIP

#####Issues:
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

### Installation (using Vagrant)
requires: [vagrant](https://www.vagrantup.com/)

Vagrant box is based on Ubuntu

```
git clone https://github.com/glickbot/riak-banana
cd riak-banana
vagrant up
ssh-with-fwds
```

### Manual Installation (existing Riak+YZ)

#### Installing Banana 
If you have an existing Riak 2.0 + Solr installed (including Oracle Java 7), and would like to install Banana:

1. Locate the [Riak Solr webapp directory](https://github.com/basho/services-knowledgebase/blob/master/Customer%20FAQ.md#where-is-the-solr-webapp-directory).
    Generally located in ```<riak lib dir>/yokozuna-2.0.../priv/solr/solr-webapp/webapp/```.

2. CD to the Solr webapp directory, and clone the [banana](https://github.com/LucidWorks/banana) repo. For example:

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

#### Usage:

Navigate to ```http://localhost:8093/internal_solr/banana/src/index.html```

Use ```http://localhost:8093/internal_solr``` for solr webapp
