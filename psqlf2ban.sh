#!/bin/bash

##########################################################################################
##                                   CONFIGURATIONS                                     ##
##########################################################################################


dbname=db_adopisoft  #set your database name
dbuser=dbu_adopisoft #set your database user 
port=5432            #set your PostgreSQL port


##########################################################################################

# ANSI color codes
GREEN='\033[1;32m' # Light Green
NC='\033[0m'       # No Color
RED='\033[1;31m'   # Light Red

# Print green header
echo -e "${GREEN}#########################################################################${NC}\n"

# Bash ASCII logo with green text and no background color
echo -e "${GREEN}         AdoPiSoft PostgreSQL Installation Script with fail2ban
           

               _            ______                     _    
              | |           | ___ \\                   | |   
              | | _____ __ _| |_/ /_ __ ___   __ _ ___| | __
              | |/ / __/ _\` | ___ \\ '_ \` _ \\ / _\` / __| |/ /
              |   < (_| (_| | |_/ / | | | | | (_| \\__ \\   < 
              |_|\\_\\___\\__,_\\____/|_| |_| |_|\\__,_|___/_|\\_\\

${NC}"


# Print green header
echo -e "${GREEN}#########################################################################${NC}\n"


# Define the packages to check
packages=("wget" "ca-certificates" "curl" "gnupg" "gnupg2" "gnupg1")

# Update package list
echo -e "${GREEN}\nUpdating package list...${NC}"
sudo apt update > /dev/null 2>&1

# Check and install missing packages
for package in "${packages[@]}"; do
  if dpkg -l | grep -q "^ii  $package "; then
    echo "$package is already installed."
  else
    echo "$package is not installed. Installing..."
    sudo apt install -y "$package" > /dev/null 2>&1
  fi
done

if [ $? -ne 0 ]; then
  echo -e "${RED}\nFailed to install required packages.${NC}"
  exit 1
fi

echo -e "${GREEN}\nAdding PostgreSQL official repository key...${NC}"
wget -qO - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor -o /usr/share/keyrings/pgdg-archive-keyring.gpg

if [ $? -ne 0 ]; then
  echo -e "${RED}\nFailed to add PostgreSQL official repository key.${NC}"
  exit 1
fi

echo -e "${GREEN}\nAdding PostgreSQL official repository to sources...${NC}"
echo "deb [signed-by=/usr/share/keyrings/pgdg-archive-keyring.gpg] http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list > /dev/null

if [ $? -ne 0 ]; then
  echo -e "${RED}\nFailed to add PostgreSQL official repository to sources.${NC}"
  exit 1
fi

# Install Postgres
echo -e "${GREEN}\nUpdating package list...${NC}"
sudo apt update > /dev/null 2>&1

echo -e "${GREEN}\nInstalling PostgreSQL 12 and PostgreSQL contrib...${NC}"
sudo apt install -y postgresql-12 postgresql-contrib > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo -e "${RED}\nFailed to install PostgreSQL.${NC}"
  exit 1
fi

# Editing postgres configuration file
echo -e "${GREEN}\nEditing PostgreSQL configuration file...${NC}"
sudo sed -i 's/#listen_addresses = .*/listen_addresses = '\''*'\''/' /etc/postgresql/12/main/postgresql.conf

# Set custom port (e.g., 5433)

sudo sed -i "s/^port = .*/port = ${port}/" /etc/postgresql/12/main/postgresql.conf

# Adding log_connections and log_line_prefix directives
sudo bash -c 'cat >> /etc/postgresql/12/main/postgresql.conf' <<EOL

# Custom log settings
log_connections = on
log_line_prefix = '%m {%h} [%p] %q%u@%d '
EOL

# Editing access policy
echo -e "${GREEN}\nEditing PostgreSQL access policy...${NC}"
echo "host all all 0.0.0.0/0 md5" | sudo tee -a /etc/postgresql/12/main/pg_hba.conf > /dev/null

# Restart postgres
echo -e "${GREEN}\nRestarting PostgreSQL service...${NC}"
sudo systemctl restart postgresql

if [ $? -ne 0 ]; then
  echo -e "${RED}\nFailed to restart PostgreSQL service.${NC}"
  exit 1
fi

# Add sudo user adopisoft
echo -e "${GREEN}\nAdding sudo user 'adopisoft'...${NC}"
sudo adduser --disabled-password --gecos "" adopisoft

# Switch over to Postgres account and create user/database
echo -e "${GREEN}\nCreating PostgreSQL user 'dbu_adopisoft' and database...${NC}"
cd /home
# Check if the PostgreSQL user exists
if sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='${dbname}'" | grep -q 1; then
  echo "User '${dbuser}' already exists. Skipping user creation."
else
  echo "User '${dbuser}' does not exist. Creating user..."
  sudo -u postgres createuser -p ${port} -P -s -e ${dbuser}
fi

# Check if the PostgreSQL database exists
if sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='${dbname}'" | grep -q 1; then
  echo "Database '${dbname}' already exists. Skipping database creation."
else
  echo "Database '${dbname}' does not exist. Creating database..."
  sudo -u postgres createdb -p ${port} -O ${dbuser} ${dbname}
fi

if [ $? -ne 0 ]; then
  echo -e "${RED}\nFailed to create PostgreSQL user or database.${NC}"
  exit 1
fi

# Setting up pgAdmin4
echo -e "${GREEN}\nSetting up pgAdmin4...${NC}"

# Setup the repository
echo -e "${GREEN}\nAdding pgAdmin4 repository key...${NC}"
curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg

if [ $? -ne 0 ]; then
  echo -e "${RED}\nFailed to add pgAdmin4 repository key.${NC}"
  exit 1
fi

echo -e "${GREEN}\nConfiguring pgAdmin4 repository...${NC}"
echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" | sudo tee /etc/apt/sources.list.d/pgadmin4.list > /dev/null
sudo apt update > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo -e "${RED}\nFailed to configure pgAdmin4 repository.${NC}"
  exit 1
fi

# Install pgAdmin
echo -e "${GREEN}\nInstalling pgAdmin4...${NC}"
sudo apt install -y pgadmin4 > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo -e "${RED}\nFailed to install pgAdmin4.${NC}"
  exit 1
fi

# Configure the webserver
echo -e "${GREEN}\nConfiguring pgAdmin4...${NC}"
sudo /usr/pgadmin4/bin/setup-web.sh

if [ $? -ne 0 ]; then
  echo -e "${RED}\nFailed to configure pgAdmin4.${NC}"
  exit 1
fi

# Install fail2ban
echo -e "${GREEN}\nInstalling fail2ban...${NC}"
sudo apt install -y fail2ban > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo -e "${RED}\nFailed to install fail2ban.${NC}"
  exit 1
fi

# Create a custom fail2ban jail for PostgreSQL and SSH
echo -e "${GREEN}\nConfiguring fail2ban for PostgreSQL and SSH...${NC}"
sudo bash -c 'cat > /etc/fail2ban/jail.local' <<EOL
[DEFAULT]
bantime = 1h
findtime = 10m
maxretry = 3

[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log
backend = systemd

[postgresql]
enabled = true
port = ${port}
filter = postgresql
logpath = /var/log/postgresql/postgresql-12-main.log
maxretry = 3
EOL

# Create the filter for PostgreSQL
sudo bash -c 'cat > /etc/fail2ban/filter.d/postgresql.conf' <<EOL
[Definition]
failregex = \{<HOST>\} .+? FATAL:  password authentication failed for user .+$
EOL

# Restart fail2ban service
echo -e "${GREEN}\nRestarting fail2ban service...${NC}"
sudo systemctl restart fail2ban

if [ $? -ne 0 ]; then
  echo -e "${RED}\nFailed to restart fail2ban service.${NC}"
  exit 1
fi

# Script completion message
echo -e "${GREEN}\nScript execution completed successfully.${NC}\n"
