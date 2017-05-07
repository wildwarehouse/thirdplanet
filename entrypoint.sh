#!/bin/sh

docker \
    run \
    --interactive \
    --rm \
    --env DISPLAY \
    --env HOST_UID=1000 \
    --env HOST_USER=aaja0ify \
    --env BIN=$(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.bin) \
    --env SUDO=$(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.sudo) \
    --env SBIN=$(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.sbin) \
    --env WORKSPACE=$(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.workspace) \
    --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.entrypoint):/opt/entrypoint \
    --volume /var/run/docker.sock:/var/run/docker.sock:ro \
    --workdir /opt/entrypoint/luckystar \
    docker/compose:1.11.2 ${@}
