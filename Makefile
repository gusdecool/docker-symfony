php83-build:
	docker build -t gusdecool/symfony:php8.3 -f ./php8.3.Dockerfile .
php83-run:
	docker run -it --rm -p 8080:80 -v $(pwd)/symfony:/app gusdecool/symfony:php8.3
