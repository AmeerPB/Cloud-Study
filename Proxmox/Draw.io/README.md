#### Draw.io docker compose


```yaml

services:
  drawio:
    image: jgraph/drawio
    container_name: drawio
    ports:
      - "10004:8080"  
#    environment:
#      - DRAWIO_PROXY=1  # Set this if you are using a proxy
    restart: unless-stopped
    volumes:
      - drawio_data:/var/www/html/data
    networks:
      - proxy
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.drawio-secure.entrypoints=https"
      - "traefik.http.routers.drawio-secure.rule=Host(`drawio.xsec.in`)"
      - "traefik.http.routers.drawio-secure.tls=true"
      - "traefik.http.routers.drawio-secure.service=drawio@docker"
      - "traefik.http.services.drawio.loadbalancer.server.port=8080"
      - "traefik.docker.network=proxy"


volumes:
  drawio_data:
    external: true

networks:
  proxy:
    external: true

```