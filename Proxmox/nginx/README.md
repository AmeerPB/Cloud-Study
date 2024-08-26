> [!NOTE]
>
> #### Docker-compose.yml for Treafik with nginx and other containers
> Working code


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
      - CF_API_EMAIL=xxxxxxxx@outlook.com
      - CF_DNS_API_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
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
      - "traefik.http.middlewares.traefik-auth.basicauth.users=admin:xxxxxxxxxxxxxxxxxxxxxxxxxx"
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
      - 8090:80
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
      - "traefik.http.services.nginx.loadbalancer.server.port=80"

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


#### Multiple NGINX containers with docker-compose



Version -1

```yaml

services:
  nginx:
    image: nginx:1.27.0-alpine
    container_name: nginx1
    restart: unless-stopped
    networks:
      - proxy
    ports:
      - 8090:80
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./site1/index.html:/usr/share/nginx/html/index.html
      - site1_data:/data
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.nginx.entrypoints=http"
      - "traefik.http.routers.nginx.rule=Host(`website1.xsec.in`)"
      - "traefik.http.routers.nginx-secure.entrypoints=https"
      - "traefik.http.routers.nginx-secure.rule=Host(`website.xsec.in`)"
#      - "traefik.http.routers.portainer-secure.middlewares=traefik-auth"
      - "traefik.http.routers.nginx-secure.tls=true"
      - "traefik.http.routers.nginx-secure.tls.certresolver=cloudflare"
      - "traefik.http.routers.nginx-secure.tls.domains[0].main=xsec.in"
      - "traefik.http.routers.nginx-secure.tls.domains[0].sans=*.xsec.in"
      - "traefik.http.services.nginx.loadbalancer.server.port=80"

  nginx2:
    image: nginx:1.27.0-alpine
    container_name: nginx2
    restart: unless-stopped
    networks:
      - proxy
    ports:
      - 8095:80
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./site2/:/usr/share/nginx/html/
      - site2_data:/data
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.nginx2.entrypoints=http"
      - "traefik.http.routers.nginx2.rule=Host(`website2.xsec.in`)"
      - "traefik.http.routers.nginx2-secure.entrypoints=https"
      - "traefik.http.routers.nginx2-secure.rule=Host(`website2.xsec.in`)"
#      - "traefik.http.routers.portainer-secure.middlewares=traefik-auth"
      - "traefik.http.routers.nginx2-secure.tls=true"
      - "traefik.http.routers.nginx2-secure.tls.certresolver=cloudflare"
      - "traefik.http.routers.nginx2-secure.tls.domains[0].main=xsec.in"
      - "traefik.http.routers.nginx2-secure.tls.domains[0].sans=*.xsec.in"
      - "traefik.http.services.nginx2.loadbalancer.server.port=80"


# Without SSL

  nginx3:
    image: nginx:1.27.0-alpine
    container_name: nginx3
    restart: unless-stopped
    networks:
      - proxy
    ports:
      - 8096:80
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./site3/:/usr/share/nginx/html/
      - site3_data:/data
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.nginx3.entrypoints=http"
      - "traefik.http.routers.nginx3.rule=Host(`website3.xsec.in`)"
      #- "traefik.http.routers.nginx3-secure.entrypoints=https"
      #- "traefik.http.routers.nginx3-secure.rule=Host(`website.xsec.in`)"
      #- "traefik.http.routers.portainer-secure.middlewares=traefik-auth"
      #- "traefik.http.routers.nginx3-secure.tls=true"
      #- "traefik.http.routers.nginx3-secure.tls.certresolver=cloudflare"
      #- "traefik.http.routers.nginx3-secure.tls.domains[0].main=xsec.in"
      #- "traefik.http.routers.nginx3-secure.tls.domains[0].sans=*.xsec.in"
      - "traefik.http.services.nginx3.loadbalancer.server.port=80"

# With SSL and AUTH

  nginx4:
    image: nginx:1.27.0-alpine
    container_name: nginx4
    restart: unless-stopped
    networks:
      - proxy
    ports:
      - 8097:80
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./site4/:/usr/share/nginx/html/
      - site4_data:/data
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.nginx4.entrypoints=http"
      - "traefik.http.routers.nginx4.rule=Host(`website4.xsec.in`)"
      - "traefik.http.routers.nginx4-secure.entrypoints=https"
      - "traefik.http.routers.nginx4-secure.rule=Host(`website4.xsec.in`)"
      - "traefik.http.routers.portainer-secure.middlewares=traefik-auth"
      - "traefik.http.routers.nginx4-secure.tls=true"
      - "traefik.http.routers.nginx4-secure.tls.certresolver=cloudflare"
      - "traefik.http.routers.nginx4-secure.tls.domains[0].main=xsec.in"
      - "traefik.http.routers.nginx4-secure.tls.domains[0].sans=*.xsec.in"
      - "traefik.http.services.nginx4.loadbalancer.server.port=80"

networks:
  proxy:
    name: proxy
    external: true

volumes:
  site1_data:
    external: true
  site2_data:
    external: true
  site3_data:
    external: true
  site4_data:
    external: true

```


