#!/bin/bash



cd ${SERVER_DIR}
wget -qO ${GAME_VERSION} https://github.com/OpenTTD/OpenTTD/archive/1.9.1.zip
unzip -d ${SERVER_DIR}/compileopenttd ${GAME_VERSION}
COMPVDIR="$(find ${SERVER_DIR}/compileopenttd -name Open* -print -quit)"
cd $COMPVDIR
$COMPVDIR/configure --prefix-dir=/serverdata/serverfiles --enable-dedicated --personal-dir=/serverfiles/openttd
CORES_AVAILABLE="$(getconf _NPROCESSORS_ONLN)"
make --jobs=$CORES_AVAILABLE
make install
rm -R ${SERVER_DIR}/compileopenttd
cd ${SERVER_DIR}/games
mkdir baseset
cd ${SERVER_DIR}/games/baseset


wget -q ${GFXPACK_URL}
unzip ${GFXPACK_URL##*/}
TAR="$( echo "${GFXPACK_URL##*/}" | rev | cut -d "." -f2- | rev)"
tar -xf $TAR.tar
rm ${GFXPACK_URL##*/}
rm $TAR.tar


echo "---sleep---"
sleep infinity

echo "---Prepare Server---"
chmod -R 770 ${DATA_DIR}
echo "---Server ready---"

echo "---Start Server---"
cd ${SERVER_DIR}
${SERVER_DIR}/games/openttd -D ${GAME_PARAMS}