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
    blankout "$(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot_ssh)" "There is no dot_ssh volume." 66 &&
    noblankout "$(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.bin)" "There is already a entrypoint volume." 67 &&
    docker volume create --label com.emorymerryman.tstamp=$(date +%s) --label com.emorymerryman.thirdplanet.structure.bin &&
    docker run --interactive --tty --rm --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.bin):/srv wildwarehouse/chown:0.0.0 &&
    docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.bin):/home/user \
        --workdir /home/user \
        bigsummer/git:0.0.0 \
        init &&
     docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.bin):/home/user \
        --workdir /home/user \
        bigsummer/git:0.0.0 \
        remote add upstream ssh://upstream/wildwarehouse/thirdplanet.git &&
    BIN=$(docker volume create --label com.emorymerryman.tstamp=$(date +%s) --label com.emorymerryman.temporary) &&
    SBIN=$(docker volume create --label com.emorymerryman.tstamp=$(date +%s) --label com.emorymerryman.temporary) &&
    SUDO=$(docker volume create --label com.emorymerryman.tstamp=$(date +%s) --label com.emorymerryman.temporary) &&
    (cat <<EOF
#!/bin/sh

docker \
    run \
    --interactive \
    --rm \
    --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot_ssh):/home/user/.ssh \
    --volume $(docker volume ls --quiet --filter  label=com.emorymerryman.thirdplanet.structure.bin):/usr/local/src \
    --workdir /usr/local/src \
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
        --volume ${SUDO}:/usr/local/src \
        --workdir /usr/local/src \
        --user root \
        bigsummer/chmod:0.0.0 \
        0444 ssh &&
    docker \
        run \
        --interactive \
        --rm \
        --volume /var/run/docker.sock:/var/run/docker.sock:ro \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.bin):/home/user \
        --volume ${BIN}:/usr/local/bin:ro \
        --volume ${SBIN}:/usr/local/sbin:ro \
        --volume ${SUDO}:/etc/sudoers.d:ro \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.bin):/home/user \
        --volume /var/run/docker.sock:/var/run/docker.sock:ro \
        --workdir /home/user \
        bigsummer/git:0.0.0 \
        remote -v &&
    docker \
        run \
        --interactive \
        --rm \
        --volume /var/run/docker.sock:/var/run/docker.sock:ro \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.bin):/home/user \
        --volume ${BIN}:/usr/local/bin:ro \
        --volume ${SBIN}:/usr/local/sbin:ro \
        --volume ${SUDO}:/etc/sudoers.d:ro \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.bin):/home/user \
        --volume /var/run/docker.sock:/var/run/docker.sock:ro \
        --workdir /home/user \
        bigsummer/git:0.0.0 \
        fetch upstream ${BRANCH} &&
    docker volume rm ${BIN} ${SBIN} ${SUDO} &&
    docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.bin):/home/user \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.bin):/usr/local/src \
        --workdir /usr/local/src \
        bigsummer/git:0.0.0 \
        checkout upstream/${BRANCH}