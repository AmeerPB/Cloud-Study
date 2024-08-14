
#### Docker-compose

``` yaml

---
services:
  heimdall:
    image: lscr.io/linuxserver/heimdall:latest
    container_name: heimdall
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
    volumes:
      - /path/to/heimdall/config:/config
    ports:
      - 80:80
      - 443:443
    restart: unless-stopped



```

#### Docker-compose with traefik


``` yaml

  heimdall:
    image: lscr.io/linuxserver/heimdall:latest
    container_name: heimdall
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
    volumes:
      - heimdall_data:/config
    ports:
      - 8092:80
      - 8093:443
    restart: unless-stopped
    networks:
      - proxy
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.heimdall.entrypoints=http"
      - "traefik.http.routers.heimdall.rule=Host(`heimdall.xsec.in`)"
      - "traefik.http.middlewares.heimdall-https-redirect.redirectscheme.scheme=https"
      - "traefik.http.middlewares.sslheader.headers.customrequestheaders.X-Forwarded-Proto=https"
      - "traefik.http.routers.heimdall.middlewares=heimdall-https-redirect"
      - "traefik.http.routers.heimdall-secure.entrypoints=https"
      - "traefik.http.routers.heimdall-secure.rule=Host(`heimdall.xsec.in`)"
      - "traefik.http.routers.heimdall-secure.middlewares=traefik-auth"
      - "traefik.http.routers.heimdall-secure.tls=true"
      - "traefik.http.routers.heimdall-secure.tls.certresolver=cloudflare"
      - "traefik.http.routers.heimdall-secure.tls.domains[0].main=xsec.in"
      - "traefik.http.routers.heimdall-secure.tls.domains[0].sans=*.xsec.in"
      - "traefik.http.services.heimdall.loadbalancer.server.port=80"


```







