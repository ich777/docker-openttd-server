#!/bin/bash

echo "---sleep---"
sleep infinity

echo "---Prepare Server---"
chmod -R 770 ${DATA_DIR}
echo "---Server ready---"

echo "---Start Server---"
${SERVER_DIR}/srcds_run -game ${GAME_NAME} ${GAME_PARAMS} -console +port ${GAME_PORT}



