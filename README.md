# Docker Image for Symfony Framework

Master: [![CircleCI](https://circleci.com/gh/gusdecool/docker-symfony/tree/master.svg?style=svg)](https://circleci.com/gh/gusdecool/docker-symfony/tree/master)

Download the Docker Image at https://hub.docker.com/r/gusdecool/symfony

## How to develop

1. Have a copy of symfony codebase in `/symfony` directory. We can install it with command 
    `composer create-project symfony/skeleton symfony`
1. The container is expecting the symfony root directory will be synced to `/app` in docker container.

# Docker commands

Use Docker Compose to make it easier to manage the containers.

run `docker-compose up -d` to run the containers
