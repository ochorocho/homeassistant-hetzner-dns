ARG BUILD_FROM
FROM $BUILD_FROM

# Copy rootfs
COPY rootfs /
RUN chmod a+x /run.sh /hetzner-dns-update.sh

CMD [ "/run.sh" ]

WORKDIR /