Version -2

```yaml

services:
  nginx:
    image: nginx:1.27.0-alpine
    container_name: nginx1
    restart: unless-stopped
    networks:
      - proxy
    ports:
      - 8090:80
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./site1/index.html:/usr/share/nginx/html/index.html
      - site1_data:/data
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.nginx.entrypoints=http"
      - "traefik.http.routers.nginx.rule=Host(`website1.xsec.in`)"
      - "traefik.http.routers.nginx-secure.entrypoints=https"
      - "traefik.http.routers.nginx-secure.rule=Host(`website1.xsec.in`)"
#      - "traefik.http.routers.portainer-secure.middlewares=traefik-auth"
      - "traefik.http.routers.nginx-secure.tls=true"
      - "traefik.http.routers.nginx-secure.tls.certresolver=cloudflare"
      - "traefik.http.routers.nginx-secure.tls.domains[0].main=xsec.in"
      - "traefik.http.routers.nginx-secure.tls.domains[0].sans=*.xsec.in"
      - "traefik.http.services.nginx.loadbalancer.server.port=80"

  nginx2:
    image: nginx:1.27.0-alpine
    container_name: nginx2
    restart: unless-stopped
    networks:
      - proxy
    ports:
      - 8095:80
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./site2/:/usr/share/nginx/html/
      - site2_data:/data
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.nginx2.entrypoints=http"
      - "traefik.http.routers.nginx2.rule=Host(`website2.xsec.in`)"
      - "traefik.http.routers.nginx2-secure.entrypoints=https"
      - "traefik.http.routers.nginx2-secure.rule=Host(`website2.xsec.in`)"
#      - "traefik.http.routers.portainer-secure.middlewares=traefik-auth"
      - "traefik.http.routers.nginx2-secure.tls=true"
      - "traefik.http.routers.nginx2-secure.tls.certresolver=cloudflare"
      - "traefik.http.routers.nginx2-secure.tls.domains[0].main=xsec.in"
      - "traefik.http.routers.nginx2-secure.tls.domains[0].sans=*.xsec.in"
      - "traefik.http.services.nginx2.loadbalancer.server.port=80"


# Without SSL

  nginx3:
    image: nginx:1.27.0-alpine
    container_name: nginx3
    restart: unless-stopped
    networks:
      - proxy
    ports:
      - 8096:80
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./site3/:/usr/share/nginx/html/
      - site3_data:/data
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.nginx3.entrypoints=http"
      - "traefik.http.routers.nginx3.rule=Host(`website3.xsec.in`)"
      #- "traefik.http.routers.nginx3-secure.entrypoints=https"
      #- "traefik.http.routers.nginx3-secure.rule=Host(`website.xsec.in`)"
      #- "traefik.http.routers.portainer-secure.middlewares=traefik-auth"
      #- "traefik.http.routers.nginx3-secure.tls=true"
      #- "traefik.http.routers.nginx3-secure.tls.certresolver=cloudflare"
      #- "traefik.http.routers.nginx3-secure.tls.domains[0].main=xsec.in"
      #- "traefik.http.routers.nginx3-secure.tls.domains[0].sans=*.xsec.in"
      - "traefik.http.services.nginx3.loadbalancer.server.port=80"

# With SSL and AUTH

  nginx4:
    image: nginx:1.27.0-alpine
    container_name: nginx4
    restart: unless-stopped
    networks:
      - proxy
    ports:
      - 8097:80
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./site4/:/usr/share/nginx/html/
      - site4_data:/data
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.nginx4.entrypoints=http"
      - "traefik.http.routers.nginx4.rule=Host(`website4.xsec.in`)"
      - "traefik.http.routers.nginx4-secure.entrypoints=https"
      - "traefik.http.routers.nginx4-secure.rule=Host(`website4.xsec.in`)"
      - "traefik.http.routers.nginx4-secure.middlewares=traefik-auth"
      - "traefik.http.routers.nginx4-secure.tls=true"
      - "traefik.http.routers.nginx4-secure.tls.certresolver=cloudflare"
      - "traefik.http.routers.nginx4-secure.tls.domains[0].main=xsec.in"
      - "traefik.http.routers.nginx4-secure.tls.domains[0].sans=*.xsec.in"
      - "traefik.http.services.nginx4.loadbalancer.server.port=80"

networks:
  proxy:
    name: proxy
    external: true

volumes:
  site1_data:
    external: true
  site2_data:
    external: true
  site3_data:
    external: true
  site4_data:
    external: true

```

