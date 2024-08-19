#### Install prometheus via docker-compose.yml


`docker-compose.yml`

``` yaml
# version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    restart: unless-stopped
    networks:
      - proxy      
    ports:
      - "9090:9090"
    volumes:
      - prometheus_config:/etc/prometheus
      - prometheus_data:/prometheus
    command:
      - "--config.file=/etc/prometheus/prometheus.yml"
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.prometheus.entrypoints=http"
      - "traefik.http.routers.prometheus.rule=Host(`prometheus.xsec.in`)"
      - "traefik.http.routers.prometheus-secure.entrypoints=https"
      - "traefik.http.routers.prometheus-secure.rule=Host(`prometheus.xsec.in`)"
#      - "traefik.http.routers.portainer-secure.middlewares=traefik-auth"
      - "traefik.http.routers.prometheus-secure.tls=true"
      - "traefik.http.routers.prometheus-secure.tls.certresolver=cloudflare"
      - "traefik.http.routers.prometheus-secure.tls.domains[0].main=xsec.in"
      - "traefik.http.routers.prometheus-secure.tls.domains[0].sans=*.xsec.in"
      - "traefik.http.services.prometheus.loadbalancer.server.port=9090"

networks:
  proxy:
    name: proxy
    external: true
volumes:
  prometheus_data: {}
  prometheus_config: {}
        

```


`prometheus.yml`


``` yaml
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds.

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']


```

#### With node exporter

`prometheus.yml`

``` yaml
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds.

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']

```



> [!NOTE]
>
> #### Working codes


#### Docker compose for Prometheus and Node-Exporter


```yaml
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    restart: unless-stopped
    network_mode: host
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.prometheus.entrypoints=http"
      - "traefik.http.routers.prometheus.rule=Host(`prometheus.xsec.in`)"
      - "traefik.http.routers.prometheus-secure.entrypoints=https"
      - "traefik.http.routers.prometheus-secure.rule=Host(`prometheus.xsec.in`)"
      - "traefik.http.routers.prometheus-secure.tls=true"
      - "traefik.http.routers.prometheus-secure.tls.certresolver=cloudflare"
      - "traefik.http.routers.prometheus-secure.tls.domains[0].main=xsec.in"
      - "traefik.http.routers.prometheus-secure.tls.domains[0].sans=*.xsec.in"
      - "traefik.http.services.prometheus.loadbalancer.server.port=9090"

  node_exporter:
    image: quay.io/prometheus/node-exporter:latest
    container_name: node_exporter
    command:
      - '--path.rootfs=/host'
    network_mode: host
    pid: host
    restart: unless-stopped
    volumes:
      - '/:/host:ro,rslave'

volumes:
  prometheus_data: {}



```

`Prometheus.yml` file

```yaml

global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds.

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']


```











