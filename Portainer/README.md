#### Deployment files for Portainer that goes with Traefik


> [!NOTE]
>
> ### Portainer with traefik docker-compose


``` yaml

version: '3.5'

services:
  traefik:
    image: traefik:latest
    container_name: traefik
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    networks:
       proxy:
    ports:
      - 80:80
      - 443:443
    environment:
      - CF_API_EMAIL=<EMAIL_ADDR>
      - CF_DNS_API_TOKEN=<CF_API_KEY>
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /home/ubuntu/docker/traefik/traefik.yml:/traefik.yml:ro
      - /home/ubuntu/docker/traefik/acme.json:/acme.json
      - /home/ubuntu/docker/traefik/config.yml:/config.yml:ro
      - /home/ubuntu/docker/traefik/logs:/var/log/traefik
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.traefik.entrypoints=http"
      - "traefik.http.routers.traefik.rule=Host(`traefik-dashboard.xsec.in`)"
      - "traefik.http.middlewares.traefik-auth.basicauth.users=<CREDS-FROM-httpasswd>"
      - "traefik.http.middlewares.traefik-https-redirect.redirectscheme.scheme=https"
      - "traefik.http.middlewares.sslheader.headers.customrequestheaders.X-Forwarded-Proto=https"
      - "traefik.http.routers.traefik.middlewares=traefik-https-redirect"
      - "traefik.http.routers.traefik-secure.entrypoints=https"
      - "traefik.http.routers.traefik-secure.rule=Host(`traefik-dashboard.xsec.in`)"
      - "traefik.http.routers.traefik-secure.middlewares=traefik-auth"
      - "traefik.http.routers.traefik-secure.tls=true"
      - "traefik.http.routers.traefik-secure.tls.certresolver=cloudflare"
      - "traefik.http.routers.traefik-secure.tls.domains[0].main=xsec.in"
      - "traefik.http.routers.traefik-secure.tls.domains[0].sans=*.xsec.in"
      - "traefik.http.routers.traefik-secure.service=api@internal"

  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    restart: unless-stopped
    networks:
      - proxy
    ports:
      - 9000:9000
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.portainer.rule=Host(`portainer.xsec.in`)"
      - "traefik.http.routers.portainer.entrypoints=http"
      - "traefik.http.middlewares.portainer-https-redirect.redirectscheme.scheme=https"
      - "traefik.http.routers.portainer.middlewares=portainer-https-redirect"
      - "traefik.http.routers.portainer-secure.entrypoints=https"
      - "traefik.http.routers.portainer-secure.rule=Host(`portainer.xsec.in`)"
      - "traefik.http.routers.portainer-secure.middlewares=traefik-auth"
      - "traefik.http.routers.portainer-secure.tls=true"
      - "traefik.http.routers.portainer-secure.tls.certresolver=cloudflare"
      - "traefik.http.services.portainer.loadbalancer.server.port=9000"

networks:
  proxy:
    name: proxy
    external: true

volumes:
  portainer_data:

```

> [!NOTE]
> #### Working docker-compose.yml with multiple containers with Traefik


``` yaml
version: '3.5'

services:
  traefik:
    image: traefik:v3.1.2
    container_name: traefik
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    networks:
       proxy:
    ports:
      - 80:80
      - 443:443
    environment:
      - CF_API_EMAIL=xxxxxxxxx@outlook.com
      - CF_DNS_API_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /home/ubuntu/docker/traefik/traefik.yml:/traefik.yml:ro
      - /home/ubuntu/docker/traefik/acme.json:/acme.json
      - /home/ubuntu/docker/traefik/config.yml:/config.yml:ro
      - /home/ubuntu/docker/traefik/logs:/var/log/traefik
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.traefik.entrypoints=http"
      - "traefik.http.routers.traefik.rule=Host(`traefik-dashboard.xsec.in`)"
      - "traefik.http.middlewares.traefik-auth.basicauth.users=admin:$$xxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      - "traefik.http.middlewares.traefik-https-redirect.redirectscheme.scheme=https"
      - "traefik.http.middlewares.sslheader.headers.customrequestheaders.X-Forwarded-Proto=https"
      - "traefik.http.routers.traefik.middlewares=traefik-https-redirect"
      - "traefik.http.routers.traefik-secure.entrypoints=https"
      - "traefik.http.routers.traefik-secure.rule=Host(`traefik-dashboard.xsec.in`)"
      - "traefik.http.routers.traefik-secure.middlewares=traefik-auth"
      - "traefik.http.routers.traefik-secure.tls=true"
      - "traefik.http.routers.traefik-secure.tls.certresolver=cloudflare"
      - "traefik.http.routers.traefik-secure.tls.domains[0].main=xsec.in"
      - "traefik.http.routers.traefik-secure.tls.domains[0].sans=*.xsec.in"
      - "traefik.http.routers.traefik-secure.service=api@internal"

  portainer:
    image: portainer/portainer-ce
    container_name: portainer
    restart: unless-stopped
    networks:
      - proxy
    ports:
      - 9000:9000
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.portainer.entrypoints=http"
      - "traefik.http.routers.portainer.rule=Host(`portainer.xsec.in`)"
      - "traefik.http.routers.portainer-secure.entrypoints=https"
      - "traefik.http.routers.portainer-secure.rule=Host(`portainer.xsec.in`)"
#      - "traefik.http.routers.portainer-secure.middlewares=traefik-auth"
      - "traefik.http.routers.portainer-secure.tls=true"
      - "traefik.http.routers.portainer-secure.tls.certresolver=cloudflare"
      - "traefik.http.routers.portainer-secure.tls.domains[0].main=xsec.in"
      - "traefik.http.routers.portainer-secure.tls.domains[0].sans=*.xsec.in"
      - "traefik.http.services.portainer.loadbalancer.server.port=9000"

#networks:
#  proxy:
#    name: proxy
#    external: true
#
#volumes:
#  portainer_data:
#    external: true

  nginx:
    image: nginx:1.27.0-alpine
    container_name: nginx
    restart: unless-stopped
    networks:
      - proxy
    ports:
      - 8090:8080
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./nginx/index.html:/usr/share/nginx/html/index.html
      - nginx_data:/data
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.nginx.entrypoints=http"
      - "traefik.http.routers.nginx.rule=Host(`nginx.xsec.in`)"
      - "traefik.http.routers.nginx-secure.entrypoints=https"
      - "traefik.http.routers.nginx-secure.rule=Host(`nginx.xsec.in`)"
#      - "traefik.http.routers.portainer-secure.middlewares=traefik-auth"
      - "traefik.http.routers.nginx-secure.tls=true"
      - "traefik.http.routers.nginx-secure.tls.certresolver=cloudflare"
      - "traefik.http.routers.nginx-secure.tls.domains[0].main=xsec.in"
      - "traefik.http.routers.nginx-secure.tls.domains[0].sans=*.xsec.in"
      - "traefik.http.services.nginx.loadbalancer.server.port=8080"

networks:
  proxy:
    name: proxy
    external: true

volumes:
  nginx_data:
    external: true
  portainer_data:
    external: true


```




