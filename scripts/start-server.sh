#!/bin/bash
echo "---Container under construction---"
sleep infinity

CUR_V="$(find ${SERVER_DIR} -name installed_v_* | cut -d "_" -f3)"
if [ "${GAME_VERSION}" = "latest" ]; then
	echo "---Getting latest OpenTTD build version...---"
	LAT_V="$(curl -s https://cdn.openttd.org/openttd-releases/latest.yaml | grep -B1 "stable" | grep "version:" | cut -d ' ' -f3)"
	echo "---Latest OpenTTD build version is: $LAT_V---"
	INSTALL_V=$LAT_V
	if [ -z $LAT_V ]; then
		if [ -z $CUR_V ]; then
			echo "---Something went wrong, couldn't get latest build version---"
			sleep infinity
		else
			echo "---Can't get latest OpenTTD build version, falling back to installed version $CUR_V!---"
			INSTALL_V=$CUR_V
		fi
	fi
else
	INSTALL_V=${GAME_VERSION}
fi

GFX_PK_CUR_V="$(cat ${SERVER_DIR}/games/baseset/changelog.txt 2>/dev/null | head -1 | cut -d ' ' -f2)"
if [ "${GFX_PK_V}" = "latest" ]; then
	echo "---Getting latest OpenGFX version...---"
	GFX_PK_V="$(curl -s https://cdn.openttd.org/opengfx-releases/latest.yaml | grep "version:" | cut -d ' ' -f3)"
	echo "---Latest OpenGFX version is: $GFX_PK_V---"
	if [ -z ${GFX_PK_V} ]; then
		if [ -z $GFX_PK_CUR_V ]; then
			echo "---Something went wrong, couldn't get latest build version---"
			sleep infinity
		else
			echo "---Can't get latest OpenGFX version, falling back to installed version $GFX_PK_CUR_V!---"
			GFX_PK_V=$GFX_PK_CUR_V
	fi
	fi
else
	echo "---Manually set OpenGFX version to ${GFX_PK_V}---"
fi

if [ ! -s ${SERVER_DIR}/installed_v_$LAT_V ]; then
  rm -rf ${SERVER_DIR}/installed_v_$LAT_V
fi

echo "---Version Check---"
if [ ! -f ${SERVER_DIR}/games/openttd ]; then
	echo
	echo "-------------------------------------"
	echo "---OpenTTD not found! Downloading,---"
	echo "---compiling and installing v$INSTALL_V---"
	echo "---Please be patient, this can take--"
	echo "---some time, waiting 15 seconds..---"
	echo "-------------------------------------"
	sleep 15
	cd ${SERVER_DIR}
	if wget -q -nc --show-progress --progress=bar:force:noscroll -O installed_v_$INSTALL_V https://cdn.openttd.org/openttd-releases/$INSTALL_V/openttd-$INSTALL_V-linux-generic-amd64.tar.xz ; then
		echo "---Successfully downloaded OpenTTD v$INSTALL_V---"
	else
		echo "---Can't download OpenTTD v$INSTALL_V putting server into sleep mode---"
		sleep infinity
	fi
	mkdir compileopenttd
	tar -xf installed_v_$INSTALL_V -C ${SERVER_DIR}/compileopenttd/
	COMPVDIR="$(find ${SERVER_DIR}/compileopenttd -name open* -print -quit)"
	mkdir $COMPVDIR/build
	cd $COMPVDIR/build
	cmake -DCMAKE_INSTALL_PREFIX:PATH=${SERVER_DIR} ..
	if [ ! -z "${COMPILE_CORES}" ]; then
		CORES_AVAILABLE=${COMPILE_CORES}
	else
		CORES_AVAILABLE="$(getconf _NPROCESSORS_ONLN)"
	fi
	make --jobs=$CORES_AVAILABLE
	make install
	rm -R ${SERVER_DIR}/compileopenttd
	if [ ! -f ${SERVER_DIR}/games/openttd ]; then 
		echo "---Something went wrong, couldn't install OpenTTD v$INSTALL_V---"
		sleep infinity
	else
		echo "---OpenTTD v$INSTALL_V installed---"
	fi
