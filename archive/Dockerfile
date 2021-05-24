FROM registry.access.redhat.com/ubi8/ubi

LABEL maintainer="Hank W Ibell <hwibell@us.ibm.com>"

ARG IHS_ARCHIVE_FILE

RUN yum -y -q install unzip

COPY $IHS_ARCHIVE_FILE /tmp/

RUN unzip -q -d /opt /tmp/$IHS_ARCHIVE_FILE
RUN ln -s /opt/IHS/conf /conf
RUN ln -s /opt/IHS/htdocs /htdocs
RUN ln -s /opt/IHS/logs /logs
RUN ln -s /opt/IHS/plugin /plugin
COPY httpd-foreground update-conf.sh /opt/IHS/bin/

RUN /opt/IHS/postinstall.sh
RUN /opt/IHS/bin/update-conf.sh

EXPOSE 80
CMD ["/opt/IHS/bin/httpd-foreground"]