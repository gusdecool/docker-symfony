# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This repo builds and publishes the `gusdecool/symfony` Docker images (https://hub.docker.com/r/gusdecool/symfony) — PHP-FPM + nginx images tailored for running a Symfony application, designed to deploy to AWS AppRunner. It does not contain a Symfony application itself; `symfony/` is a git-ignored mount point where a Symfony project is scaffolded locally for testing the images.

## Commands

Build and run PHP 8.3 images:
```shell
make php83-build
make php83-run   # runs the prod image, mounts ./symfony:/app, exposes :8080
```

Build and run PHP 8.4 images:
```shell
make php84-build
make php84-run
```

Push images to Docker Hub:
```shell
make push-image
```

Scaffold a Symfony app into `symfony/` for local testing against these images (use the current LTS, currently 6.4.x):
```shell
docker run -it --rm -v "$(pwd)/symfony:/app" composer create-project "symfony/skeleton:6.4.*" /app
```

There is no direct `docker build`/test command outside the Makefile — always build through `make` so both the prod and dev variants stay tagged consistently.

## Architecture

Each supported PHP version has two Dockerfiles that build on each other:

- `php<version>.Dockerfile` — the **prod** image (tagged `gusdecool/symfony:php<version>`). Based on `php:<version>-fpm-alpine`, this installs PHP extensions via [`install-php-extensions`](https://github.com/mlocati/docker-php-extension-installer) (mysqli, pdo_mysql, intl, bcmath), adds nginx as the web server in front of PHP-FPM, and runs both processes via a single `CMD` (`nginx & php-fpm`). Node.js/npm are installed for frontend asset builds (e.g. Symfony Encore/AssetMapper). Port 80 is exposed; nginx proxies to PHP-FPM on `127.0.0.1:9000` per `docker-config/nginx-site.conf`.
- `php<version>-dev.Dockerfile` — the **dev** image (tagged `gusdecool/symfony:php<version>-dev`). `FROM gusdecool/symfony:php<version> AS prod`, layering on Xdebug (`docker-config/php-xdebug.ini`) for step debugging against a host IDE (`xdebug.client_host=host.docker.internal`).

Shared PHP/nginx configuration lives in `docker-config/` and is `COPY`'d into the images:
- `nginx-site.conf` — nginx vhost serving `/app/public` and routing all requests through `index.php` via FastCGI.
- `php-error_reporting.ini` — forces `error_reporting = E_ALL` with errors logged to `/dev/stderr` so they surface in `docker logs`.
- `php-xdebug.ini` — dev-only Xdebug config (mode `develop,debug`).

When adding support for a new PHP version, mirror the existing `php<version>.Dockerfile` / `php<version>-dev.Dockerfile` pair and add matching `php<version>-build` / `php<version>-run` targets (and push-image entries) to the `Makefile`.

`docker-compose.yml` runs the published dev image directly (`gusdecool/symfony:8.3-dev`) against a local `./` mount, useful for consuming the image without rebuilding it.

## CI/CD

`.github/workflows/docker-publish.yml` runs on every push to `master` and publishes all four images to Docker Hub. It's split into two sequenced jobs: `build-prod` builds and pushes the prod images (`php8.3`, `php8.4`), then `build-dev` (which `needs: build-prod`) builds and pushes the dev images. This ordering is required because each `php<version>-dev.Dockerfile` starts `FROM gusdecool/symfony:php<version>` — i.e. it pulls the just-published prod tag from Docker Hub rather than building on a local layer, so the prod image must already be pushed before the dev build starts. The workflow expects `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` repository secrets. When adding a new PHP version, add both its prod and dev entries to the respective job's matrix.

`.github/workflows/docker-build-test.yml` runs on pull requests targeting `master` and build-tests all four Dockerfiles (`push: false`, no secrets needed) as a merge gate. Unlike `docker-publish.yml`, this workflow builds every Dockerfile in one flat matrix rather than sequencing dev after prod, since the dev build here just pulls the already-published prod tag rather than one built in this run — so it doesn't exercise a PR's prod Dockerfile changes.
