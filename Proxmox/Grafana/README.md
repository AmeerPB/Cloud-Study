#### Grafana installation docker-compose.yml


> [!TIP]
>
> Refer: https://grafana.com/docs/grafana/latest/setup-grafana/installation/docker/#run-grafana-via-docker-compose


#### simple Grafana with persistent storage

``` yaml
services:
  grafana:
    image: grafana/grafana-oss
    container_name: grafana
    restart: unless-stopped
    ports:
      - '3000:3000'
    volumes:
      - grafana_data:/var/lib/grafana
volumes:
  grafana_data: {}


```

#### With SSL via Traefik


``` yaml
version: '3.5'

services:
  grafana:
    image: grafana/grafana-oss
    container_name: grafana
    restart: unless-stopped
    networks:
      - proxy    
    ports:
      - '3000:3000'
    volumes:
      - grafana_data:/var/lib/grafana
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.grafana.entrypoints=http"
      - "traefik.http.routers.grafana.rule=Host(`grafana.xsec.in`)"
      - "traefik.http.routers.grafana-secure.entrypoints=https"
      - "traefik.http.routers.grafana-secure.rule=Host(`grafana.xsec.in`)"
#      - "traefik.http.routers.portainer-secure.middlewares=traefik-auth"
      - "traefik.http.routers.grafana-secure.tls=true"
      - "traefik.http.routers.grafana-secure.tls.certresolver=cloudflare"
      - "traefik.http.routers.grafana-secure.tls.domains[0].main=xsec.in"
      - "traefik.http.routers.grafana-secure.tls.domains[0].sans=*.xsec.in"
      - "traefik.http.services.grafana.loadbalancer.server.port=3000"

networks:
  proxy:
    name: proxy
    external: true

volumes:
  grafana_data: {}


```




