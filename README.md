# OpenTTD Dedicated Server in Docker optimized for Unraid

This Docker will download and install the version of OpenTTD that you enter in the variable 'GAME_VERSION' (if you define 'latest' it will always pull the latest build, if you define 'testing' it will always pull down the latest testing build).


WEB CONSOLE: You can connect to the OpenTTD console by opening your browser and go to HOSTIP:9015 (eg: 192.168.1.1:9015) or click on WebUI on the Docker page within Unraid.

Update Notice: If there is a newer version simply restart the container to update it to the latest version.


## Env params

| Name | Value | Example |
| --- | --- | --- |
| SERVER_DIR | Folder for gamefiles | /serverdata/serverfiles |
| GAME_PARAMS | Commandline startup parameters | [empty] |
| GAME_VERSION | Preferred game version | latest |
| GFX_PK_V | Preferred GFX Version | latest |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |


***To load the last autosavegame you MUST specifie the following in the GAME_PARAMETERS variable: '-g /serverdata/serverfiles/.local/share/openttd/save/autosave/autosave0.sav'***

# Run example

```
docker run --name OpenTTD -d \
    -p 3979:3979/tcp \
    -p 3979:3979/udp \
    -p 9015:8080/tcp \
    --env 'GAME_PARAMS=' \
    --env 'GAME_VERSION=latest' \
    --env 'GFX_PK_V=latest' \
    --env 'UID=99' \
    --env 'GID=100' \
    --volume /mnt/cache/appdata/openttd:/serverdata/serverfiles \
    --restart=unless-stopped \
    ich777/openttdserver:latest
```

This Docker was mainly created for the use with Unraid, if you don’t use Unraid you should definitely try it!

#### Support Thread: https://forums.unraid.net/topic/79530-support-ich777-gameserver-dockers/