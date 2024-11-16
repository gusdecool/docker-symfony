# Docker Image for Symfony Framework

Download the Docker Image at https://hub.docker.com/r/gusdecool/symfony

## How to use
TODO to be written

## How to develop
Install Symfony, ideally use LTS version. The current LTS version is 6.4.x.
```shell
docker run -it --rm -v "$(pwd)/symfony:/app" composer create-project "symfony/skeleton:6.4.*" /app
```

Build the docker image with command
```shell
make php83-build
```

Then test run the container
```shell
make php83-run
```

Open in browser http://localhost:6000 to make sure it works as expected
