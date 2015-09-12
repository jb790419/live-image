#!/bin/bash
getuser() {
set -- $(cat /proc/cmdline)
for x in "$@"; do
    case "$x" in
        username=*)
        echo "${x#username=}"
        ;;
    esac
done
}

repoattach() {
mkdir -p /tmp/backup/$(getuser)
sshfs root@nas:/i-data/md0/backup/$(getuser) /tmp/backup/$(getuser)
}

repodetach() {
fusermount -u /tmp/backup/$(getuser)
rmdir /tmp/backup/$(getuser)
}

getrepo() {
echo "/tmp/backup/$(getuser)/repository.attic"
}

getarch() {
attic list $(getrepo) | tail -n 1 | awk '{print $1}'
}

getlocales() {
set -- $(cat /proc/cmdline)
for x in "$@"; do
    case "$x" in
        locales=*)
        echo "${x#locales=}"
        ;;
    esac
done

}

restore() {
export LANG=$(getlocales)
echo "in restore"
pushd /
repoattach
attic extract $(getrepo)::$(getarch)
repodetach
popd
}

backup() {
echo 'in backup'
repoattach
attic create $(getrepo)::$(date --iso-8601=seconds) /home/$(getuser)
repodetach
}

case $1 in
    backup|restore) "$1" ;;
esac
