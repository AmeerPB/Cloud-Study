#### Deluge docker-compose artifacts

``` yaml
version: '3.5'

services:
  deluge:
    image: lscr.io/linuxserver/deluge:latest
    container_name: deluge
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Kolkata
      - DELUGE_LOGLEVEL=error #optional
    volumes:
#      - /path/to/deluge/config:/config
      - ./downloads:/downloads
    ports:
      - 8112:8112
      - 6881:6881
      - 6881:6881/udp
      - 58846:58846 #optional
    restart: unless-stopped
    networks:
      - proxy
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.deluge.entrypoints=http"
      - "traefik.http.routers.deluge.rule=Host(`deluge.xsec.in`)"
      - "traefik.http.middlewares.deluge-https-redirect.redirectscheme.scheme=https"
      - "traefik.http.middlewares.sslheader.headers.customrequestheaders.X-Forwarded-Proto=https"
      - "traefik.http.routers.deluge.middlewares=deluge-https-redirect"
      - "traefik.http.routers.deluge-secure.entrypoints=https"
      - "traefik.http.routers.deluge-secure.rule=Host(`deluge.xsec.in`)"
      - "traefik.http.routers.deluge-secure.middlewares=traefik-auth"
      - "traefik.http.routers.deluge-secure.tls=true"
      - "traefik.http.routers.deluge-secure.tls.certresolver=cloudflare"
      - "traefik.http.routers.deluge-secure.tls.domains[0].main=xsec.in"
      - "traefik.http.routers.deluge-secure.tls.domains[0].sans=*.xsec.in"
      - "traefik.http.services.deluge.loadbalancer.server.port=8112"

networks:
  proxy:
    name: proxy
    external: true


```

> [!NOTE]
> 
> Due to the label "- "traefik.http.routers.deluge-secure.middlewares=traefik-auth"", Delge Web UI will ask for the username/password which set via the htpasswd command in Treafik. 




