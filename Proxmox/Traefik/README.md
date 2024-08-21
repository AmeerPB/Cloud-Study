> [!NOTE]
>
> #### Docker-compose.yml for Traefik with multiple containers

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


#### Docker-compose.yml for Traefik with enabling the access Log feature

```docker-compose.yml```

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
      - CF_API_EMAIL=xxxxxxxxxxxx@outlook.com
      - CF_DNS_API_TOKEN=xxxxxxxxxxxxxxxxxxxxx
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /home/ubuntu/docker/traefik/traefik.yml:/traefik.yml:ro
      - /home/ubuntu/docker/traefik/acme.json:/acme.json
      - /home/ubuntu/docker/traefik/config.yml:/config.yml:ro
      - /home/ubuntu/docker/traefik/logs:/var/log/traefik
    command:
      - "--api.insecure=true"
      - "--providers.docker=true"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--accesslog=true"
      - "--accesslog.filepath=/var/log/traefik/access.log"
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.traefik.entrypoints=http"
      - "traefik.http.routers.traefik.rule=Host(`traefik-dashboard.xsec.in`)"
      - "traefik.http.middlewares.traefik-auth.basicauth.users=admin:xxxxxxxxxxxxxxxxxxxxxxx"
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

```

```traefik.yml```

```yaml

api:
  dashboard: true
  debug: true
entryPoints:
  http:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: https
          scheme: https
  https:
    address: ":443"
serversTransport:
  insecureSkipVerify: true
providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
  file:
    filename: /config.yml
certificatesResolvers:
  cloudflare:
    acme:
      email: xxxxxxx@outlook.com
      storage: acme.json
      dnsChallenge:
        provider: cloudflare
        #disablePropagationCheck: true # uncomment this if you have issues pulling certificates through cloudflare, By setting this flag to true disables the need to wait for the propagation of the TXT record to all authoritative name servers.
        resolvers:
          - "1.1.1.1:53"
          - "1.0.0.1:53"
accessLog:
  filePath: "/var/log/traefik/access.log"



```


#### To enable Tracing with OpenTelemetry and Jaeger

> [!NOTE]
> 
> See the rest of the Jaeger and openTelemetry docker-compose.yml and config files for a complete setup artifacts

`docker-compose.yml`

``` yaml
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
      - 8082:8082
#     environment:
#       - CF_API_EMAIL=xxxx@xxxxx.ru
#       - CF_DNS_API_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /home/ubuntu/docker/traefik/traefik.yml:/traefik.yml:ro
      - /home/ubuntu/docker/traefik/acme.json:/acme.json
      - /home/ubuntu/docker/traefik/config.yml:/config.yml:ro
      - /home/ubuntu/docker/traefik/logs:/var/log/traefik
    command:
      - "--api.insecure=true"
      - "--providers.docker=true"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--entrypoints.metrics.address=:8082"
      - "--metrics.prometheus=true"
      - "--metrics.prometheus.entrypoint=metrics"
      - "--accesslog=true"
      - "--accesslog.filepath=/var/log/traefik/access.log"
      #- "--tracing.jaeger=true"  # Enable Jaeger tracing
      - "--tracing.otlp=true"
      - "--tracing.otlp.endpoint=http://192.168.1.20:4318"  
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.traefik.entrypoints=http"
      - "traefik.http.routers.traefik.rule=Host(`traefik-dashboard.xsec.in`)"
      - "traefik.http.middlewares.traefik-auth.basicauth.users=admin:xxxxxxxxxxxxxxxxxxxxxxxxxxxx"
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

networks:
  proxy:
    name: proxy
    external: true


```

`traefik.yml`

```yaml
api:
  dashboard: true
  debug: true
entryPoints:
  http:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: https
          scheme: https
  https:
    address: ":443"
  metrics:
    address: ":8082"
serversTransport:
  insecureSkipVerify: true
providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
  file:
    filename: /config.yml
certificatesResolvers:
  cloudflare:
    acme:
      email: xxxxx@xxxxx.ru
      storage: acme.json
      dnsChallenge:
        provider: cloudflare
        resolvers:
          - "1.1.1.1:53"
          - "1.0.0.1:53"
accessLog:
  filePath: "/var/log/traefik/access.log"
metrics:
  prometheus:
    entryPoint: metrics
    addEntryPointsLabels: true
    addServicesLabels: true
    buckets:
      - 0.1
      - 0.3
      - 1.2
      - 5.0

tracing:
  otlp:
    http:
      endpoint: http://192.168.1.20:4318


```




