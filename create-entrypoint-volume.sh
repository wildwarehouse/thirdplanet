#!/bin/sh

blankout(){
    if [ -z "${1}" ]
    then
        echo ${2} &&
            exit ${3}
    fi
} &&
    noblankout(){
        if [ ! -z "${1}" ]
        then
            echo ${2} &&
                exit ${3}
        fi
    } &&
    while [ ${#} -gt 0 ]
    do
        case ${1} in
            *)
                echo Unknown Option: ${1} &&
                    exit 64
            ;;
        esac
    done &&
    blankout "$(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.github.dot_ssh)" "There is no dot_ssh volume." 66 &&
    noblankout "$(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.entrypoint)" "There is already an entrypoint volume." 67 &&
    docker volume create --label com.emorymerryman.tstamp=$(date +%s) --label com.emorymerryman.luckystar.structure.entrypoint &&
    docker \
        run \
        --interactive \
        --tty \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.entrypoint):/usr/local/src \
        --workdir /usr/local/src \
        --user root \
        bigsummer/mkdir:0.0.0 \
        luckystar &&
     docker \
        run \
        --interactive \
        --tty \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.entrypoint):/usr/local/src \
        --workdir /usr/local/src \
        --user root \
        bigsummer/chown:0.0.0 \
        user:user luckystar &&
    docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.entrypoint):/usr/local/src \
        --workdir /usr/local/src/luckystar \
        wildwarehouse/git:0.0.0 \
        init &&
     docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.entrypoint):/usr/local/src \
        --workdir /usr/local/src/luckystar \
        wildwarehouse/git:0.0.0 \
        remote add upstream ssh://upstream/wildwarehouse/coldbreeze.git