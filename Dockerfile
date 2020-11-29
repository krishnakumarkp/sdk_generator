FROM amazonlinux:2

RUN yum update -y 
RUN yum install -y ca-certificates curl software-properties-common wget unzip zip tar which curl git
RUN amazon-linux-extras install php7.2

RUN set -ex \
    && useradd -m -d /home/jenkins -u 112 -U jenkins \
    && mkdir -p /home/jenkins/.ssh \
    && chown jenkins:jenkins /home/jenkins/.ssh \
    && chmod 700 /home/jenkins/.ssh

# Install PHP 7.2
RUN yum update -y \
    && yum groupinstall "Development tools" -y \
    && yum install -y which libmemcached-devel zlib-devel \
    && yum install -y php php-cli php-devel php-pdo php-mbstring php-pear \
    && yum clean all && rm -rf /var/cache/yum

RUN yum install -y php-mbstring
RUN curl -s https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer
RUN yum install -y java-11-amazon-corretto-headless 
#install sonar scanner
RUN curl -L https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.5.0.2216.zip -o  sonarscanner.zip \
  && unzip -qq sonarscanner.zip \
  && rm -rf sonarscanner.zip \
  && mv sonar-scanner-4.5.0.2216 sonar-scanner
ENV PATH $PATH:sonar-scanner/bin
USER jenkins
CMD [ "java", "-version" ]