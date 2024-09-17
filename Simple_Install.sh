#!/bin/bash

# Solicitar contraseñas al usuario
echo "Introduce la contraseña para el usuario de MySQL:"
read -s mysql_password
echo "Introduce la contraseña para el usuario de Nextcloud (ej. talde1):"
read -s nextcloud_user_password

# Actualizar sistema
echo "Actualizando el sistema..."
sudo apt update && sudo apt upgrade -y

# Instalar dependencias necesarias
echo "Instalando dependencias necesarias..."
sudo apt install -y apache2 mariadb-server libapache2-mod-php php-gd php-mysql \
php-curl php-mbstring php-intl php-gmp php-bcmath php-xml php-imagick php-zip
sudo apt install -y unzip

# Agregar repositorio para PHP 8.1
echo "Agregando repositorio para PHP 8.1..."
sudo add-apt-repository ppa:ondrej/php -y

# Instalar PHP 8.1 y extensiones necesarias
echo "Instalando PHP 8.1 y sus extensiones..."
sudo apt install -y php8.1 libapache2-mod-php8.1 php8.1-mysql php8.1-gd php8.1-curl \
php8.1-mbstring php8.1-intl php8.1-imagick php8.1-xml php8.1-zip php8.1-bcmath php8.1-gmp

# Descargar y descomprimir Nextcloud
echo "Descargando e instalando Nextcloud..."
wget https://download.nextcloud.com/server/releases/latest.zip
sudo unzip latest.zip -d /var/www/
sudo mv /var/www/nextcloud /var/www/html/nextcloud

# Asignar permisos a la carpeta de Nextcloud
echo "Asignando permisos a la carpeta de Nextcloud..."
sudo chown -R www-data:www-data /var/www/html/nextcloud
sudo chmod -R 755 /var/www/html/nextcloud

# Configurar Apache para Nextcloud
echo "Configurando Apache para Nextcloud..."
sudo bash -c 'cat > /etc/apache2/sites-available/nextcloud.conf' <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/nextcloud

    <Directory /var/www/html/nextcloud>
        AllowOverride All
        Require all granted
    </Directory>

    <IfModule mod_headers.c>
        Header always set X-Content-Type-Options "nosniff"
        Header always set X-XSS-Protection "1; mode=block"
        Header always set X-Frame-Options "DENY"
        Header always set Referrer-Policy "no-referrer"
    </IfModule>

    ErrorLog \${APACHE_LOG_DIR}/nextcloud_error.log
    CustomLog \${APACHE_LOG_DIR}/nextcloud_access.log combined
</VirtualHost>
EOF

# Habilitar el sitio de Nextcloud en Apache
sudo a2ensite nextcloud.conf
sudo systemctl reload apache2

# Permitir tráfico HTTP a través del firewall
echo "Configurando el firewall..."
sudo ufw allow 80

# Configurar MySQL
echo "Configurando MySQL..."
sudo systemctl start mysql
sudo systemctl enable mysql

# Crear base de datos y usuario en MySQL
echo "Creando base de datos y usuario para Nextcloud en MySQL..."
sudo mysql -u root -p"${mysql_password}" -e "
CREATE USER 'nextclouduser'@'localhost' IDENTIFIED BY '${nextcloud_user_password}';
CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextclouduser'@'localhost';
FLUSH PRIVILEGES;"

# Iniciar servicios de Apache y MySQL
echo "Iniciando servicios Apache y MySQL..."
sudo systemctl enable apache2
sudo systemctl start apache2
sudo systemctl start mysql

echo "Instalación de Nextcloud completada. Accede a tu servidor para continuar con la configuración."