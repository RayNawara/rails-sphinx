# https://github.com/iComputer7/ancient-ubuntu-docker
FROM ubuntu:12.04

RUN sed -i -e "s/archive.ubuntu.com/old-releases.ubuntu.com/g" /etc/apt/sources.list

# https://freelancing-gods.com/2008/06/12/a-concise-guide-to-using-thinking-sphinx.html
RUN apt-get update -q && apt-get install -y curl build-essential libmysqlclient-dev nano
WORKDIR /home
RUN curl -O http://sphinxsearch.com/files/archive/sphinx-0.9.9.tar.gz
# COPY sphinx-0.9.9.tar.gz  .
RUN tar zxvf sphinx-0.9.9.tar.gz
WORKDIR sphinx-0.9.9
RUN pwd
RUN ./configure --with-mysql 
RUN make 
RUN make install
WORKDIR /mba-orig
ADD shared ./shared
RUN cp shared/config/sphinx.conf /usr/local/etc
RUN searchd --config shared/config/sphinx.conf

LABEL description="This is an image to setup a dev environment for mbadiamond"

RUN apt-get update && apt-get upgrade -y \
  && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1655A0AB68576280 \
  && apt-get install curl -y \
  # && curl https://deb.nodesource.com/setup_6.x | bash \
  # && apt-get update \
  # && curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  # && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update \
  && apt-get install -y wget nano git-core zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common python-software-properties libffi-dev make \
  && rm -rf /var/lib/apt/lists/*

# set rbenv, ruby-build bin paths
ENV HOME /home/app
ENV PATH $HOME/.rbenv/shims:$HOME/.rbenv/bin:$HOME/.rbenv/plugins/ruby-build/bin:$PATH
# clone rbenv
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv \
  # clone ruby-build
  && git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

RUN cd /usr/local/src/ && wget https://www.openssl.org/source/openssl-1.0.2u.tar.gz --no-check-certificate \
  && tar -xzvf openssl-1.0.2u.tar.gz \
  && cd openssl-1.0.2u \
  && openssl version -a \
  && ./config \
  && make install \
  && ln -sf /usr/local/ssl/bin/openssl `which openssl` \
  && openssl version -v

# RUN apt purge -y libssl-dev && apt install -y libssl1.0-dev
COPY openssl_tls_1.2.patch /home/app

RUN RUBY_CONFIGURE_OPTS=--with-openssl-dir=/usr/local/src/openssl-1.0.2u rbenv install -f --patch 1.8.7-p374 < /home/app/openssl_tls_1.2.patch \
  && rbenv global 1.8.7-p374 \
  && ruby -ropenssl -e 'puts OpenSSL::OPENSSL_VERSION' \
  && ruby -v \
  && gem install bundler --no-rdoc --no-ri -v 1.17.3 \
  && gem install rake --no-rdoc --no-ri -v 0.9.2 \
  && gem install rails --no-rdoc --no-ri -v 2.3.10 \
  && gem install slimgems --no-rdoc --no-ri \
  && rbenv rehash

# Set Rails to run in development
ENV RAILS_ENV development 
ENV RACK_ENV development

# install for MySql
RUN apt-get update && apt-get install -y libmysqlclient-dev mysql-client \
  && gem install mysql -v 2.9.1 --no-rdoc --no-ri \
  # install for rmagick
  && apt-get install -y -qq libmagickwand-dev imagemagick

# install wkhtmltopdf 0.12.6
RUN cd ~ && download=https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz && wget $download -O wkhtmltox.tar.xz  && apt-get install -y xfonts-base xfonts-75dpi && tar xf wkhtmltox.tar.xz && mv wkhtmltox/bin/* /usr/local/bin/ && wkhtmltopdf --version

# Get MBA source from github
# RUN git init && git clone --recursive https://github.com/RayNawara/mba-orig.git 
# Change this to link to my source code directory

# set working directory to project src
WORKDIR /mba-orig

# RUN pwd && bundle config mirror.https://rubygems.org http://gemstash:9292

# bundle install and then bundle exec unicorn_rails -c config/unicorn.conf

# RUN bundle installSS

# You could also run script/server but then you can't generate PDFs. 

CMD ["/bin/bash"]
