#################################################################
#
#                    ##        .
#              ## ## ##       ==
#           ## ## ## ##      ===
#       /""""""""""""""""\___/ ===
#  ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~
#       \______ o          __/
#         \    \        __/
#          \____\______/
#
#################################################################

FROM alpine:3.2
MAINTAINER Jonathan Short <jonathan.short@sendgrid.com>

# install rsyslog+rsyslog-tls
RUN apk add --update rsyslog rsyslog-tls && rm -rf /var/cache/apk/*

# install openssl
RUN apk --update add openssl

# install aws cli
RUN apk add --update python groff \
    && wget https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -O awscli-bundle.zip \
    && unzip awscli-bundle.zip \
    && ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws \
    && rm awscli-bundle.zip \
    && rm -rf /var/cache/apk/* \
    && rm -rf awscli-bundle

ADD run.sh /tmp/run.sh
RUN chmod +x /tmp/run.sh
ADD rsyslog.conf /etc/
ADD loggly.crt /etc/rsyslog.d/keys/ca.d/

EXPOSE 514
EXPOSE 514/udp

CMD ["/tmp/run.sh"]

