FROM ich777/debian-baseimage

LABEL maintainer="admin@minenet.at"

RUN apt-get update && \
	apt-get -y install --no-install-recommends unzip xz-utils curl liblzma-dev build-essential libsdl1.2-dev zlib1g-dev liblzo2-dev timidity dpatch libfontconfig-dev libicu-dev screen && \
	rm -rf /var/lib/apt/lists/*

ENV DATA_DIR="/serverdata"
ENV SERVER_DIR="${DATA_DIR}/serverfiles"
ENV GAME_PARAMS="template"
ENV GAME_PORT=3979
ENV GAME_VERSION=1.9.1
ENV COMPILE_CORES=""
ENV GFXPACK_URL=""
ENV UMASK=000
ENV UID=99
ENV GID=100

RUN mkdir $DATA_DIR && \
	mkdir $SERVER_DIR && \
	useradd -d $DATA_DIR -s /bin/bash --uid $UID --gid $GID openTTD && \
	chown -R openTTD $DATA_DIR && \
	ulimit -n 2048

ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/ && \
	chown -R openTTD /opt/scripts

USER openTTD

#Server Start
ENTRYPOINT ["/opt/scripts/start-server.sh"]