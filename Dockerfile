FROM quay.io/letsencrypt/letsencrypt:latest

VOLUME /var/acme-webroot

COPY entrypoint.sh /

COPY cli.ini /root/.config/letsencrypt/

ENTRYPOINT [ "/entrypoint.sh" ]
