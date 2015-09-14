#!/bin/sh

# Fail if LOGGLY_TAG is not set
if [ -z "$LOGGLY_TAG" ]; then
  if [ ! -z "$TAG" ]; then
    # grandfather old env var
    export LOGGLY_TAG=$TAG
  else
    echo "Missing \$LOGGLY_TAG"
    exit 1
  fi
fi

# Fail if LOGGLY_CONFIG_BUCKET is not set
if [ -z "$LOGGLY_CONFIG_BUCKET" ]; then
  echo "Missing \$LOGGLY_CONFIG_BUCKET"
  exit 1
fi

# Fail if LOGGLY_TOKEN_FILE is not set
if [ -z "$LOGGLY_TOKEN_FILE" ]; then
  echo "Missing \$LOGGLY_TOKEN_FILE"
  exit 1
fi

# Fetch token from S3 bucket
aws s3 cp s3://$LOGGLY_CONFIG_BUCKET/$LOGGLY_TOKEN_FILE /tmp/
if [ ! -f /tmp/$LOGGLY_TOKEN_FILE ]; then
  echo "Unable to retrieve loggly token"
  exit 1
fi
LOGGLY_AUTH_TOKEN=`head -1 /tmp/$LOGGLY_TOKEN_FILE | tr -d "\n$"`
rm -rf /tmp/$LOGGLY_TOKEN_FILE

# Create spool directory
mkdir -p /var/spool/rsyslog

# If LOGGLY_DEBUG is true, write logs to stdout as well
if [ "$LOGGLY_DEBUG" = true ]; then
  sed -i "/\*\.\* @@logs-01\.loggly\.com.*/a \*\.\* \:omstdout\:" /etc/rsyslog.conf
fi

# Expand multiple tags, in the format of tag1:tag2:tag3, into several tag arguments
LOGGLY_TAG=$(echo "$LOGGLY_TAG" | sed 's/:/\\\\" tag=\\\\"/g')

# Replace variables
sed -i "s/LOGGLY_AUTH_TOKEN/$LOGGLY_AUTH_TOKEN/" /etc/rsyslog.conf
sed -i "s/LOGGLY_TAG/$LOGGLY_TAG/" /etc/rsyslog.conf

# Run RSyslog daemon
exec /usr/sbin/rsyslogd -n

