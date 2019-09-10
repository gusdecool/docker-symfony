# Docker Image for Symfony Framework

## How to develop

1. Have a copy of symfony codebase in `/symfony` directory. We can install it with command 
    `composer create-project symfony/skeleton symfony`
1. The container is expecting the symfony root directory will be synced to `/app` in docker container.

# Docker commands

## Build

```shell script
docker build -t gusdecool/symfony .
```

## Run

```shell script
docker run --rm \
    -v ${PWD}/symfony:/app \
    -v ${HOME}/.composer:/root/.composer \
    -p 7100:443 \
    gusdecool/symfony
```

then open `https://localhost:7100/` on your browser and ignore the SSL error.

## Push

```shell script
docker push gusdecool/symfony
```
