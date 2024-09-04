<h3>Installation script for centralized PostgreSQL server of AdoPisoft including pgadmin.</h3> <br>
Tested using Ubuntu 22.04<br>
Copy and paste the 3 commands in the terminal<br><br>

<b>psqlf2ban.sh</b><br>
<br>
Added fail2ban option. There is a configuration where you can modify your database name, database user name and port inside the bash script. <b>Don't forget to edit the configuration file.</b><br>
wget https://raw.githubusercontent.com/kcaBmask/PostgreSQL/main/psqlf2ban.sh<br>
sudo chmod a+x psqlf2ban.sh <br>
bash psqlf2ban.sh<br>

<b>dbbackup.sh</b><br>
Database back up crontab. You can use the AdoPIsoft schedule (cron) to automate the script. <br>
Be sure to edit the configuration and make the script executable.
