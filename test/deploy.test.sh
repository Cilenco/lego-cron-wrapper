#!/bin/sh

FILE_NAME="${LEGO_CERT_DOMAIN#\*.}"

# If file exists this was a renew call, stop container
if test -f /app/certificates/run_$FILE_NAME.crt; then
    cp -f $LEGO_CERT_PATH /app/certificates/new_$FILE_NAME.crt
    cp -f $LEGO_CERT_KEY_PATH /app/certificates/new_$FILE_NAME.key
    
    # Stop pebble. Since docker is started with "exit-code-from" this container will also stop
    curl --unix-socket /var/run/docker.sock -X POST http://localhost/containers/pebble/stop
else
    cp -f $LEGO_CERT_PATH /app/certificates/run_$FILE_NAME.crt
    cp -f $LEGO_CERT_KEY_PATH /app/certificates/run_$FILE_NAME.key

    sleep 10s

    # Trigger renew
    sh /app/renew
fi
