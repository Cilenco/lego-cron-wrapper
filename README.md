[![GitHub release](https://img.shields.io/github/v/release/cilenco/lego-cron-wrapper)](https://github.com/cilenco/lego-cron-wrapper/releases)
[![Docker Image Size](https://img.shields.io/docker/image-size/cilenco/lego-cron-wrapper?sort=semver)](https://hub.docker.com/r/cilenco/lego-cron-wrapper "Click to view the image on Docker Hub")
[![Docker pulls](https://img.shields.io/docker/pulls/cilenco/lego-cron-wrapper.svg)](https://hub.docker.com/r/cilenco/lego-cron-wrapper 'DockerHub')

This repository is a tiny wrapper around the awesome [Lego ACME](https://github.com/go-acme/lego) client. It adds automatic certificat renew support which is currently missing from the official Lego Docker image. It does so by using cron to periodically invoke the client to update the certificates. Migrating to this image from an existing setup is straightforward: The command fed to the image is passed to the `run` or `renew` command respectively. Because of this the image is also very future proof since all commands and arguments are passed directly to the original client.

### Usage with [nginx-proxy](https://github.com/nginx-proxy/nginx-proxy)

```yaml
version: '2'
services:
  nginx-proxy:
    image: nginxproxy/nginx-proxy
    container_name: nginx-proxy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/tmp/docker.sock:ro
      - certs:/etc/nginx/certs:ro
  lego-acme:
    image: cilenco/lego-cron-wrapper
    container_name: lego-acme
    command: >
      --accept-tos --email=<YOUR_EMAIL> --dns <DNS_PROVIDER>
      --domains=*.<YOUR_DOMAIN> --domains=<YOUR_DOMAIN>
    environment:
      - RUN_ARGUMENTS=--run-hook=/app/deploy
      - RENEW_ARGUMENTS=--renew-hook=/app/deploy
      # Add environment variables used by your DNS provider
    volumes:
      - certs:/app/certificates
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./deploy.sh:/app/deploy

volumes:
  certs:
    external: true
```

The deploy script mounted to the acme container can be found in this repo as well. If you would like to create it on your own don't forget to make it executable! All it does is to copy the certificates with the correct name to the external volume and restarts the nginx-proxy container.
```sh
#!/bin/sh

FILE_NAME="${LEGO_CERT_DOMAIN#\*.}"

cp -f $LEGO_CERT_PATH /app/certificates/$FILE_NAME.crt 
cp -f $LEGO_CERT_KEY_PATH /app/certificates/$FILE_NAME.key

curl --unix-socket /var/run/docker.sock -X POST http://localhost/containers/nginx-proxy/restart
```
