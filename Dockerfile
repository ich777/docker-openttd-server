FROM ich777/debian-baseimage

LABEL maintainer="admin@minenet.at"

RUN apt-get update && \
	apt-get -y install --no-install-recommends unzip xz-utils curl screen && \
	rm -rf /var/lib/apt/lists/*

RUN wget -O /tmp/gotty.tar.gz https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_amd64.tar.gz && \
	tar -C /usr/bin/ -xvf /tmp/gotty.tar.gz && \
	rm -rf /tmp/gotty.tar.gz

ENV DATA_DIR="/serverdata"
ENV SERVER_DIR="${DATA_DIR}/serverfiles"
ENV GAME_PARAMS="template"
ENV GAME_PORT=3979
ENV GAME_VERSION="latest"
ENV ENABLE_WEBCONSOLE="true"
ENV GOTTY_PARAMS="-w --title-format OpenTTD"
ENV COMPILE_CORES=""
ENV GFX_PK_V="latest"
ENV UMASK=000
ENV UID=99
ENV GID=100
ENV DATA_PERM=770
ENV USER="openTTD"

RUN mkdir $DATA_DIR && \
	mkdir $SERVER_DIR && \
	useradd -d $SERVER_DIR -s /bin/bash $USER && \
	chown -R $USER $DATA_DIR && \
	ulimit -n 2048

ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]