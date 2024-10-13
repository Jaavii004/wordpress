#!/bin/bash

# Actualizar los repositorios
sudo apt update -y
sudo apt upgrade -y

# Instalar Apache, MySQL y PHP
sudo apt install -y apache2 mysql-server php php-mysql libapache2-mod-php php-xml php-curl php-zip

# Habilitar el módulo de reescritura de Apache
sudo a2enmod rewrite
sudo systemctl restart apache2

# Crear las carpetas para WordPress
sudo mkdir -p /var/www/alvaro
sudo mkdir -p /var/www/javier

# Asignar permisos
sudo chown -R www-data:www-data /var/www/alvaro
sudo chown -R www-data:www-data /var/www/javier
sudo chmod -R 755 /var/www/alvaro
sudo chmod -R 755 /var/www/javier

# Descargar WordPress
cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xvzf latest.tar.gz

# Copiar WordPress a las carpetas correspondientes
sudo cp -R wordpress/* /var/www/alvaro/
sudo cp -R wordpress/* /var/www/javier/

# Crear bases de datos para WordPress
sudo mysql -e "CREATE DATABASE alvaro_db;"
sudo mysql -e "CREATE DATABASE javier_db;"
sudo mysql -e "CREATE USER 'alvaro_user'@'localhost' IDENTIFIED BY 'password_alvaro';"
sudo mysql -e "CREATE USER 'javier_user'@'localhost' IDENTIFIED BY 'password_javier';"
sudo mysql -e "GRANT ALL PRIVILEGES ON alvaro_db.* TO 'alvaro_user'@'localhost';"
sudo mysql -e "GRANT ALL PRIVILEGES ON javier_db.* TO 'javier_user'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Configurar Apache para los dos sitios
cat <<EOL | sudo tee /etc/apache2/sites-available/alvaro.conf
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/alvaro
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
    <Directory /var/www/alvaro>
        AllowOverride All
    </Directory>
</VirtualHost>
EOL

cat <<EOL | sudo tee /etc/apache2/sites-available/javier.conf
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/javier
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
    <Directory /var/www/javier>
        AllowOverride All
    </Directory>
</VirtualHost>
EOL

# Habilitar los sitios y reiniciar Apache
sudo a2ensite alvaro.conf
sudo a2ensite javier.conf
sudo systemctl restart apache2

# Configurar wp-config.php para alvaro
cp /var/www/alvaro/wp-config-sample.php /var/www/alvaro/wp-config.php
sudo sed -i "s/database_name_here/alvaro_db/" /var/www/alvaro/wp-config.php
sudo sed -i "s/username_here/alvaro_user/" /var/www/alvaro/wp-config.php
sudo sed -i "s/password_here/password_alvaro/" /var/www/alvaro/wp-config.php

# Configurar wp-config.php para javier
cp /var/www/javier/wp-config-sample.php /var/www/javier/wp-config.php
sudo sed -i "s/database_name_here/javier_db/" /var/www/javier/wp-config.php
sudo sed -i "s/username_here/javier_user/" /var/www/javier/wp-config.php
sudo sed -i "s/password_here/password_javier/" /var/www/javier/wp-config.php

# Limpiar
rm -rf /tmp/latest.tar.gz /tmp/wordpress

echo "Instalación completada. Puedes acceder a tus sitios en /alvaro y /javier."
