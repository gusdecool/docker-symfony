php83-build:
	docker build -t gusdecool/symfony:php8.3 -f ./php8.3.Dockerfile .
	docker build -t gusdecool/symfony:php8.3-dev -f ./php8.3-dev.Dockerfile .
php83-run:
	docker run -it --rm --name docker-symfony -p 8080:80 -v $(pwd)/symfony:/app gusdecool/symfony:php8.3 sh
php84-build:
	docker build -t gusdecool/symfony:php8.4 -f ./php8.4.Dockerfile .
	docker build -t gusdecool/symfony:php8.4-dev -f ./php8.4-dev.Dockerfile .
php84-run:
	docker run -it --rm --name docker-symfony -p 8080:80 -v $(pwd)/symfony:/app gusdecool/symfony:php8.4 sh
push-image:
	docker push gusdecool/symfony:php8.3
	docker push gusdecool/symfony:php8.3-dev
	docker push gusdecool/symfony:php8.4
	docker push gusdecool/symfony:php8.4-dev
