php83-build:
	docker build -t gusdecool/symfony:php8.3 -f ./php8.3.Dockerfile .
	docker build -t gusdecool/symfony:php8.3-dev -f ./php8.3-dev.Dockerfile .
php83-run:
	docker run -it --rm --name docker-symfony -p 8080:80 -v $(pwd)/symfony:/app gusdecool/symfony:php8.3
push-image:
	docker push gusdecool/symfony:php8.3
	docker push gusdecool/symfony:php8.3-dev
