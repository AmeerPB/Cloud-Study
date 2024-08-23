#### To deploy ElasticSearch and Kibana for viewing the Traefik logs

#### Step 1. Install ElasticSearch

> [!NOTE]
> 
> This install command will display the elastic built-in superuser password in the installation log.


```bash

wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-8.x.list
sudo apt-get update && sudo apt-get install elasticsearch

```
  

> [!NOTE]
> 
> In case of error regarding OOM kill, Increase the Elasticsearch Heap Size  

Elasticsearch uses a heap size defined by the -Xms and -Xmx parameters in the JVM options file (jvm.options). By default, these values might be set too high for your system's available memory.
Edit the /etc/elasticsearch/jvm.options file (or similar depending on your setup) and adjust the heap size.  

```bash
sudo nano /etc/elasticsearch/jvm.options
```

Lower the values of -Xms and -Xmx, for example:  

```bash
-Xms1g
-Xmx1g
```

Save the file and restart Elasticsearch:

```sudo systemctl restart elasticsearch```


> [!NOTE]
> 
> regarding the below error,

```bash
root@ELK-LXC:/var/log/elasticsearch# tail -f elasticsearch.log

[2024-08-22T17:52:36,962][WARN ][o.e.h.n.Netty4HttpServerTransport] [ELK-LXC] received plaintext http traffic on an https channel, closing connection Netty4HttpChannel{localAddress=/127.0.0.1:9200, remoteAddress=/127.0.0.1:34662}
[2024-08-22T17:54:18,894][WARN ][o.e.h.n.Netty4HttpServerTransport] [ELK-LXC] received plaintext http traffic on an https channel, closing connection Netty4HttpChannel{localAddress=/127.0.0.1:9200, remoteAddress=/127.0.0.1:40534}

```

in `/etc/elasticsearch/elasticsearch.yml`  

change from
```bash
# Enable encryption for HTTP API client connections, such as Kibana, Logstash, and Agents
xpack.security.http.ssl:
  enabled: true
  keystore.path: certs/http.p12
```

to  

```bash
# Enable encryption for HTTP API client connections, such as Kibana, Logstash, and Agents
xpack.security.http.ssl:
  enabled: false
  keystore.path: certs/http.p12
```


To view the elastic page with AUTH

```bash

root@ELK-LXC:/var/log/elasticsearch# curl -u 'elastic:<password-from-the-installation-log>' -X GET "http://localhost:9200/"
{
  "name" : "ELK-LXC",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "Ykhjo8eOSPOZP0wFqN_T1w",
  "version" : {
    "number" : "8.15.0",
    "build_flavor" : "default",
    "build_type" : "deb",
    "build_hash" : "1a77947f34deddb41af25e6f0ddb8e830159c179",
    "build_date" : "2024-08-05T10:05:34.233336849Z",
    "build_snapshot" : false,
    "lucene_version" : "9.11.1",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}

```





