Installation script for centralized PostgreSQL server of AdoPisoft including pgadmin. <br>
Tested using Ubuntu 22.04<br>
Copy and paste this 3 commands in the terminal<br><br>

wget https://raw.githubusercontent.com/kcaBmask/postgres/main/postgresql.sh<br>
sudo chmod a+x postgresql.sh<br>
bash postgresql.sh<br><br>
Line 69, just replace whatever password you want for your database. Default: adopisoft<br>

psqlf2ban.sh<br>
Added fail2ban option. There is a configuration where you can modify your database name, database user name and port inside the bash script<br>
<br>
