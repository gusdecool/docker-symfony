# Docker Image for Symfony Framework

Master: [![CircleCI](https://circleci.com/gh/gusdecool/docker-symfony/tree/master.svg?style=svg)](https://circleci.com/gh/gusdecool/docker-symfony/tree/master)

Download the Docker Image at https://hub.docker.com/r/gusdecool/symfony

## How to use

The best way to use this image on your local computer is by using docker compose. Create `docker-compose.yml` file
on your Symfony root directory and copy paste the line below

```yaml
version: "3.7"
services:
    app:
        image: gusdecool/symfony
        ports:
            - 7100:80
        volumes:
            - ./:/app
```

Save the file and run `docker-compose up -d`. Once the command run successfully, open http://localhost:7100.

## How to develop

1. Have a copy of symfony codebase in `/symfony` directory. We can install it with command 
    `composer create-project symfony/skeleton symfony`
1. The container is expecting the symfony root directory will be synced to `/app` in docker container.

# Docker commands

Use Docker Compose to make it easier to manage the containers.

run `docker-compose up -d` to run the containers

## Build

```shell script
docker build -t gusdecool/symfony .
```
