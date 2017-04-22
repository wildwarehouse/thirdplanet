#!/bin/sh

errorout(){
    if [ ${1} ]
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
    errorout [ -z "${GITHUB_ACCESS_TOKEN}" ] "GITHUB_ACCESS_TOKEN is not defined." 65 &&
    errorout [ -z "${GITHUB_USER_ID}" ] "GITHUB_USER_ID is not defined." 66 &&
    errorout [ -z "${REPORT_PASSPHRASE}" ] "REPORT_PASSPHRASE is not defined." 67 &&
    errorout [ ! -z "$(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot-ssh)" ] "There is already a dot-ssh volume." 68 &&
    docker volume create --label com.emorymerryman.tstamp=$(date +%s) --label com.emorymerryman.thirdplanet.structure.github.dot-ssh &&
    docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot-ssh):/root/.ssh \
        --workdir /root/.ssh \
        --entrypoint chmod \
        alpine:3.4 \
        0700 . &&
    docker \
        run \
        --interactive \
        --rm \
        --entrypoint ssh-keygen \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot-ssh):/root/.ssh \
        --workdir /root/.ssh \
        tidyrailroad/openssh-client:0.0.0 \
        -f /root/.ssh/upstream_id_rsa -P "" -C "upstream" &&
    (cat <<EOF
{
    "title": "upstream",
    "key": "$(docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot-ssh):/root/.ssh:ro \
        --workdir /root/.ssh \
        alpine:3.4 \
        cat upstream_id_rsa.pub)"
}
EOF
    ) | docker \
        run \
        --interactive \
        --rm \
        tidyrailroad/curl:0.0.0 \
        --header "Content-Type: application/x-www-form-urlencoded" --user "${GITHUB_USER_ID}:${GITHUB_ACCESS_TOKEN}" --data @- "https://api.github.com/user/keys" &&
    docker \
        run \
        --interactive \
        --rm \
        --entrypoint ssh-keygen \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot-ssh):/root/.ssh \
        --workdir /root/.ssh \
        tidyrailroad/openssh-client:0.0.0 \
        -f /root/.ssh/origin_id_rsa -P "" -C "origin" &&
    (cat <<EOF
{
    "title": "origin",
    "key": "$(docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot-ssh):/root/.ssh:ro \
        --workdir /root/.ssh \
        alpine:3.4 \
        cat origin_id_rsa.pub)"
}
EOF
    ) | docker \
        run \
        --interactive \
        --rm \
        tidyrailroad/curl:0.0.0 \
        --header "Content-Type: application/x-www-form-urlencoded" --user "${GITHUB_USER_ID}:${GITHUB_ACCESS_TOKEN}" --data @- "https://api.github.com/user/keys" &&
    docker \
        run \
        --interactive \
        --rm \
        --entrypoint ssh-keygen \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot-ssh):/root/.ssh \
        --workdir /root/.ssh \
        tidyrailroad/openssh-client:0.0.0 \
        -f /root/.ssh/report_id_rsa -P "${REPORT_PASSPHRASE}" -C "report" &&
    (cat <<EOF
{
    "title": "report",
    "key": "$(docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot-ssh):/root/.ssh:ro \
        --workdir /root/.ssh \
        alpine:3.4 \
        cat report_id_rsa.pub)"
}
EOF
    ) | docker \
        run \
        --interactive \
        --rm \
        tidyrailroad/curl:0.0.0 \
        --header "Content-Type: application/x-www-form-urlencoded" --user "${GITHUB_USER_ID}:${GITHUB_ACCESS_TOKEN}" --data @- "https://api.github.com/user/keys" &&
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
    ) | docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot-ssh):/root/.ssh \
        --workdir /root/.ssh \
        --entrypoint tee \
        alpine:3.4 \
        config &&
    docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot-ssh):/root/.ssh \
        --workdir /root/.ssh \
        --entrypoint chmod \
        alpine:3.4 \
        0600 config &&
    docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot-ssh):/root/.ssh \
        tidyrailroad/openssh-client:0.0.0 \
        -o StrictHostKeyChecking=no upstream