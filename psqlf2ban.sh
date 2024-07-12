# PostgreSQL
#!/bin/bash

# ANSI color codes
GREEN='\033[1;32m' # Light Green
NC='\033[0m'       # No Color
RED='\033[1;31m'   # Light Red

# Print green header
echo -e "${GREEN}#########################################################################${NC}\n"

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
echo -e "${GREEN}#########################################################################${NC}\n"

# Script header with green text and no background color
echo -e "${GREEN}\n=== PostgreSQL Installation and Configuration Script ===${NC}\n"

# Add Official Repository
echo -e "${GREEN}\nInstalling required packages...${NC}"
sudo apt update > /dev/null 2>&1 && sudo apt install -y wget ca-certificates > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo -e "${RED}\nFailed to install required packages.${NC}"
  exit 1
fi

echo -e "${GREEN}\nAdding PostgreSQL official repository key...${NC}"
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

if [ $? -ne 0 ]; then
  echo -e "${RED}\nFailed to add PostgreSQL official repository key.${NC}"
  exit 1
fi

echo -e "${GREEN}\nAdding PostgreSQL official repository to sources...${NC}"
echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" | sudo tee -a /etc/apt/sources.list.d/pgdg.list > /dev/null

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
PORT=49152
sudo sed -i "s/^port = .*/port = ${PORT}/" /etc/postgresql/12/main/postgresql.conf

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
sudo adduser adopisoft

# Switch over to Postgres account and create user/database
echo -e "${GREEN}\nCreating PostgreSQL user 'adopisoft' and database...${NC}"
sudo -u postgres createuser -p ${PORT} --interactive
sudo -u postgres createdb -p ${PORT} adopisoft

# Securely set password for user adopisoft
echo -e "${GREEN}\nSetting password for PostgreSQL user 'adopisoft'...${NC}"
sudo -u postgres psql -p ${PORT} -c "ALTER USER adopisoft WITH PASSWORD  'adopisoft';"

# Setting up pgAdmin4
echo -e "${GREEN}\nSetting up pgAdmin4...${NC}"

# Setup the repository
echo -e "${GREEN}\nAdding pgAdmin4 repository key...${NC}"
curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg

if [ $? -ne 0 ]; then
  echo -e "${RED}\nFailed to add pgAdmin4 repository key.${NC}"
  exit 1
fi

echo -e "${GREEN}Configuring pgAdmin4 repository...${NC}"
echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" | sudo tee -a /etc/apt/sources.list.d/pgadmin4.list > /dev/null
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
port = ${PORT}
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
