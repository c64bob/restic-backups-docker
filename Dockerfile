FROM restic/restic:latest

# make it possible to set timezone
RUN apk add --update tzdata

# setup cron
RUN mkdir -p  /var/spool/cron/crontabs /var/log
      
# define environment
ENV RESTIC_REPOSITORY = ""
ENV RESTIC_PASSWORD = ""
ENV RESTIC_TAG = ""
ENV BACKUP_CRON = "0 */6 * * *"
ENV RESTIC_FORGET_ARGS = ""
ENV RESTIC_JOB_ARGS = ""
ENV TZ = ""

# copy scripts and execute
WORKDIR "/"
COPY backup.sh /bin/backup
COPY entry.sh /entry.sh
ENTRYPOINT ["/entry.sh"]
CMD ["tail","-fn0","/var/log/cron.log"]
