php81-build:
	docker build -t gusdecool/symfony:php8.1 ./php8.1 -f ./php8.1/prod.Dockerfile
php81-run:
	docker run -it --rm -v $(pwd)/php8.1/symfony-6.4:/app gusdecool/symfony:php8.1 sh
	cd ../ && composer create-project symfony/skeleton:"6.4.*" app && cd app
php81-docker:
	docker-compose -f php8.1/compose-symfony-6.4.yml up
php82:
	docker build -t gusdecool/symfony:php8.2 ./php8.2
php82-dev:
	docker build -t gusdecool/symfony:php8.2-dev -f ./php8.2/dev.Dockerfile ./php8.2