elif [ "$INSTALL_V" != "$CUR_V" ]; then
	echo
	echo "-------------------------------------------------"
	echo "---Version missmatch, installing v$INSTALL_V----------"
	echo "------Changing from v$CUR_V to v$INSTALL_V-------------"
	echo "----Please be patient this can take some time----"
	echo "---------------Waiting 15 seconds----------------"
	echo "-------------------------------------------------"
	echo
	sleep 15
	cd ${SERVER_DIR}
	rm installed_v_$CUR_V
	rm -R games
	rm -R share
	if wget -q -nc --show-progress --progress=bar:force:noscroll -O installed_v_$INSTALL_V https://cdn.openttd.org/openttd-releases/$INSTALL_V/openttd-$INSTALL_V-linux-generic-amd64.tar.xz ; then
		echo "---Successfully downloaded OpenTTD v$INSTALL_V---"
	else
		echo "---Can't download OpenTTD v$INSTALL_V putting server into sleep mode---"
		sleep infinity
	fi
	mkdir compileopenttd
	tar -xf installed_v_$INSTALL_V -C ${SERVER_DIR}/compileopenttd/
	COMPVDIR="$(find ${SERVER_DIR}/compileopenttd -name openttd-* -print -quit)"
	mkdir $COMPVDIR/build
	cd $COMPVDIR/build
	cmake -DCMAKE_INSTALL_PREFIX:PATH=${SERVER_DIR} ..
	if [ ! -z "${COMPILE_CORES}" ]; then
		CORES_AVAILABLE=${COMPILE_CORES}
	else
		CORES_AVAILABLE="$(getconf _NPROCESSORS_ONLN)"
	fi
	make --jobs=$CORES_AVAILABLE
	make install
	rm -R ${SERVER_DIR}/compileopenttd
	if [ ! -f ${SERVER_DIR}/games/openttd ]; then 
		echo "---Something went wrong, couldn't install OpenTTD v$INSTALL_V---"
		sleep infinity
	else
		echo "---OpenTTD v$INSTALL_V installed---"
	fi
else
	echo "---OpenTTD v$LAT_V found---"
fi

if [ ! -d ${SERVER_DIR}/games/baseset ]; then
	echo "---OpenGFX not found, downloading...---"
	cd ${SERVER_DIR}/games
	mkdir ${SERVER_DIR}/games/baseset
	cd ${SERVER_DIR}/games/baseset
	if wget -q -nc --show-progress --progress=bar:force:noscroll -O opengfx-${GFX_PK_V}.zip https://cdn.openttd.org/opengfx-releases/${GFX_PK_V}/opengfx-${GFX_PK_V}-all.zip ; then
		echo "---Successfully downloaded OpenGFX---"
	else
		echo "---Can't download OpenGFX putting server into sleep mode---"
		sleep infinity
	fi
	unzip opengfx-${GFX_PK_V}.zip
	tar --strip-components=1 -xf opengfx-${GFX_PK_V}.tar
	rm opengfx-${GFX_PK_V}.zip opengfx-${GFX_PK_V}.tar
	GFX="$(find ${SERVER_DIR}/games/baseset -maxdepth 1 -name '*grf')"
	if [ -z "$GFX" ]; then
		echo "---Something went wrong, couldn't install OpenGFX---"
		sleep infinity
	fi
elif [ "$GFX_PK_CUR_V" != "$GFX_PK_V" ]; then
	echo "---Newer version for OpenGFX found, installing!---"
	rm -R ${SERVER_DIR}/games/baseset
	mkdir ${SERVER_DIR}/games/baseset
	cd ${SERVER_DIR}/games/baseset
	if wget -q -nc --show-progress --progress=bar:force:noscroll -O opengfx-${GFX_PK_V}.zip https://cdn.openttd.org/opengfx-releases/${GFX_PK_V}/opengfx-${GFX_PK_V}-all.zip ; then
		echo "---Successfully downloaded OpenGFX---"
	else
		echo "---Can't download OpenGFX putting server into sleep mode---"
		sleep infinity
	fi
	unzip opengfx-${GFX_PK_V}.zip
	tar --strip-components=1 -xf opengfx-${GFX_PK_V}.tar
	rm opengfx-${GFX_PK_V}.zip opengfx-${GFX_PK_V}.tar
	GFX="$(find ${SERVER_DIR}/games/baseset -maxdepth 1 -name '*grf')"
	if [ -z "$GFX" ]; then
		echo "---Something went wrong, couldn't install OpenGFX---"
		sleep infinity
	fi
else
	echo "---OpenGFX found---"
fi

echo "---Prepare Server---"
if [ ! -f ~/.screenrc ]; then
    echo "defscrollback 30000
bindkey \"^C\" echo 'Blocked. Please use to command \"exit\" to shutdown the server or close this window to exit the terminal.'" > ~/.screenrc
fi
chmod -R ${DATA_PERM} ${DATA_DIR}
echo "---Checking for old logs---"
find ${SERVER_DIR} -name "masterLog.*" -exec rm -f {} \;
echo "---Server ready---"

echo "---Start Server---"
cd ${SERVER_DIR}
screen -S OpenTTD -L -Logfile ${SERVER_DIR}/masterLog.0 -d -m ${SERVER_DIR}/games/openttd -D ${GAME_PARAMS}
sleep 2
if [ "${ENABLE_WEBCONSOLE}" == "true" ]; then
    /opt/scripts/start-gotty.sh 2>/dev/null &
fi
screen -S watchdog -d -m /opt/scripts/start-watchdog.sh
tail -f ${SERVER_DIR}/masterLog.0