class riakbanana::params {
	$index = logstash_logs
	$riak_host = localhost
	$riak_port = 8098
	$solr_webapp_dir = "/usr/lib/riak/lib/yokozuna-2.0.0-1-g6ac3a63/priv/solr/solr-webapp/webapp"
	$riak_url = "http://${riak_host}:${riak_port}"

}