`Version -3`

#### With custom error pages


``` yaml

ubuntu@Docker-1-LXC:~/docker-compose/Nginx$ cat docker-compose.yml
services:
  nginx:
    image: nginx:1.27.0-alpine
    container_name: nginx1
    restart: unless-stopped
    networks:
      - proxy
    ports:
      - 8090:80
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./site1/index.html:/usr/share/nginx/html/index.html
      - site1_data:/data
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.nginx.entrypoints=http"
      - "traefik.http.routers.nginx.rule=Host(`website1.xsec.in`)"
      - "traefik.http.routers.nginx-secure.entrypoints=https"
      - "traefik.http.routers.nginx-secure.rule=Host(`website1.xsec.in`)"
#      - "traefik.http.routers.portainer-secure.middlewares=traefik-auth"
      - "traefik.http.routers.nginx-secure.tls=true"
      - "traefik.http.routers.nginx-secure.tls.certresolver=cloudflare"
      - "traefik.http.routers.nginx-secure.tls.domains[0].main=xsec.in"
      - "traefik.http.routers.nginx-secure.tls.domains[0].sans=*.xsec.in"
      - "traefik.http.services.nginx.loadbalancer.server.port=80"

  nginx2:
    image: nginx:1.27.0-alpine
    container_name: nginx2
    restart: unless-stopped
    networks:
      - proxy
    ports:
      - 8095:80
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./site2/:/usr/share/nginx/html/
      - site2_data:/data
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.nginx2.entrypoints=http"
      - "traefik.http.routers.nginx2.rule=Host(`website2.xsec.in`)"
      - "traefik.http.routers.nginx2-secure.entrypoints=https"
      - "traefik.http.routers.nginx2-secure.rule=Host(`website2.xsec.in`)"
#      - "traefik.http.routers.portainer-secure.middlewares=traefik-auth"
      - "traefik.http.routers.nginx2-secure.tls=true"
      - "traefik.http.routers.nginx2-secure.tls.certresolver=cloudflare"
      - "traefik.http.routers.nginx2-secure.tls.domains[0].main=xsec.in"
      - "traefik.http.routers.nginx2-secure.tls.domains[0].sans=*.xsec.in"
      - "traefik.http.services.nginx2.loadbalancer.server.port=80"


# Without SSL

#  nginx3:
#    image: nginx:1.27.0-alpine
#    container_name: nginx3
#    restart: unless-stopped
#    networks:
#      - proxy
#    ports:
#      - 10000:80
#    volumes:
#      - /var/run/docker.sock:/var/run/docker.sock
#      - ./site3/:/usr/share/nginx/html/
#      - site3_data:/data
#    labels:
#      - "traefik.enable=true"
#      - "traefik.http.routers.nginx3.entrypoints=http"
#      - "traefik.http.routers.nginx3.rule=Host(`website3.xsec.in`)"
#      #- "traefik.http.routers.nginx3-secure.entrypoints=https"
#      #- "traefik.http.routers.nginx3-secure.rule=Host(`website.xsec.in`)"
#      #- "traefik.http.routers.portainer-secure.middlewares=traefik-auth"
#      #- "traefik.http.routers.nginx3-secure.tls=true"
#      #- "traefik.http.routers.nginx3-secure.tls.certresolver=cloudflare"
#      #- "traefik.http.routers.nginx3-secure.tls.domains[0].main=xsec.in"
#      #- "traefik.http.routers.nginx3-secure.tls.domains[0].sans=*.xsec.in"
#      - "traefik.http.services.nginx3.loadbalancer.server.port=80"

# With SSL and AUTH

  nginx4:
    image: nginx:1.27.0-alpine
    container_name: nginx4
    restart: unless-stopped
    networks:
      - proxy
    ports:
      - 8097:80
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./site4/:/usr/share/nginx/html/
      - site4_data:/data
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.nginx4.entrypoints=http"
      - "traefik.http.routers.nginx4.rule=Host(`website4.xsec.in`)"
      - "traefik.http.routers.nginx4-secure.entrypoints=https"
      - "traefik.http.routers.nginx4-secure.rule=Host(`website4.xsec.in`)"
      - "traefik.http.routers.nginx4-secure.middlewares=traefik-auth"
      - "traefik.http.routers.nginx4-secure.tls=true"
      - "traefik.http.routers.nginx4-secure.tls.certresolver=cloudflare"
      - "traefik.http.routers.nginx4-secure.tls.domains[0].main=xsec.in"
      - "traefik.http.routers.nginx4-secure.tls.domains[0].sans=*.xsec.in"
      - "traefik.http.services.nginx4.loadbalancer.server.port=80"

# With AUTH and custom error page

  nginx5:
    image: nginx:1.27.0-alpine
    container_name: nginx5
    restart: unless-stopped
    networks:
      - proxy
    ports:
      - 10001:80
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./site5/:/usr/share/nginx/html/
      - site5_data:/data
    labels:
      - "traefik.enable=true"
      # HTTP entrypoint
      - "traefik.http.routers.nginx5.entrypoints=http"
      - "traefik.http.routers.nginx5.rule=Host(`website5.xsec.in`)"
      # HTTPS entrypoint
      - "traefik.http.routers.nginx5-secure.entrypoints=https"
      - "traefik.http.routers.nginx5-secure.rule=Host(`website5.xsec.in`)"
      - "traefik.http.routers.nginx5-secure.tls=true"
      - "traefik.http.services.nginx5.loadbalancer.server.port=80"
      # nginx5-errors MiddleWare for custom error pages
      - "traefik.http.middlewares.nginx5-errors.errors.status=404-499,500-599"
      - "traefik.http.middlewares.nginx5-errors.errors.service=error-pages"
      - "traefik.http.middlewares.nginx5-errors.errors.query=/{status}.html"
      - "traefik.http.routers.nginx5.middlewares=nginx5-errors"


  error-pages:
    image: nginx:1.27.0-alpine
    container_name: error-pages
    networks:
      - proxy
    ports:
      - 10002:80      
    volumes:
      - ./errors/:/usr/share/nginx/html/
    labels:
      - "traefik.enable=true"
      # HTTP entrypoint
      - "traefik.http.routers.error-pages.entrypoints=http"
      - "traefik.http.routers.error-pages.rule=Host(`errors.xsec.in`)"
      - "traefik.http.services.error-pages.loadbalancer.server.port=80"
      - "traefik.http.routers.error-pages.rule=Host(`errors.xsec.in`)"
      # HTTPS entrypoint      
      - "traefik.http.routers.error-pages-secure.entrypoints=https"
      - "traefik.http.routers.error-pages-secure.rule=Host(`errors.xsec.in`)"
      - "traefik.http.routers.error-pages-secure.tls=true"

      
networks:
  proxy:
    name: proxy
    external: true

volumes:
  site1_data:
    external: true
  site2_data:
    external: true
  site3_data:
    external: true
  site4_data:
    external: true
  site5_data:
    external: true


```





