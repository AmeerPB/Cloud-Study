#### Jaeger config files for Viewing Traefik tracing

```yaml
version: '3.5'

services:
  jaeger:
    image: jaegertracing/all-in-one:latest
    container_name: jaeger
    restart: unless-stopped
    ports:
      - "5775:5775/udp"      # Agent compact thrift
      - "6831:6831/udp"      # Agent binary thrift
      - "6832:6832/udp"      # Agent binary thrift
      - "5778:5778"          # Agent HTTP (for configuration)
      - "16686:16686"        # Jaeger UI
      - "14250:14250"        # Collector gRPC
      - "14268:14268"        # Collector HTTP
      - "9411:9411"          # Zipkin HTTP (optional, for compatibility with Zipkin)
    networks:
      - proxy
    volumes:
      - jaeger_data:/var/lib/jaeger
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.jaeger.entrypoints=http"
      - "traefik.http.routers.jaeger.rule=Host(`jaeger.xsec.in`)"
      - "traefik.http.routers.jaeger-secure.entrypoints=https"
      - "traefik.http.routers.jaeger-secure.rule=Host(`jaeger.xsec.in`)"
      #- "traefik.http.routers.jaeger-secure.middlewares=traefik-auth"
      - "traefik.http.routers.jaeger-secure.tls=true"
      - "traefik.http.routers.jaeger-secure.tls.certresolver=cloudflare"
      - "traefik.http.routers.jaeger-secure.tls.domains[0].main=xsec.in"
      - "traefik.http.routers.jaeger-secure.tls.domains[0].sans=*.xsec.in"
      - "traefik.http.services.jaeger.loadbalancer.server.port=16686"

networks:
  proxy:
    external: true

volumes:
  jaeger_data:
    name: jaeger_data


```