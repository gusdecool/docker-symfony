# Docker Image for Symfony Framework

Master: [![CircleCI](https://circleci.com/gh/gusdecool/docker-symfony/tree/master.svg?style=svg)](https://circleci.com/gh/gusdecool/docker-symfony/tree/master)

Download the Docker Image at https://hub.docker.com/r/gusdecool/symfony

## How to use

Check the file [docker-compose.yml](./docker-compose.yml) for example how to init this repo

Save the file and run `docker-compose up -d`. Once the command run successfully, open the specified ports in yml file.

## How to develop

1. Have a copy of symfony codebase in `/symfony` directory. We can install it with command 
    `composer create-project symfony/website-skeleton symfony`. Note install the full symfony to check the functionality
1. The container is expecting the symfony root directory will be synced to `/app` in docker container.

# Docker commands

Use Docker Compose to make it easier to manage the containers.

run `docker-compose up -d` to run the containers

## Build

```shell script
docker-compose build
```

## SSL certificate

`ssl-certificate` directory contains the dummy root certificate. 
The password key is `123456`. Use tutorial from https://github.com/gusdecool/local-cert-generator
to generate new certificate if needed or expired.
