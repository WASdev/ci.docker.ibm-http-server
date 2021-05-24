#!/usr/bin/env bash

# Enable SSL if conf/ihsserverkey.kdb exists
cat <<EOF >> /opt/IHS/conf/httpd.conf

<IfFile conf/ihsserverkey.kdb>
  LoadModule ibm_ssl_module modules/mod_ibm_ssl.so
  Listen 443
  SSLCheckCertificateExpiration 30
  <VirtualHost *:443>
    SSLEnable
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
  </VirtualHost>
  KeyFile /opt/IHS/conf/ihsserverkey.kdb
</IfFile>

ErrorLog /dev/stdout
EOF
