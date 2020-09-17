FROM ubuntu:16.04

RUN apt-get -y update 
RUN apt-get install -y software-properties-common 
RUN apt-get -y update
RUN apt-get install -y gnupg2
RUN apt-get install -y wget
RUN apt-get install -y openjdk-8-jdk

RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
RUN apt-get update
RUN apt-get install -y php7.1 php7.1-cli php7.1-common php7.1-json php7.1-mbstring php7.1-mcrypt php7.1-zip php7.1-xml