#### Deploy selfhosted GitLab


```yaml
services:
  gitlab:
    image: 'gitlab/gitlab-ce:latest'
    container_name: gitlab
    hostname: gitlab.xsec.in
    restart: always
    ports:
      - '8070:80'
      - '8443:443'
      - '8822:22'
    volumes:
      - 'gitlab_config:/etc/gitlab'
      - 'gitlab_logs:/var/log/gitlab'
      - 'gitlab_data:/var/opt/gitlab'
    shm_size: '4gb'
    networks:
      - proxy
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.gitlab.entrypoints=http"
      - "traefik.http.routers.gitlab.rule=Host(`gitlab.xsec.in`)"
      - "traefik.http.middlewares.gitlab-https-redirect.redirectscheme.scheme=https"
      - "traefik.http.middlewares.sslheader.headers.customrequestheaders.X-Forwarded-Proto=https"
      - "traefik.http.routers.gitlab.middlewares=gitlab-https-redirect"
      - "traefik.http.routers.gitlab-secure.entrypoints=https"
      - "traefik.http.routers.gitlab-secure.rule=Host(`gitlab.xsec.in`)"
      - "traefik.http.routers.gitlab-secure.tls=true"
      - "traefik.http.services.gitlab.loadbalancer.server.port=80"

networks:
  proxy:
    name: proxy
    external: true

volumes:
  gitlab_config: {}
  gitlab_logs: {}
  gitlab_data: {}

```

> [!TIP]
>
> To fetch the root user password from the GitLab container
> ```bash
> % docker exec -it gitlab grep 'Password: ' /etc/gitlab/initial_root_password
> Password: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
>
> ```

