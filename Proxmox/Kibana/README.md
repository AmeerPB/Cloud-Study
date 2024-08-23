### Install Kibana for accessing Traefik logs via ELasticsearch

#### Step 1. Install kibana

- Install elasticsearch first OR add the elastic repo details in apt. Otherwise kibana package will not be available

```bash

wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-8.x.list
sudo apt-get update && sudo apt-get install elasticsearch

```



`apt install kibana`


> [!NOTE]
> 
> Incase of the below error in `/var/log/kibana/kibana.log`


```bash

{"service":{"node":{"roles":["background_tasks","ui"]}},"ecs":{"version":"8.11.0"},"@timestamp":"2024-08-22T18:04:53.124+00:00","message":"Registering endpoint:user-artifact-packager task with timeout of [20m], interval of [60s] and policy update batch size of [25]","log":{"level":"INFO","logger":"plugins.securitySolution.endpoint:user-artifact-packager:1.0.0"},"process":{"pid":2271,"uptime":14.678670054},"trace":{"id":"408b729964903a9ccec452c8e52bb9f4"},"transaction":{"id":"0461c5647e25bb6b"}}
{"service":{"node":{"roles":["background_tasks","ui"]}},"ecs":{"version":"8.11.0"},"@timestamp":"2024-08-22T18:04:53.124+00:00","message":"Registering task [endpoint:complete-external-response-actions] with timeout of [5m] and run interval of [60s]","log":{"level":"INFO","logger":"plugins.securitySolution.endpoint:complete-external-response-actions"},"process":{"pid":2271,"uptime":14.679037549},"trace":{"id":"408b729964903a9ccec452c8e52bb9f4"},"transaction":{"id":"0461c5647e25bb6b"}}
{"service":{"node":{"roles":["background_tasks","ui"]}},"ecs":{"version":"8.11.0"},"@timestamp":"2024-08-22T18:04:54.505+00:00","message":"Unable to retrieve version information from Elasticsearch nodes. security_exception\n\tRoot causes:\n\t\tsecurity_exception: missing authentication credentials for REST request [/_nodes?filter_path=nodes.*.version%2Cnodes.*.http.publish_address%2Cnodes.*.ip]","log":{"level":"ERROR","logger":"elasticsearch-service"},"process":{"pid":2271,"uptime":16.059943807},"trace":{"id":"408b729964903a9ccec452c8e52bb9f4"},"transaction":{"id":"0461c5647e25bb6b"}}
{"service":{"node":{"roles":["background_tasks","ui"]}},"ecs":{"version":"8.11.0"},"@timestamp":"2024-08-22T18:04:55.201+00:00","message":"Browser executable: /usr/share/kibana/node_modules/@kbn/screenshotting-plugin/chromium/headless_shell-linux_x64/headless_shell","log":{"level":"INFO","logger":"plugins.screenshotting.chromium"},"process":{"pid":2271,"uptime":16.755999172},"trace":{"id":"408b729964903a9ccec452c8e52bb9f4"},"transaction":{"id":"0461c5647e25bb6b"}}

```


Open the `kibana.yml` file, which is usually located at `/etc/kibana/kibana.yml`.  
Add or update the following settings with your Elasticsearch credentials:  

```bash
elasticsearch.username: "elastic"
elasticsearch.password: "xxxxxxxxxxxxxxxxx"
```


After saving the changes to kibana.yml, restart the Kibana service to apply the new settings.  
 
`sudo systemctl restart kibana`




> [!NOTE]
> 
> incase of the below error


```bash

Aug 22 18:24:56 ELK-LXC kibana[2611]: [2024-08-22T18:24:56.740+00:00][INFO ][node] Kibana process configured with roles: [background_tasks, ui]
Aug 22 18:24:57 ELK-LXC systemd[1]: Stopping Kibana...
Aug 22 18:25:02 ELK-LXC kibana[2611]:  FATAL  Error: [config validation of [elasticsearch].username]: value of "elastic" is forbidden. This is a superuser>
Aug 22 18:25:02 ELK-LXC systemd[1]: kibana.service: Main process exited, code=exited, status=78/CONFIG

```

Use the elasticsearch-setup-passwords tool or the Kibana UI to create a new user with the necessary roles (e.g., kibana_system).  

```bash
curl -u 'elastic:*D9Ju2H_DWR5QCByrR89' -X POST "localhost:9200/_security/user/kibana_user" -H "Content-Type: application/json" -d'
{
  "password" : "*D9Ju2H_DWR5QCByrR89",
  "roles" : [ "kibana_system" ]
}'

```

### To use the elastic credentials in the curl command

```bash

root@ELK-LXC:~# curl -u 'elastic:xxxxxxxxxxxx' -X POST "localhost:9200/_security/user/kibana_user" -H "Content-Type: application/json" -d'
{
  "password" : "*D9Ju2H_DWR5QCByrR89",
  "roles" : [ "kibana_system" ]
}'

```

The above command will output `{"created":true}`.   

Then, Open the Kibana configuration file `/etc/kibana/kibana.yml` and update the ``elasticsearch.username`` and ``elasticsearch.password`` settings to use the new user credentials.

```bash
elasticsearch.username: "kibana_user"
elasticsearch.password: "your_password"

```








