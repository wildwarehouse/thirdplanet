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
    noblankout "$(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.bin)" "There is already a bin volume." 67 &&
    docker volume create --label com.emorymerryman.tstamp=$(date +%s) --label com.emorymerryman.luckystar.structure.bin &&
    docker \
        run \
        --interactive \
        --tty \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.bin):/usr/local/src \
        --workdir /usr/local/src \
        --user root \
        bigsummer/mkdir:0.0.0 \
        bin &&
     docker \
        run \
        --interactive \
        --tty \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.bin):/usr/local/src \
        --workdir /usr/local/src \
        --user root \
        bigsummer/chown:0.0.0 \
        user:user bin &&
    docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.bin):/usr/local/src \
        --workdir /usr/local/src/bin \
        wildwarehouse/git:0.0.0 \
        init &&
     docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.bin):/usr/local/src \
        --workdir /usr/local/src/bin \
        wildwarehouse/git:0.0.0 \
        remote add upstream ssh://upstream/wildwarehouse/thirdplanet.git &&
    BIN=$(docker volume create --label com.emorymerryman.tstamp=$(date +%s) --label com.emorymerryman.temporary) &&
    SBIN=$(docker volume create --label com.emorymerryman.tstamp=$(date +%s) --label com.emorymerryman.temporary) &&
    SUDO=$(docker volume create --label com.emorymerryman.tstamp=$(date +%s) --label com.emorymerryman.temporary) &&
    (cat <<EOF
#!/bin/sh

echo AAAA 0020 >> /tmp/log.txt "\${@}" &&
docker \
    run \
    --interactive \
    --rm \
    --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.github.dot_ssh):/home/user \
    --volume $(docker volume ls --quiet --filter  label=com.emorymerryman.luckystar.structure.bin):/usr/local/src \
    --workdir /usr/local/src/bin \
    bigsummer/ssh:0.0.0 \
    \${@}
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

echo AAAA 0010 >> /tmp/log.txt "\${@}" &&
sudo /usr/local/sbin/ssh.sh \${@}
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
    echo AAAA 0000 &&
    (docker \
        run \
        --interactive \
        --rm \
        --volume /var/run/docker.sock:/var/run/docker.sock:ro \
        --volume ${BIN}:/usr/local/bin:ro \
        --volume ${SBIN}:/usr/local/sbin:ro \
        --volume ${SUDO}:/etc/sudoers.d:ro \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.bin):/usr/local/src \
        --volume /var/run/docker.sock:/var/run/docker.sock:ro \
        --workdir /usr/local/src/bin \
        --tty \
        --entrypoint bash \
        bigsummer/git:0.0.0 || echo WTF ) &&
    echo AAAA 0001 &&
    docker \
        run \
        --interactive \
        --rm \
        --volume /var/run/docker.sock:/var/run/docker.sock:ro \
        --volume ${BIN}:/usr/local/bin:ro \
        --volume ${SBIN}:/usr/local/sbin:ro \
        --volume ${SUDO}:/etc/sudoers.d:ro \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.bin):/usr/local/src \
        --volume /var/run/docker.sock:/var/run/docker.sock:ro \
        --workdir /usr/local/src/bin \
        --env GIT_SSH=/usr/local/bin/ssh \
        --env GIT_SSH_COMMAND=/usr/local/bin/ssh \
        bigsummer/git:0.0.0 \
        fetch upstream ${BRANCH} &&
    echo AAAA 0002 &&
    echo AAAA 1000 &&
    docker volume rm ${BIN} ${SBIN} ${SUDO} &&
    docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.bin):/usr/local/src \
        --workdir /usr/local/src/bin \
        wildwarehouse/git:0.0.0 \
        checkout upstream/${BRANCH}