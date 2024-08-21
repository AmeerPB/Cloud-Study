#### OpenTelemetry

OpenTelemetry Collector processes and forwards the tracing data to Jaeger.  

docker-compose.yml

```yaml
services:
  otel-collector:
    image: otel/opentelemetry-collector-contrib:latest
    container_name: otel-collector
    restart: unless-stopped
    ports:
      - "55680:55680"  # Default OTLP receiver port
      - "4317:4317"    # gRPC receiver port for OTLP
    volumes:
      - ./config.yml:/otel-config.yml
    command: ["--config", "/otel-config.yml"]

#networks:
#  default:
#    external:
#      name: proxy
#

#networks:
#  proxy:
#    name: proxy
#    external: true


```

`config.yml`

```yaml
receivers:
  otlp:
    protocols:
      grpc:
      http:

#exporters:
#  jaeger:
#    endpoint: "192.168.1.20:14250"  # Replace with your Jaeger endpoint if used

exporters:
  otlphttp:
    endpoint: "http://192.168.1.20:14250"  # Jaeger HTTP endpoint for traces

processors:
  batch:

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [otlphttp]


```

