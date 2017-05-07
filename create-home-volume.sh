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
    noblankout "$(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.home)" "There is already a home volume." 67 &&
    docker volume create --label com.emorymerryman.tstamp=$(date +%s) --label com.emorymerryman.luckystar.structure.home &&
    docker \
        run \
        --interactive \
        --tty \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.home):/usr/local/src \
        --workdir /usr/local/src \
        --user root \
        bigsummer/mkdir:0.0.0 \
        user &&
    docker \
        run \
        --interactive \
        --tty \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.home):/usr/local/src \
        --workdir /usr/local/src \
        --user root \
        bigsummer/chown:0.0.0 \
        user:user user &&
    docker \
        run \
        --interactive \
        --tty \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.home):/home \
        --entrypoint /usr/bin/sh \
        wildwarehouse/cloud9:0.0.0 \
        /opt/docker/install.sh &&
    docker \
        run \
        --interactive \
        --tty \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.home):/home \
        --workdir /home/user \
        bigsummer/ln:0.0.0 \
        --symbolic --force /srv/dot_ssh/.ssh .ssh &&
    docker \
        run \
        --interactive \
        --tty \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.home):/home \
        --workdir /home/user \
        bigsummer/ln:0.0.0 \
        --symbolic --force /srv/bin/bin bin