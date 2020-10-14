cat <<EOF >> /etc/apt/sources.list
deb http://fr.archive.ubuntu.com/ubuntu/ xenial main restricted
deb http://fr.archive.ubuntu.com/ubuntu/ xenial-updates main restricted
EOF

apt update
apt install -y php libapache2-mod-php php-mysql php-gd apache2 git
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server

#sudo mysql -h 127.0.0.1 -P3306 -uroot -e"alter user 'root'@'localhost' identified by 'root'"
mysql -u root -e "SET PASSWORD FOR root@localhost = PASSWORD('root')";
rm /etc/apache2/site-available/000-default.conf

cat <<EOF > /etc/apache2/sites-available/pownstars.conf
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

a2ensite pownstars

wget https://raw.githubusercontent.com/pveutin/pownstars/main/pownstars.sql
mysqladmin -uroot -proot create pownstars
mysql -u root -proot pownstars < pownstars.sql
cat <<EOF > users.sql
CREATE USER 'pownstars'@'localhost' IDENTIFIED BY 'pownstars!';
GRANT ALL PRIVILEGES ON *.* TO 'pownstars'@'localhost';
flush privileges;
EOF

mysql -uroot -proot < users.sql

cd /var/www
rm -rf ./*
git init
git remote add origin https://github.com/pveutin/pownstars.git
git pull origin main
chown www-data:www-data /var/www/html/uploads/

service apache2 restart