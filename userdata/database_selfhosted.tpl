#!/bin/bash
yum -y update

tee /etc/yum.repos.d/pgdg.repo<<EOF
[pgdg12]
name=PostgreSQL 12 for RHEL/CentOS 7 - x86_64
baseurl=https://download.postgresql.org/pub/repos/yum/12/redhat/rhel-7-x86_64
enabled=1
gpgcheck=0
EOF
yum makecache
yum install postgresql12 postgresql12-server -y
/usr/pgsql-12/bin/postgresql-12-setup initdb

systemctl enable --now postgresql-12

su - postgres 
cd /var/lib/psql

chown -R postgres:postgres /var/lib/pgsql
su -p -c "psql -c \"alter user postgres with password '3anbzsTQDD2ZB8CnSGtKz7'\"" postgres
su -c "echo \"listen_addresses = '*'\" >> /var/lib/pgsql/12/data/postgresql.conf" postgres
su -c "echo \"host    samerole        all             0.0.0.0/0               md5\" >> /var/lib/pgsql/12/data/pg_hba.conf" postgres
# sudo -u postgres psql -c "alter user postgres with password 'StrongPassword'"
# sudo -u postgres echo "listen_addresses = '*'" >> /var/lib/pgsql/12/data/postgresql.config
# echo "host    samerole        all             0.0.0.0/0               md5" >> /var/lib/pgsql/12/data/pg_hba.conf
sudo service postgresql-12 restart