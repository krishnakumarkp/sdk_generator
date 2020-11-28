FROM amazonlinux:2
USER root
RUN yum update -y 
RUN yum install -y ca-certificates curl software-properties-common wget unzip zip tar which curl git
RUN amazon-linux-extras install php7.2

# Install PHP 7.2
RUN yum update -y \
    && yum groupinstall "Development tools" -y \
    && yum install -y which libmemcached-devel zlib-devel \
    && yum install -y php php-cli php-devel php-pdo php-mbstring php-pear \
    && yum clean all && rm -rf /var/cache/yum

RUN git config --global user.name "jenkins"
RUN git config --global user.email "jenkins@jenkins.com"

RUN yum install -y php-mbstring
RUN curl -s https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer
RUN yum install -y java-11-amazon-corretto-headless 
CMD [ "java", "-version" ]