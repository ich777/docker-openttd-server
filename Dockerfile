FROM ubuntu

MAINTAINER ich777

RUN apt-get update
RUN apt-get -y install wget unzip liblzma-dev build-essential libsdl1.2-dev zlib1g-dev liblzo2-dev timidity dpatch libfontconfig-dev libicu-dev screen

ENV DATA_DIR="/serverdata"
ENV SERVER_DIR="${DATA_DIR}/serverfiles"
ENV GAME_PARAMS="template"
ENV GAME_PORT=3979
ENV GAME_VERSION="latest"
ENV UID=99
ENV GID=100

RUN mkdir $DATA_DIR
RUN mkdir $SERVER_DIR
RUN useradd -d $DATA_DIR -s /bin/bash --uid $UID --gid $GID openTTD
RUN chown -R openTTD $DATA_DIR

RUN ulimit -n 2048

ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/
RUN chown -R openTTD /opt/scripts

USER openTTD

#Server Start
ENTRYPOINT ["/opt/scripts/start-server.sh"]
