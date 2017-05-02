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
            --gitlab-access-token)
                gitlab_ACCESS_TOKEN=${2} &&
                    shift &&
                    shift
            ;;
            --gitlab-user-id)
                gitlab_USER_ID=${2} &&
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
    blankout "${gitlab_ACCESS_TOKEN}" "gitlab_ACCESS_TOKEN is not defined." 65 &&
    blankout "${gitlab_USER_ID}" "gitlab_USER_ID is not defined." 66 &&
    blankout "${REPORT_PASSPHRASE}" "REPORT_PASSPHRASE is not defined." 67 &&
    noblankout "$(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.gitlab.dot_ssh)" "There is already a dot-ssh volume." 68 &&
    VOLUME=$(docker volume create --label com.emorymerryman.tstamp=$(date +%s) --label com.emorymerryman.thirdplanet.structure.gitlab.dot_ssh) &&
    docker run --interactive --tty --rm --volume ${VOLUME}:/srv wildwarehouse/chown:0.0.0 &&
    chmod(){
        docker run --interactive --tty --rm --volume ${VOLUME}:/home/user/.ssh wildwarehouse/fedora:0.0.0 chmod "${@}"
    } &&
    sshkeygen(){
        docker run --interactive --tty --rm --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.gitlab.dot_ssh):/home/user/.ssh bigsummer/ssh-keygen:0.0.0 "${@}"
    } &&
    curl(){
        docker run --interactive --rm --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.gitlab.dot_ssh):/home/user/.ssh bigsummer/curl:0.0.0 "${@}"
    } &&
    tee(){
        docker run --interactive --rm --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.gitlab.dot_ssh):/home/user/.ssh bigsummer/tee:0.0.0 "${@}"
    } &&
    ssh(){
        docker run --interactive --rm --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.gitlab.dot_ssh):/home/user/.ssh bigsummer/ssh:0.0.0 "${@}"
    } &&
    chmod 0700 /home/user/.ssh &&
    push_key(){
            sshkeygen -f /home/user/.ssh/${1}_id_rsa -P "${2}" -C "${1}" &&
            (cat <<EOF
{
    "title": "${1}",
    "key": "$(docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.gitlab.dot_ssh):/home/user/.ssh:ro \
        wildwarehouse/fedora:0.0.0 \
        cat /home/user/.ssh/${1}_id_rsa.pub)"
}
EOF
        ) | curl --header "Content-Type: application/x-www-form-urlencoded" --user "${gitlab_USER_ID}:${gitlab_ACCESS_TOKEN}" --data @- "https://api.gitlab.com/user/keys"
    } &&
    push_key upstream "" &&
    push_key origin "" &&
    push_key report ${REPORT_PASSPHRASE} &&
    (cat <<EOF
Host upstream
User git
HostName gitlab
IdentityFile ~/.ssh/upstream_id_rsa

Host origin
User git
HostName gitlab
IdentityFile ~/.ssh/origin_id_rsa

Host report
User git
HostName gitlab
IdentityFile ~/.ssh/report_id_rsa

EOF
    ) | tee /home/user/.ssh/config &&
    chmod 0600 /home/user/.ssh/config &&
    ssh -o StrictHostKeyChecking=no upstream