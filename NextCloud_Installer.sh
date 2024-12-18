#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Por favor ejecuta este script como root o utilizando sudo."
  exit
fi

set -e

read -p "Introduce el dominio o IP de tu servidor (ej. nextcloud.example.com o 192.168.1.10): " server_name
while [[ -z "$server_name" ]]; do
    echo "El dominio o IP no puede estar vacío."
    read -p "Introduce el dominio o IP de tu servidor (ej. nextcloud.example.com o 192.168.1.10): " server_name
done

read -p "Introduce el email del administrador del servidor: " server_admin
while [[ -z "$server_admin" ]]; do
    echo "El correo electrónico no puede estar vacío."
    read -p "Introduce el email del administrador del servidor: " server_admin
done

read -s -p "Introduce la contraseña para el usuario root de MySQL: " mysql_password
echo
read -s -p "Introduce la contraseña para el usuario de Nextcloud (ej. nextclouduser): " nextcloud_user_password
echo

echo "Actualizando el sistema..."
sudo apt update && sudo apt upgrade -y

echo "Instalando dependencias necesarias..."
sudo apt install -y apache2 mariadb-server libapache2-mod-php php-gd php-mysql \
php-curl php-mbstring php-intl php-gmp php-bcmath php-xml php-imagick php-zip \
software-properties-common unzip curl certbot python3-certbot-apache

echo "Agregando repositorio de PHP 8.1..."
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update

echo "Instalando PHP 8.1 y sus módulos..."
sudo apt install -y php8.1 libapache2-mod-php8.1 php8.1-mysql php8.1-gd php8.1-curl \
php8.1-mbstring php8.1-intl php8.1-imagick php8.1-xml php8.1-zip php8.1-bcmath php8.1-gmp

echo "Verificando que Apache y MySQL estén corriendo..."
sudo systemctl enable apache2
sudo systemctl start apache2
sudo systemctl enable mysql
sudo systemctl start mysql

echo "Descargando Nextcloud..."
cd /tmp
wget https://download.nextcloud.com/server/releases/latest.zip
sudo unzip latest.zip -d /var/www/
sudo mv /var/www/nextcloud /var/www/html/nextcloud

echo "Asignando permisos a Nextcloud..."
sudo chown -R www-data:www-data /var/www/html/nextcloud
sudo chmod -R 755 /var/www/html/nextcloud

echo "Habilitando módulos de Apache..."
sudo a2enmod rewrite headers env dir mime setenvif ssl

echo "Configurando Apache para Nextcloud..."
sudo bash -c "cat > /etc/apache2/sites-available/nextcloud.conf" <<EOF
<VirtualHost *:80>
    ServerAdmin $server_admin
    ServerName $server_name
    DocumentRoot /var/www/html/nextcloud

    <Directory /var/www/html/nextcloud>
        AllowOverride All
        Require all granted
    </Directory>

    <IfModule mod_headers.c>
        Header always set X-Content-Type-Options \"nosniff\"
        Header always set X-XSS-Protection \"1; mode=block\"
        Header always set X-Frame-Options \"DENY\"
        Header always set Referrer-Policy \"no-referrer\"
    </IfModule>

    ErrorLog \${APACHE_LOG_DIR}/nextcloud_error.log
    CustomLog \${APACHE_LOG_DIR}/nextcloud_access.log combined
</VirtualHost>
EOF

sudo a2ensite nextcloud.conf
sudo systemctl reload apache2

echo "Configurando firewall..."
sudo ufw allow 80
sudo ufw allow 443

echo "Configurando MySQL..."
sudo mysql -u root -p"$mysql_password" <<EOF
CREATE USER 'nextclouduser'@'localhost' IDENTIFIED BY '$nextcloud_user_password';
CREATE DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextclouduser'@'localhost';
FLUSH PRIVILEGES;
EOF

read -p "¿Quieres habilitar SSL con Let's Encrypt? (s/n): " enable_ssl
if [ "$enable_ssl" == "s" ]; then
    echo "Instalando y configurando SSL con Certbot..."
    sudo certbot --apache -d "$server_name" --non-interactive --agree-tos -m "$server_admin"
    sudo systemctl reload apache2
else
    echo "SSL no ha sido habilitado."
fi

echo "Instalación de Nextcloud completada. Visita http://$server_name para continuar con la configuración."
