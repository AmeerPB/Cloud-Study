#### Setup steps 

#### Docker run command

```yaml
docker run -d --name dd-agent \
-e DD_API_KEY=xxxxxxxxxxxxxxx \
-e DD_SITE="us5.datadoghq.com" \
-e DD_DOGSTATSD_NON_LOCAL_TRAFFIC=true \
-v /var/run/docker.sock:/var/run/docker.sock:ro \
-v /proc/:/host/proc/:ro \
-v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
-v /var/lib/docker/containers:/var/lib/docker/containers:ro \
gcr.io/datadoghq/agent:7

```

#### Docker-compose file for DD

> [!WARNING]
>
> Didn't work as expected.
> The DD webpage didnt recognised as an agent is installed on the Host

``` yaml
version: '3.5'

services:
  datadog-agent:
    image: gcr.io/datadoghq/agent:7
    container_name: dd-agent
    environment:
      - DD_API_KEY=xxxxxxxxxxxxxxx  # Replace with your Datadog API key
      - DD_SITE="us5.datadoghq.com" # Replace with your Datadog site (e.g., us5 for US, eu for EU)
      - DD_DOGSTATSD_NON_LOCAL_TRAFFIC=true
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /proc/:/host/proc/:ro
      - /sys/fs/cgroup/:/host/sys/fs/cgroup:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
    ports:
      - "8125:8125/udp" # DogStatsD port
      - "8126:8126"     # Trace Agent port (optional)
    networks:
      - proxy

networks:
  proxy:
    name: proxy
    external: true

```





