# restic-backups-docker
A docker container to automate [restic backups](https://restic.github.io/)

This container runs restic backups in regular intervals. 

## Logfiles
Logfiles are inside the container. If needed you can create volumes for them.

```
docker logs
```
Shows `/var/log/cron.log`

Additionally you can see the the full log, including restic output, of the last execution in `/var/log/backup-last.log`. When the backup fails the log is copied to `/var/log/restic-error-last.log`.

## Environment variables

* `RESTIC_REPOSITORY` - the location of the restic repository. Currently only sftp is supported.
* `RESTIC_PASSWORD` - the password for the restic repository.
* `RESTIC_SSH_KEY` - private key for passwordless ssh authentication.
* `RESTIC_TAG` - Optional. To tag the images created by the container.
* `RESTIC_FORGET_ARGS` - Optional. Only if specified `restic forget` is run with the given arguments after each backup. Example value: `-e "RESTIC_FORGET_ARGS=--prune --keep-last 10 --keep-hourly 24 --keep-daily 7 --keep-weekly 52 --keep-monthly 120 --keep-yearly 100"`
* `RESTIC_JOB_ARGS` - Optional. Allows to specify extra arguments to the back up job such as limiting bandwith with `--limit-upload` or excluding file masks with `--exclude`.
* `BACKUP_CRON` - A cron expression to run the backup. Default: `0 */6 * * *` aka every 6 hours.
* `TZ` - Optional. Set a custom timezone.
* `HEALTHCHECK_URL` - Optional. Set a URL to call after successful backups. For a service like https://healthchecks.io/
* `API_TOTAL_SIZE` - Optional. Set a URL to post repo total size after successful backups. For REST APIs.

## Volumes

* `/data` - This is the data that gets backed up. Just [mount](https://docs.docker.com/engine/reference/run/#volume-shared-filesystems) it to wherever you want.

## Set the hostname

Since restic saves the hostname with each snapshot and the hostname of a docker container is derived from it's id you might want to customize this by setting the hostname of the container to another value.

## Backup via SFTP

Since restic needs a **passwordless login** to the SFTP server make sure you can do `sftp user@host` from inside the container. If you can do so from your host system, the easiest way is to just mount your `.ssh` folder conaining the authorized cert into the container by specifying `-v ~/.ssh:/root/.ssh` as argument for `docker run`.

Now you can simply specify the restic repository to be an [SFTP repository](https://restic.readthedocs.io/en/stable/Manual/#create-an-sftp-repository).

```
-e "RESTIC_REPOSITORY=sftp:user@host:/tmp/backup"
```
