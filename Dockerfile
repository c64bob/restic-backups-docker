FROM restic/restic:latest

# setup cron
RUN mkdir -p  /var/spool/cron/crontabs /var/log
      
# define environment
ENV RESTIC_REPOSITORY
ENV RESTIC_PASSWORD
ENV RESTIC_TAG
ENV BACKUP_CRON = "0 */6 * * *"
ENV RESTIC_FORGET_ARGS
ENV RESTIC_JOB_ARGS
        
# everything in /data will be backed up
VOLUME /data
COPY backup.sh /bin/backup
COPY entry.sh /entry.sh
        
WORKDIR "/"
ENTRYPOINT ["/entry.sh"]
CMD ["tail","-fn0","/var/log/cron.log"]
