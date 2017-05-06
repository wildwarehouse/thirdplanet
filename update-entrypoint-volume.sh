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
            --branch)
                BRANCH=${2} &&
                    shift &&
                    shift
            ;;
            *)
                echo Unknown Option: ${1} &&
                    exit 64
            ;;
        esac
    done &&
    blankout "${BRANCH}" "There is no BRANCH defined" 65 &&
    blankout "$(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.github.dot_ssh)" "There is no dot_ssh volume." 66 &&
    blankout "$(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.entrypoint)" "There is no entrypoint volume." 67 &&
    BIN=$(docker volume create --label com.emorymerryman.tstamp=$(date +%s) --label com.emorymerryman.temporary) &&
    SBIN=$(docker volume create --label com.emorymerryman.tstamp=$(date +%s) --label com.emorymerryman.temporary) &&
    SUDO=$(docker volume create --label com.emorymerryman.tstamp=$(date +%s) --label com.emorymerryman.temporary) &&
    (cat <<EOF
#!/bin/sh

docker \
    run \
    --interactive \
    --rm \
    --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.github.dot_ssh):/home/user \
    --volume $(docker volume ls --quiet --filter  label=com.emorymerryman.luckystar.structure.entrypoint):/usr/local/src \
    --workdir /usr/local/src/luckystar \
    bigsummer/ssh:0.0.0 \
    "\${@}"
EOF
) | docker \
    run \
    --interactive \
    --rm \
    --volume ${SBIN}:/usr/local/src \
    --workdir /usr/local/src \
    --user root \
    bigsummer/tee:0.0.0 \
    ssh.sh &&
    (cat <<EOF
user ALL=(ALL) NOPASSWD:/usr/local/sbin/ssh.sh
EOF
) | docker \
    run \
    --interactive \
    --rm \
    --volume ${SUDO}:/usr/local/src \
    --workdir /usr/local/src \
    --user root \
    bigsummer/tee:0.0.0 \
    ssh &&
    (cat <<EOF
#!/bin/sh

sudo /usr/local/sbin/ssh.sh "\${@}"
EOF
) | docker \
    run \
    --interactive \
    --rm \
    --volume ${BIN}:/usr/local/src \
    --workdir /usr/local/src \
    --user root \
    bigsummer/tee:0.0.0 \
    ssh &&
    docker \
        run \
        --interactive \
        --rm \
        --volume ${SBIN}:/usr/local/src \
        --workdir /usr/local/src \
        --user root \
        bigsummer/chmod:0.0.0 \
        0500 ssh.sh &&
    docker \
        run \
        --interactive \
        --rm \
        --volume ${BIN}:/usr/local/src \
        --workdir /usr/local/src \
        --user root \
        bigsummer/chmod:0.0.0 \
        0555 ssh &&
    docker \
        run \
        --interactive \
        --rm \
        --volume /var/run/docker.sock:/var/run/docker.sock:ro \
        --volume ${BIN}:/usr/local/bin:ro \
        --volume ${SBIN}:/usr/local/sbin:ro \
        --volume ${SUDO}:/etc/sudoers.d:ro \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.entrypoint):/usr/local/src \
        --volume /var/run/docker.sock:/var/run/docker.sock:ro \
        --workdir /usr/local/src/luckystar \
        bigsummer/git:0.0.0 \
        fetch upstream ${BRANCH} &&
    docker volume rm ${BIN} ${SBIN} ${SUDO} &&
    docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.entrypoint):/usr/local/src \
        --workdir /usr/local/src/luckystar \
        wildwarehouse/git:0.0.0 \
        checkout upstream/${BRANCH}