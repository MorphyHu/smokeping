FROM centos:7.5.1804
MAINTAINER MorphyHu
# set LANG
ENV LANG en_US.UTF-8
# install smokeping version
ENV SMOKEPING_VERSION 2.7.2
# set timezone
RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' > /etc/timezone
# install packages
RUN yum update -y \
    && yum groupinstall -y "Development tools" \
    && yum install -y epel-release \
    && yum install -y perl httpd httpd-devel mod_fcgid rrdtool perl-CGI-SpeedyCGI fping rrdtool-perl perl-Sys-Syslog \
    && yum install -y perl-CPAN perl-local-lib perl-Time-HiRes perl-core \
    && yum install -y postfix supervisor ssmtp sendEmail wget openssl-devel \
    && cd /tmp \
    && wget http://oss.oetiker.ch/smokeping/pub/smokeping-${SMOKEPING_VERSION}.tar.gz \
    && tar xzvf smokeping-${SMOKEPING_VERSION}.tar.gz \
    && cd smokeping-${SMOKEPING_VERSION} \
    && mkdir /opt/smokeping \
    && ./configure --prefix=/opt/smokeping \
    && /usr/bin/gmake install
# config smokeping
RUN cp /opt/smokeping/etc/basepage.html.dist /opt/smokeping/etc/basepage.html \
    && cp /opt/smokeping/etc/config.dist /opt/smokeping/etc/config \
    && sed -i -e 's@/opt/smokeping/cache@/opt/smokeping/htdocs/cache@' /opt/smokeping/etc/config \
    && cp /opt/smokeping/etc/smokemail.dist /opt/smokeping/etc/smokemail \
    && cp /opt/smokeping/etc/smokeping_secrets.dist /opt/smokeping/etc/smokeping_secrets \
    && cp /opt/smokeping/etc/tmail.dist /opt/smokeping/etc/tmail \
    && cp /opt/smokeping/htdocs/smokeping.fcgi.dist /opt/smokeping/htdocs/smokeping.fcgi \
    && chmod 700 /opt/smokeping/etc/smokeping_secrets.dist \
    && mkdir /opt/smokeping/data \
    && mkdir /opt/smokeping/var \
    && mkdir /opt/smokeping/htdocs/cache \
    && chown apache.apache -R /opt/smokeping
# config httpd
RUN echo 'ServerName 127.0.0.1' >> /etc/httpd/conf/httpd.conf \
    && sed -i -e 's@logs/access_log@/dev/stdout@' /etc/httpd/conf/httpd.conf \
    && sed -i -e 's@logs/error_log@/dev/stderr@' /etc/httpd/conf/httpd.conf \
    && sed -i -e 's@DirectoryIndex.*$@DirectoryIndex index.html smokeping.fcgi@' /etc/httpd/conf/httpd.conf \
    && sed -i -e 's@DocumentRoot.*$@DocumentRoot "/var/www/html"@' /etc/httpd/conf/httpd.conf
# Clean
RUN yum -y clean all \
    && rm -rf /var/cache/yum \
    && rm -rf /tmp/*
# install operating system configuration
COPY docker/ /
EXPOSE 80
ENTRYPOINT [ "/init" ]
