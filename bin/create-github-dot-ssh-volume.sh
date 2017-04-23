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
            --github-access-token)
                GITHUB_ACCESS_TOKEN=${2} &&
                    shift &&
                    shift
            ;;
            --github-user-id)
                GITHUB_USER_ID=${2} &&
                    shift &&
                    shift
            ;;
            --report-passphrase)
                REPORT_PASSPHRASE=${2} &&
                    shift &&
                    shift
            ;;
            *)
                echo Unknown Option: ${1} &&
                    exit 64
            ;;
        esac
    done &&
    blankout "${GITHUB_ACCESS_TOKEN}" "GITHUB_ACCESS_TOKEN is not defined." 65 &&
    blankout "${GITHUB_USER_ID}" "GITHUB_USER_ID is not defined." 66 &&
    blankout "${REPORT_PASSPHRASE}" "REPORT_PASSPHRASE is not defined." 67 &&
    noblankout "$(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot_ssh)" "There is already a dot-ssh volume." 68 &&
    VOLUME=$(docker volume create --label com.emorymerryman.tstamp=$(date +%s) --label com.emorymerryman.thirdplanet.structure.github.dot_ssh) &&
    docker run --interactive --tty --rm --volume ${VOLUME}:/srv wildwarehouse/chown:0.0.0 &&
    echo ${VOLUME} &&
    docker run --interactive --tty --rm --volume ${VOLUME}:/srv/alpha wildwarehouse/fedora:0.0.0 touch /srv/alpha/good1 &&
    docker run --interactive --tty --rm --volume ${VOLUME}:/srv/alpha wildwarehouse/fedora:0.0.0 touch /srv/alpha/good2 &&
    docker run --interactive --tty --rm --volume ${VOLUME}:/srv/alpha wildwarehouse/fedora:0.0.0 chmod 0700 /srv/alpha &&
    echo ${VOLUME} &&
    chmod(){
        echo BEFORE &&
        docker run --interactive --tty --rm --volume ${VOLUME}:/srv/alpha --workdir /srv/alpha wildwarehouse/fedora:0.0.0 chmod "${@}" &&
        echo AFTER
    } &&
    sshkeygen(){
        docker run --interactive --tty --rm --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot_ssh):/home/user/.ssh --workdir /home/user/.ssh bigsummer/ssh-keygen:0.0.0 "${@}"
    } &&
    curl(){
        docker run --interactive --tty --rm --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot_ssh):/home/user/.ssh --workdir /home/user/.ssh bigsummer/curl:0.0.0 "${@}"
    } &&
    tee(){
        docker run --interactive --rm --tty --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot_ssh):/home/user/.ssh --workdir /home/user/.ssh bigsummer/tee:0.0.0 "${@}"
    } &&
    ssh(){
        docker run --interactive --tty --rm --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot_ssh):/home/user/.ssh --workdir /home/user/.ssh bigsummer/ssh:0.0.0 "${@}"
    } &&
    push_key(){
        chmod 0700 . &&
            ssh-keygen /home/.ssh/${1}_id_rsa -P "${2}" -C "${1}" &&
            (cat <<EOF
{
    "title": "${1}",
    "key": "$(docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot_ssh):/root/.ssh:ro \
        --workdir /root/.ssh \
        alpine:3.4 \
        cat ${1}_id_rsa.pub)"
}
EOF
        ) | curl --header "Content-Type: application/x-www-form-urlencoded" --user "${GITHUB_USER_ID}:${GITHUB_ACCESS_TOKEN}" --data @- "https://api.github.com/user/keys"
    } &&
    push_key upstream "" &&
    push_key origin "" &&
    push_key report ${REPORT_PASSPHRASE} &&
    (cat <<EOF
Host upstream
User git
HostName github.com
IdentityFile ~/.ssh/upstream_id_rsa

Host origin
User git
HostName github.com
IdentityFile ~/.ssh/origin_id_rsa

Host report
User git
HostName github.com
IdentityFile ~/.ssh/report_id_rsa

EOF
    ) | tee config &&
    chmod 0600 config &&
    ssh -o StrictHostKeyChecking=no upstream