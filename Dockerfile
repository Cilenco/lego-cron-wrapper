FROM goacme/lego:v4.10.2

VOLUME /.lego # Save certs and account to external volume

COPY app/crontab /var/spool/cron/crontabs/root
RUN chown -R root:root /var/spool/cron/crontabs/root
RUN chmod -R 640 /var/spool/cron/crontabs/root

RUN apk add curl

COPY app/setup /app/setup
RUN chmod +x /app/setup

ENTRYPOINT ["/app/setup"]
