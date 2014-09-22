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

#### Installation (using Vagrant)
requires: [vagrant](https://www.vagrantup.com/)

Vagrant box is based on Ubuntu

```
git clone https://github.com/glickbot/riak-banana
cd riak-banana
vagrant up
ssh-with-fwds
```

#### Installation (manual, existing Riak+YZ)
If you have an existing Riak 2.0 + Solr installed (including Oracle Java 7), and would like to install Banana:

1) Locate the [Riak Solr webapp directory](https://github.com/basho/services-knowledgebase/blob/master/Customer%20FAQ.md#where-is-the-solr-webapp-directory).
    Generally located in ```<riak lib dir>/yokozuna-2.0.../priv/solr/solr-webapp/```.

2) ...

#### Usage:

Navigate to ```http://localhost:8093/internal_solr/banana/src/index.html```

Use ```http://localhost:8093/internal_solr``` for solr webapp
