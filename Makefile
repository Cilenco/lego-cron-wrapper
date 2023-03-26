build:
	docker build -t cilenco/lego-cron-wrapper:latest -t cilenco/lego-cron-wrapper:v4.10.2 .

push:
	docker push cilenco/lego-cron-wrapper

