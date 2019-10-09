#!bin/sh

echo "Starting container..."

# test for mandatory environment variables
[ -z "$RESTIC_REPOSITORY" ] && echo "RESTIC_REPOSITORY an not be empty. Exiting." && exit 1
[ -z "$RESTIC_PASSWORD" ] && echo "RESTIC_PASSWORD can not be empty. Exiting." && exit 1
[ -z "$RESTIC_SSH_KEY" ] && echo "RESTIC_SSH_KEY can not be empty. Exiting." && exit 1

# output ssh key as file
mkdir -p ~/.ssh
echo "${RESTIC_SSH_KEY}" > ~/.ssh/restic_ssh_key
chmod 400 ~/.ssh/restic_ssh_key

# check repo
restic snapshots &>/dev/null
status=$?
echo "Check Repo status $status"

if [ $status != 0 ]; then
    echo "Restic repository '${RESTIC_REPOSITORY}' does not exists. Running restic init."
    restic init

    init_status=$?
    echo "Repo init status $init_status"

    if [ $init_status != 0 ]; then
        echo "Failed to init the repository: '${RESTIC_REPOSITORY}'"
        exit 1
    fi
fi

echo "Setup backup cron job with cron expression BACKUP_CRON: ${BACKUP_CRON}"
echo "${BACKUP_CRON} /bin/backup >> /var/log/cron.log 2>&1" > /var/spool/cron/crontabs/root

# Make sure the file exists before we start tail
touch /var/log/cron.log

# start the cron deamon
crond

echo "Container started."

exec "$@"
