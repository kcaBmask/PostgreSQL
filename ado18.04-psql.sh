#!/usr/bin/env bash


# Download PostgreSQL signing key

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
# Add PostgreSQL repository

sudo sh -c 'echo "deb https://apt-archive.postgresql.org/pub/repos/apt bionic-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
echo "Installing netstat"
sudo apt-get install net-tools

USER=adopisoft
echo "=== $BASH_SOURCE on $(hostname -f) at $(date)" >&2

echo "Updating package information"
sudo apt update -y

echo "Installing PostgreSQL and its contrib packages"
sudo apt install postgresql-12 postgresql-contrib -y

echo "Starting PostgreSQL service"
sudo /etc/init.d/postgresql start

echo "Creating PostgreSQL database 'adopisoft'"
sudo -u postgres createdb adopisoft

echo "Setting up PostgreSQL user and privileges"
sudo su - postgres -c \
"psql <<__END__
   SELECT 'create user' ;
   CREATE USER $USER ;
   ALTER USER $USER CREATEDB;

   SELECT 'grant him the privileges' ;
   GRANT ALL PRIVILEGES ON DATABASE adopisoft TO $USER ;
   ALTER USER $USER PASSWORD 'adopisoft';

   SELECT 'AND VERIFY' ;
   SELECT * FROM information_schema.role_table_grants
   WHERE grantee='$USER';

   SELECT 'INSTALL EXTENSIONS' ;
   CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";
   CREATE EXTENSION IF NOT EXISTS \"pgcrypto\";
   CREATE EXTENSION IF NOT EXISTS \"dblink\";
__END__
"

echo "Checking PostgreSQL service status"
sudo /etc/init.d/postgresql status

echo "Checking PostgreSQL ports"
sudo netstat -tulntp | grep -i postgres
