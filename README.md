# Docker Image for Symfony Framework

Download the Docker Image at https://hub.docker.com/r/gusdecool/symfony

## How to use

1. Create a project directory and scaffold a Symfony project into it using the image's Composer — no local PHP/Composer install needed. Use the current LTS version, currently 6.4.x:
```shell
mkdir my-project && cd my-project
docker run -it --rm -v "$(pwd):/app" gusdecool/symfony:php8.5 composer create-project "symfony/skeleton:6.4.*" /app
```

2. Add a `docker-compose.yml` in the project root to run the app. Use the `-dev` tag for local development (includes Xdebug), or drop the `-dev` suffix for a prod-like image:
```yaml
services:
  app:
    image: gusdecool/symfony:php8.5-dev
    volumes:
      - ./:/app
    ports:
      - "8090:80"
```

3. Start the container:
```shell
docker compose up -d
```

4. Open http://localhost:8090 in your browser to confirm it works.

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

## Continuous deployment
Pushes to `master` trigger [`.github/workflows/docker-publish.yml`](.github/workflows/docker-publish.yml), which builds every prod/dev image pair and pushes them to Docker Hub. The workflow needs `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` configured as repository secrets.
