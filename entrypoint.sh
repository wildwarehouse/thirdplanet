#!/bin/sh

docker \
    run \
    --interactive \
    --rm \
    --env DISPLAY \
    --env HOST_UID=1000 \
    --env HOST_USER=aaja0ify \
    --env HOMEY=$(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.home) \
    --env WORKSPACE=$(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.workspace) \
    --env DOT_SSH=$(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.github.dot_ssh) \
    --env BIN=$(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.bin) \
    --env ENTRYPOINT=$(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.entrypoint) \
    --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.entrypoint):/opt/entrypoint \
    --volume /var/run/docker.sock:/var/run/docker.sock:ro \
    --workdir /opt/entrypoint/luckystar \
    docker/compose:1.11.2 ${@}
