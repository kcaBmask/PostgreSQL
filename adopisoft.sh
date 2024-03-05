#!/bin/bash

# ANSI color codes
GREEN='\033[1;32m' # Light Green.
NC='\033[0m'       # No Color
RED='\033[1;31m'   # Light Red.

# Print green header
echo -e "${GREEN}#########################################################################${NC}\\n"

# Bash ASCII logo with green text and no background color
echo -e "${GREEN}
 __                ___.                          __    
|  | __ ____ _____ \\_ |__   _____ _____    _____|  | __
|  |/ // ___\\__  \\ | __ \\ /     \\__  \\  /  ___/  |/ /
|    <\\  \\___ / __ \\| \\_\\ \\  Y Y  \\/ __ \\_\\___ \\|    < 
|__|_ \\___  >____  /___  /__|_|  (____  /____  >__|_ \\
     \\/    \\/     \\/    \\/      \\/     \\/     \\/     \\/
${NC}"

# Print green header
echo -e "${GREEN}#########################################################################${NC}\\n"

# Script header with green text and no background color
echo -e "${GREEN}\n=== PostgreSQL Installation and Configuration Script ===${NC}\n"

# Add Official Repository
echo -e "${GREEN}\nInstalling required packages...${NC}"
sudo apt update > /dev/null 2>&1
sudo apt install -y wget ca-certificates > /dev/null 2>&1

echo -e "${GREEN}\nAdding PostgreSQL official repository key...${NC}"
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

echo -e "${GREEN}\nAdding PostgreSQL official repository to sources...${NC}"
echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" | sudo tee -a /etc/apt/sources.list.d/pgdg.list


# Install Postgres
echo -e "${GREEN}\nUpdating package list...${NC}"
sudo apt update > /dev/null 2>&1

echo -e "${GREEN}\nInstalling PostgreSQL 12 and PostgreSQL contrib...${NC}"
sudo apt install -y postgresql-12 postgresql-contrib > /dev/null 2>&1

# Editing postgres configuration file
echo -e "${GREEN}\nEditing PostgreSQL configuration file...${NC}"
sudo sed -i 's/#listen_addresses = .*/listen_addresses = '\''*'\''/' /etc/postgresql/12/main/postgresql.conf

# Editing access policy
echo -e "${GREEN}\nEditing PostgreSQL access policy...${NC}"
echo "host all all 0.0.0.0/0 md5" | sudo tee -a /etc/postgresql/12/main/pg_hba.conf

# Restart postgres
echo -e "${GREEN}\nRestarting PostgreSQL service...${NC}"
sudo systemctl restart postgresql

# Add sudo user adopisoft
echo -e "${GREEN}\nAdding sudo user 'adopisoft'...${NC}"
sudo adduser adopisoft

# Switch over to Postgres account and create user/database
echo -e "${GREEN}\nCreating PostgreSQL user 'adopisoft' and database...${NC}"
sudo -u postgres createuser --interactive
sudo -u postgres createdb adopisoft

# Set password for user adopisoft
echo -e "${GREEN}\nSetting password for PostgreSQL user 'adopisoft'...${NC}"
sudo -u postgres psql -c "ALTER USER adopisoft WITH PASSWORD 'adopisoft';"

# Setting up pgadmin4
echo -e "${GREEN}\nSetting up pgAdmin4...${NC}"

# Setup the repository
echo -e "${GREEN}\nAdding pgAdmin4 repository key...${NC}"
curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg
echo -e "${GREEN}Configuring pgAdmin4 repository...${NC}"
echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" | sudo tee -a /etc/apt/sources.list.d/pgadmin4.list
sudo apt update > /dev/null 2>&1

# Install pgAdmin
echo -e "${GREEN}\nInstalling pgAdmin4...${NC}"
sudo apt install -y pgadmin4 > /dev/null 2>&1

# Configure the webserver
echo -e "${GREEN}\nConfiguring pgAdmin4...${NC}"
sudo /usr/pgadmin4/bin/setup-web.sh

# Script completion message
echo -e "${GREEN}\nScript execution completed successfully.${NC}\n"
