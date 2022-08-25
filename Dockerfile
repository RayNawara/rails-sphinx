# https://github.com/iComputer7/ancient-ubuntu-docker
FROM ubuntu:12.04

RUN sed -i -e "s/archive.ubuntu.com/old-releases.ubuntu.com/g" /etc/apt/sources.list

# https://freelancing-gods.com/2008/06/12/a-concise-guide-to-using-thinking-sphinx.html
RUN apt-get update -q && apt-get install -y curl build-essential libmysqlclient-dev nano
WORKDIR /home
RUN curl -O http://sphinxsearch.com/files/archive/sphinx-0.9.9.tar.gz
# COPY sphinx-0.9.9.tar.gz  .
RUN tar zxvf sphinx-0.9.9.tar.gz
WORKDIR /sphinx-0.9.9
RUN pwd
RUN ./configure --with-mysql 
RUN make 
RUN make install
WORKDIR /home
COPY shared shared/
RUN cp shared/config/sphinx.conf /usr/local/etc
# CMD [searchd --config shared/config/sphinx.conf]