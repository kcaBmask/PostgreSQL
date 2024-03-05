#!/bin/bash

# Add Official Repository
echo "Installing required packages..."
sudo apt install -y wget ca-certificates

echo "Adding PostgreSQL official repository key..."
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

echo "Adding PostgreSQL official repository to sources..."
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'

# Install Postgres
echo "Updating package list..."
sudo apt update

echo "Installing PostgreSQL 12 and PostgreSQL contrib..."
sudo apt install -y postgresql-12 postgresql-contrib

echo "Checking PostgreSQL service status..."
service postgresql status

# Editing postgres configuration file
echo "Editing PostgreSQL configuration file..."
# Uncomment then edit like this listen_addresses = '*'
nano /etc/postgresql/12/main/postgresql.conf

# Editing access policy
echo "Editing PostgreSQL access policy..."
# Add Inyo Ito sa huli host all all 0.0.0.0/0 md5
nano /etc/postgresql/12/main/pg_hba.conf

# Restart postgres
echo "Restarting PostgreSQL service..."
systemctl restart postgresql

# Check listening port
echo "Checking PostgreSQL listening port..."
ss -nlt | grep 5432

# Add sudo user adopisoft
echo "Adding sudo user 'adopisoft'..."
sudo adduser adopisoft

# Switch over to Postgres account
echo "Switching to the 'postgres' account..."
sudo -i -u postgres
# Create user adopisoft
echo "Creating PostgreSQL user 'adopisoft'..."
createuser --interactive
# Create database named adopisoft
echo "Creating PostgreSQL database 'adopisoft'..."
createdb adopisoft
psql

# Testing connection
echo "Testing PostgreSQL connection..."
\conninfo

# Exit Postgres prompt
echo "Exiting PostgreSQL prompt..."
\q

# Login to Postgres with username adopisoft
echo "Logging in to PostgreSQL with username 'adopisoft'..."
sudo -u adopisoft psql

# Set password for user adopisoft
echo "Setting password for PostgreSQL user 'adopisoft'..."
\password adopisoft

# Check connection information
echo "Checking PostgreSQL connection information..."
\conninfo

# List all Postgres users
echo "Listing all PostgreSQL users..."
\du

# Quit Postgres prompt
echo "Quitting PostgreSQL prompt..."
\q

# Setting up pgadmin4
echo "Setting up pgAdmin4..."

# Setup the repository
echo "Adding pgAdmin4 repository key..."
curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg
echo "Configuring pgAdmin4 repository..."
sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'

# Install pgAdmin
echo "Installing pgAdmin4..."
# Install for both desktop and web modes:
sudo apt install -y pgadmin4

# Install for desktop mode only:
# sudo apt install pgadmin4-desktop

# Install for web mode only:
# sudo apt install pgadmin4-web

# Configure the webserver, if you installed pgadmin4-web:
# sudo /usr/pgadmin4/bin/setup-web.sh

# Enable UFW and open port 5432
echo "Enabling UFW and opening port 5432..."
sudo ufw enable
sudo ufw allow 5432

echo "Script execution completed successfully."
