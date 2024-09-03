<h1>Installation script for centralized PostgreSQL server of AdoPisoft including pgadmin.<h1></h1> <br>
Tested using Ubuntu 22.04<br>
Copy and paste the command in the terminal<br><br>

wget https://raw.githubusercontent.com/kcaBmask/postgres/main/postgresql.sh &&
sudo chmod a+x postgresql.sh &&
bash postgresql.sh<br><br>
Line 69, just replace whatever password you want for your database. Default: adopisoft<br>

<b>psqlf2ban.sh</b><br>
<br>
Added fail2ban option. There is a configuration where you can modify your database name, database user name and port inside the bash script<br>
wget https://raw.githubusercontent.com/kcaBmask/PostgreSQL/main/psqlf2ban.sh && sudo chmod a+x psqlf2ban.sh && bash psqlf2ban.sh<br>

<b>dbbackup.sh</b><br>
Autoback up database using crontab.
