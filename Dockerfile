ARG BUILD_FROM
FROM $BUILD_FROM

# Install requirements for add-on
RUN apk add --no-cache python3 py3-pip gcc python3-dev
RUN pip3 install inetbox-py --break-system-packages

# Copy data for add-on


# Copy rootfs
COPY rootfs /

WORKDIR /