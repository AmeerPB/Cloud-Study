#### Gitea docker-compose


```yaml
version: "3"

services:
  server:
    image: gitea/gitea:latest
    container_name: gitea
    environment:
      - USER_UID=1000
      - USER_GID=1000
      - GITEA__database__DB_TYPE=postgres
      - GITEA__database__HOST=db:5432
      - GITEA__database__NAME=gitea
      - GITEA__database__USER=gitea
      - GITEA__database__PASSWD=tf2vrJDtyA3IPrrNI9Sj
      - GITEA__server__HTTP_PORT=9090
    restart: always
    volumes:
      - ./gitea:/data
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
    depends_on:
      - db
    networks:
      - proxy
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.gitea-secure.entrypoints=https"
      - "traefik.http.routers.gitea-secure.rule=Host(`gitea.xsec.in`)"
      - "traefik.http.routers.gitea-secure.tls=true"
      - "traefik.http.routers.gitea-secure.service=gitea@docker"
      - "traefik.http.services.gitea.loadbalancer.server.port=3000"
      - "traefik.docker.network=proxy"
    security_opt:
      - no-new-privileges:true

  db:
    image: postgres:14
    restart: always
    environment:
      - POSTGRES_USER=gitea
      - POSTGRES_PASSWORD=tf2vrJDtyA3IPrrNI9Sj
      - POSTGRES_DB=gitea
    volumes:
      - ./postgres:/var/lib/postgresql/data
    networks:
      - proxy

networks:
  proxy:
    external: true

```