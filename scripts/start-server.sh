#!/bin/bash
echo "---Container under construction---"
sleep infinity
CUR_V="$(find ${SERVER_DIR} -name installed_v_* | cut -d "_" -f3)"
if [ "${GAME_VERSION}" = "latest" ]; then
  echo "---Trying to get latest stable OpenTTD version...---"
  LAT_V="$(curl -s https://cdn.openttd.org/openttd-releases/latest.yaml | grep -B1 "stable" | grep "version:" | cut -d ' ' -f3)"
  if [ ! -z ${LAT_V} ]; then
    echo "---Latest stable OpenTTD version is: $LAT_V---"
  fi
elif [ "${GAME_VERSION}" = "testing" ]; then
  echo "---Trying to get latest testing OpenTTD version...---"
  LAT_V="$(curl -s https://cdn.openttd.org/openttd-releases/latest.yaml | grep -B1 "testing" | grep "version:" | cut -d ' ' -f3)"
  if [ ! -z ${LAT_V} ]; then
    echo "---Latest testing OpenTTD version is: $LAT_V---"
  fi
fi

if [ -z $LAT_V ]; then
  if [ -z $CUR_V ]; then
    echo "---Something went wrong, couldn't get latest version---"
    sleep infinity
  else
    echo "---Can't get latest OpenTTD build version, falling back to installed version $CUR_V!---"
    LAT_V=$CUR_V
  fi
fi

GFX_PK_CUR_V="$(cat ${SERVER_DIR}/baseset/changelog.txt 2>/dev/null | head -1 | cut -d ' ' -f2)"
if [ "${GFX_PK_V}" = "latest" ]; then
  echo "---Getting latest OpenGFX version...---"
  GFX_PK_V="$(curl -s https://cdn.openttd.org/opengfx-releases/latest.yaml | grep "version:" | cut -d ' ' -f3)"
  if [ -z ${GFX_PK_V} ]; then
    if [ -z $GFX_PK_CUR_V ]; then
      echo "---Something went wrong, couldn't get latest build version---"
      sleep infinity
    else
      echo "---Can't get latest OpenGFX version, falling back to installed version $GFX_PK_CUR_V!---"
      GFX_PK_V=$GFX_PK_CUR_V
    fi
  else
    echo "---Latest OpenGFX version is: $GFX_PK_V---"
  fi
else
  echo "---Manually set OpenGFX version to ${GFX_PK_V}---"
fi

if [ ! -s ${SERVER_DIR}/installed_v_$LAT_V ]; then
  rm -rf ${SERVER_DIR}/installed_v_$LAT_V
fi

echo "---Version Check---"
if [ ! -f ${SERVER_DIR}/openttd ]; then
  echo
  echo "-------------------------------------"
  echo "---OpenTTD not found! Downloading,---"
  echo "-----and installing v$LAT_V-----"
  echo "-------------------------------------"
  cd ${SERVER_DIR}
  if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${SERVER_DIR}/installed_v_${LAT_V} https://cdn.openttd.org/openttd-releases/${LAT_V}/openttd-${LAT_V}-linux-generic-amd64.tar.xz ; then
    echo "---Successfully downloaded OpenTTD v$LAT_V---"
  else
    echo "---Can't download OpenTTD v$LAT_V putting server into sleep mode---"
    sleep infinity
  fi
  tar --strip-components=1 -xf installed_v_$LAT_V -C ${SERVER_DIR}/
elif [ "$INSTALL_V" != "$CUR_V" ]; then
  echo
  echo "-------------------------------------------------"
  echo "-----Version missmatch, installing v$LAT_V-----"
  echo "-------------------------------------------------"
  echo
  cd ${SERVER_DIR}
  if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${SERVER_DIR}/installed_v_${LAT_V} https://cdn.openttd.org/openttd-releases/${LAT_V}/openttd-${LAT_V}-linux-generic-amd64.tar.xz ; then
    echo "---Successfully downloaded OpenTTD v$LAT_V---"
  else
    echo "---Can't download OpenTTD v$LAT_V putting server into sleep mode---"
    sleep infinity
  fi
  tar --strip-components=1 -xf installed_v_$LAT_V -C ${SERVER_DIR}/
else
	echo "---OpenTTD v$LAT_V found---"
fi

if [ ! -f ${SERVER_DIR}/baseset/changelog.txt ]; then
  echo "---OpenGFX not found, downloading...---"
  cd ${SERVER_DIR}
  if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${SERVER_DIR}/opengfx-${GFX_PK_V}.zip https://cdn.openttd.org/opengfx-releases/${GFX_PK_V}/opengfx-${GFX_PK_V}-all.zip ; then
    echo "---Successfully downloaded OpenGFX---"
  else
    echo "---Can't download OpenGFX putting server into sleep mode---"
    sleep infinity
  fi
  unzip ${SERVER_DIR}/opengfx-${GFX_PK_V}.zip
  tar --strip-components=1 -xf ${SERVER_DIR}/opengfx-${GFX_PK_V}.tar -C ${SERVER_DIR}/baseset/
  rm ${SERVER_DIR}/opengfx-${GFX_PK_V}.zip ${SERVER_DIR}/opengfx-${GFX_PK_V}.tar
elif [ "$GFX_PK_CUR_V" != "$GFX_PK_V" ]; then
  echo "---Newer version for OpenGFX found, installing!---"
  cd ${SERVER_DIR}
  if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${SERVER_DIR}/opengfx-${GFX_PK_V}.zip https://cdn.openttd.org/opengfx-releases/${GFX_PK_V}/opengfx-${GFX_PK_V}-all.zip ; then
    echo "---Successfully downloaded OpenGFX---"
  else
    echo "---Can't download OpenGFX putting server into sleep mode---"
    sleep infinity
  fi
  unzip ${SERVER_DIR}/opengfx-${GFX_PK_V}.zip
  tar --strip-components=1 -xf ${SERVER_DIR}/opengfx-${GFX_PK_V}.tar -C ${SERVER_DIR}/baseset/
  rm ${SERVER_DIR}/opengfx-${GFX_PK_V}.zip ${SERVER_DIR}/opengfx-${GFX_PK_V}.tar
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
screen -S OpenTTD -L -Logfile ${SERVER_DIR}/masterLog.0 -d -m ${SERVER_DIR}/openttd -D ${GAME_PARAMS}
sleep 2
if [ "${ENABLE_WEBCONSOLE}" == "true" ]; then
    /opt/scripts/start-gotty.sh 2>/dev/null &
fi
screen -S watchdog -d -m /opt/scripts/start-watchdog.sh
tail -f ${SERVER_DIR}/masterLog.0