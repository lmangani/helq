nprobe-facetflow
================

nProbe Integration with FacetFlow Hosted ES ("nELK")

![ntop](http://www.ntop.org/wp-content/uploads/2011/08/logo_new_m.png)


#Quick Ubuntu Setup:

In this example, we'll be using:

* nprobe: capturing and sending json reports to Logstash on port 5656
* logstash: receiving json logs and forwarding to to local nginx on port 19200
* kibana: connecting to facetflow w/ user authentication option
* nginx: reverse proxying http & authenticating logstash to facetflow using HTTPS

Note: A free or paid account at Facetflow is required.



## ![](http://www.ntop.org/wp-content/uploads/2011/08/nboxLogo.gif) Installation
### nProbe Setup
```
lsb=$(lsb_release -r | awk '{print $2}');
sudo wget http://www.nmon.net/apt/$lsb/all/apt-ntop.deb
sudo dpkg -i apt-ntop.deb
sudo apt-get update
sudo apt-get install -y --force-yes pfring nprobe
sudo rm -rf ./apt-ntop.deb
```

### Logstash Setup
```
sudo wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install -y --force-yes logstash
```

### Nginx Setup
```
apt-get install nginx

```

### Kibana Setup
```
cd /usr/src
git clone https://github.com/elasticsearch/kibana
mkdir /usr/share/nginx/kibana
cp -r kibana/src/* /usr/share/nginx/kibana/
```
Edit the elasticsearch parameter in /usr/share/nginx/kibana/config.js:
```
 elasticsearch: { server: "{YOUR_ID}.facetflow.io", withCredentials: true }
```

----------------

## ![](http://www.ntop.org/wp-content/uploads/2011/08/nboxLogo.gif) Configuration
### FacetFlow
Sign up for a free account/package at FacetFlow.com and get your API_KEY



### Logstash
```
input {
  tcp {
    type => "nProbe"
    port => 5656
    codec => json_lines
  }
}

output {
  if [type] == "nProbe" { 
    elasticsearch_http {
    host => "127.0.0.1"
    port => 19200
    user => "{YOUR_API_KEY}"
    }
  }
}
```
### nginx

Convert your API KEY to base64 for HTTP Authentication (keep the :)
```
echo {API_KEY}: | base64
```

Paste the following configuration in /etc/nginx/sites-enabled/logstash_fwd.conf
```
server {
    listen       19200;
    server_name  {YOUR_ID}.facetflow.io;

    error_log   facetflow-errors.log;
    access_log  facetflow.log;

    location / {

      # Deny access to Cluster API
      if ($request_filename ~ "_cluster") {
        return 403;
        break;
      }
      # Pass requests to ElasticSearch
      proxy_pass https://{YOUR_ID}.facetflow.io;
      proxy_redirect off;
      proxy_set_header  Host $proxy_host;
      # Route all requests to authorized user's own index
      #rewrite  ^(.*)$ $1  break;
      rewrite_log on;
    }
}

```
----------------


## ![](http://www.ntop.org/wp-content/uploads/2011/08/nboxLogo.gif) Start your Engines!
### Nginx
```service nginx start```

### Logstash
```service logstash start```

### nProbe
```
$ nprobe -T "%IPV4_SRC_ADDR %L4_SRC_PORT %IPV4_DST_ADDR %L4_DST_PORT %PROTOCOL %IN_BYTES %OUT_BYTES %FIRST_SWITCHED %LAST_SWITCHED %IN_PKTS %OUT_PKTS %IP_PROTOCOL_VERSION %APPLICATION_ID %L7_PROTO_NAME %ICMP_TYPE %SRC_IP_COUNTRY %DST_IP_COUNTRY %APPL_LATENCY_MS" --tcp "127.0.0.1:5656" -b 0 -i any --json-labels -t 30
```

----------------

That's all! Your nProbe template metrics should appear in your FacetFlow-powered "nELK" stack

![](http://www.nuxeo.com/blog/wp-content/uploads/2014/04/kibana-300x132.png)

You can import our nProbe Template dashboards to quick start or model your own.

For more information about nProbe visit: http://www.ntop.org/products/nprobe/
