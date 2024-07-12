Installation script for centralized PostgreSQL server of AdoPisoft including pgadmin. <br>
Tested using Ubuntu 22.04<br>
Copy and paste this 3 commands in the terminal<br><br>

wget https://raw.githubusercontent.com/kcaBmask/postgres/main/postgresql.sh<br>
sudo chmod a+x postgresql.sh<br>
bash postgresql.sh<br><br>
Line 69, just replace whatever password you want for your database. Default: adopisoft<br>

psqlf2ban.sh<br>
Added fail2ban. Adding option to modify postgresql default port: 5432.You can modify on line 70.<br>
Line 105, just replace whatever password you want for your database. Default: adopisoft<br>
