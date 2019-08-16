# OpenTTD Dedicated Server in Docker optimized for Unraid

This Docker will download and install the version of OpenTTD that you enter in the variable 'GAME_VERSION' (if you define 'latest' it will always pull the latest build).


CONSOLE: If you want to connect to the console open a Terminal and type in 'screen -xS OpenTTD' (without quotes).
Compile Note: Assigning fewer cores for compiling will result in slower startup on the first start up and updates, RECOMMENDED: leave the 'Compile Cores' blank to use all available cores).
Update Notice: If there is a newer version if set to 'latest' simply restart the container to update it to the latest version. If you want to update from an older build simply set the new build number or set to latest. You can also downgrade to another version.


## Env params

| Name | Value | Example |
| --- | --- | --- |
| SERVER_DIR | Folder for gamefile | /serverdata/serverfiles |
| GAME_PARAMS | Commandline startup parameters | [empty] |
| GAME_VERSION | Preferred game version | latest |
| GFXPACK_URL | GFX Pack URL | http://bundles.openttdcoop.org/opengfx/releases/0.5.5/opengfx-0.5.5.zip |
| COMPILE_CORES | Compile cores to use | [empty] |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |
| GAME_PORT | Port the server will be running on | 11753 |

##### To load the last autosavegame you MUST specifie the following '-D -g /serverdata/serverfiles/openttd/save/autosave/autosave0.sav' you can also customize the path but it begins always with '/serverdata/serverfiles/'

# Run example

docker run --name OpenTTD -d \
    -p 3979:3979/tcp \
    -p 3979:3979/udp \
    --env 'GAME_PARAMS=' \
    --env 'GAME_VERSION=latest' \
    --env 'GFXPACK_URL=http://bundles.openttdcoop.org/opengfx/releases/0.5.5/opengfx-0.5.5.zip' \
    --env 'COMPILE_CORES=' \
    --env 'UID=99' \
    --env 'GID=100' \
    --volume /mnt/user/appdata/openttd:/serverdata/serverfiles \
    --restart=unless-stopped \
    ich777/openttdserver:latest

This Docker was mainly created for the use with Unraid, if you don’t use Unraid you should definitely try it!

#### Support Thread: https://forums.unraid.net/topic/79530-support-ich777-gameserver-dockers/