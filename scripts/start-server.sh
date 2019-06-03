#!/bin/bash
if [ ! -f ${SERVER_DIR}/games/openttd ]; then
	echo
    echo "-------------------------------------"
	echo "---OpenTTD not found! Downloading,---"
    echo "---compiling and installing v${GAME_VERSION}---"
    echo "---Please be patient, this can take--"
    echo "---some time, waiting 15 seconds..---"
    echo "-------------------------------------"
    sleep 15
    cd ${SERVER_DIR}
    wget -qO installed_v_${GAME_VERSION} https://github.com/OpenTTD/OpenTTD/archive/${GAME_VERSION}.zip
	unzip -d ${SERVER_DIR}/compileopenttd installed_v_${GAME_VERSION}
	COMPVDIR="$(find ${SERVER_DIR}/compileopenttd -name Open* -print -quit)"
	cd $COMPVDIR
	$COMPVDIR/configure --prefix-dir=/serverdata/serverfiles --enable-dedicated --personal-dir=/serverfiles/openttd
    if [ ! -z "${COMPILE_CORES}" ]; then
    	CORES_AVAILABLE=${COMPILE_CORES}
    else
		CORES_AVAILABLE="$(getconf _NPROCESSORS_ONLN)"
    fi
	make --jobs=$CORES_AVAILABLE
	make install
	rm -R ${SERVER_DIR}/compileopenttd
	if [ ! -f ${SERVER_DIR}/games/openttd ]; then 
		echo "---Something went wrong, couldn't install OpenTTD v${GAME_VERSION}---"
        sleep infinity
    else
    	echo "---OpenTTD v${GAME_VERSION} installed---"
    fi
    if [ ! -d ${SERVER_DIR}/games/baseset ]; then
    	echo "---OpenGFX not found, downloading...---"
        cd ${SERVER_DIR}/games
        mkdir baseset
        cd ${SERVER_DIR}/games/baseset
        wget -q ${GFXPACK_URL}
		unzip ${GFXPACK_URL##*/}
		TAR="$( echo "${GFXPACK_URL##*/}" | rev | cut -d "." -f2- | rev)"
		tar -xf $TAR.tar
        mv ${SERVER_DIR}/games/baseset/${TAR}/* ${SERVER_DIR}/games/baseset
		rm ${GFXPACK_URL##*/}
        rm -R $TAR
		rm $TAR.tar
        GFX="$(find ${SERVER_DIR}/games/baseset -maxdepth 1 -name *grf)"
        if [ -z "$GFX" ]; then
        	echo "---Something went wrong, couldn't install OpenGFX---"
            sleep infinity
        fi
	else
    	echo "---OpenGFX found---"
    fi
fi

CUR_V="$(find ${SERVER_DIR} -name installed_v_* | cut -d "_" -f3)"
if [ "${GAME_VERSION}" != "$CUR_V" ]; then
	echo
    echo "-------------------------------------------------"
	echo "---Version missmatch, installing newer Version---"
	echo "------Updating from v$CUR_V to v${GAME_VERSION}------"
    echo "----Please be patient this can take some time----"
    echo "---------------Waiting 15 seconds----------------"
    echo "-------------------------------------------------"
    echo
    sleep 15
    cd ${SERVER_DIR}
    rm installed_v_$CUR_V
    rm -R games
    rm -R shared
    wget -qO installed_v_${GAME_VERSION} https://github.com/OpenTTD/OpenTTD/archive/${GAME_VERSION}.zip
	unzip -d ${SERVER_DIR}/compileopenttd installed_v_${GAME_VERSION}
	COMPVDIR="$(find ${SERVER_DIR}/compileopenttd -name Open* -print -quit)"
	cd $COMPVDIR
	$COMPVDIR/configure --prefix-dir=/serverdata/serverfiles --enable-dedicated --personal-dir=/serverfiles/openttd
    if [ ! -z "${COMPILE_CORES}" ]; then
    	CORES_AVAILABLE=${COMPILE_CORES}
    else
		CORES_AVAILABLE="$(getconf _NPROCESSORS_ONLN)"
    fi
	make --jobs=$CORES_AVAILABLE
	make install
	rm -R ${SERVER_DIR}/compileopenttd
	if [ ! -f ${SERVER_DIR}/games/openttd ]; then 
		echo "---Something went wrong, couldn't install OpenTTD v${GAME_VERSION}---"
        sleep infinity
    else
    	echo "---OpenTTD v${GAME_VERSION} installed---"
    fi
    if [ ! -d ${SERVER_DIR}/games/baseset ]; then
    	echo "---OpenGFX not found, downloading...---"
        cd ${SERVER_DIR}/games
        mkdir baseset
        cd ${SERVER_DIR}/games/baseset
        wget -q ${GFXPACK_URL}
		unzip ${GFXPACK_URL##*/}
		TAR="$( echo "${GFXPACK_URL##*/}" | rev | cut -d "." -f2- | rev)"
		tar -xf $TAR.tar
        mv ${SERVER_DIR}/games/baseset/${TAR}/* ${SERVER_DIR}/games/baseset
		rm ${GFXPACK_URL##*/}
        rm -R $TAR
		rm $TAR.tar
        GFX="$(find ${SERVER_DIR}/games/baseset -maxdepth 1 -name *grf)"
        if [ -z "$GFX" ]; then
        	echo "---Something went wrong, couldn't install OpenGFX---"
            sleep infinity
        fi
	else
    	echo "---OpenGFX found---"
    fi
fi

echo "---Prepare Server---"
chmod -R 770 ${DATA_DIR}
echo "---Checking for old logs---"
find ${SERVER_DIR} -name "masterLog.*" -exec rm -f {} \;
echo "---Server ready---"

echo "---Start Server---"
cd ${SERVER_DIR}
screen -S OpenTTD -L -Logfile ${SERVER_DIR}/masterLog.0 -d -m ${SERVER_DIR}/games/openttd -D ${GAME_PARAMS}
sleep 2
tail -f ${SERVER_DIR}/masterLog.0