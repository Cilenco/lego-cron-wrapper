build:
	docker build -t cilenco/lego-cron-wrapper:latest -t cilenco/lego-cron-wrapper:v2.1 .

push:
	docker push cilenco/lego-cron-wrapper

