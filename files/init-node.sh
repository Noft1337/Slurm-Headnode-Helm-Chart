#!/bin/bash

set -e

base64 --decode /etc/munge-tmp/munge.key > /etc/munge/munge.key
base64 --decode /etc/jwt-tmp/jwt_hs256.key > /etc/jwt/jwt_hs256.key

if [ ! -z "$IS_SLURM_MASTER" ]; then
  # Create slurmcltd data directory
  if [ ! -d /var/spool/slurm/ctld ]; then
    mkdir -p /var/spool/slurm/ctld
    chown -R slurm: /var/spool/slurm
  fi

  # Init slurm acct database
  IS_DATABASE_EXIST='0'
  while [ "1" != "$IS_DATABASE_EXIST" ]; do
    echo "Waiting for database $MARIADB_DATABASE on $MARIADB_HOST..."
    IS_DATABASE_EXIST="`mysql -h {{ .Values.global.database.host }} -u slurm -p"password" -qfsBe "select count(*) as c from information_schema.schemata where schema_name='slurm_acct_db'" -H | sed -E 's/c|<[^>]+>//gi' 2>&1`"
    #IS_DATABASE_EXIST="`mysql -h {{ .Release.Name }}-mariadb-galera -u root -p"password-for-mariadb" -qfsBe "select count(*) as c from information_schema.schemata where schema_name='slurm_acct_db'" -H | sed -E 's/c|<[^>]+>//gi' 2>&1`"
    sleep 5
  done
fi

# Prepare munge dirs
chown -R munge: /etc/munge /var/lib/munge /var/run/munge
chmod 0700 /etc/munge
chmod 0600 /etc/munge/munge.key
chmod 0711 /var/lib/munge
chmod 0755 /var/run/munge
chmod 0600 /etc/jwt/jwt_hs256.key

# Prepare slurm and munge spool dirs
if [ ! -d /var/spool/slurm/d -o ! -d /var/spool/slurm/ctld ]; then
  mkdir -p /var/spool/slurm/d /var/spool/slurm/ctld
  chown -R slurm: /var/spool/slurm
fi
if [ ! -d /var/spool/munge ]; then
  mkdir /var/spool/munge
  chown -R munge: /var/spool/munge
fi

exec "$@"
