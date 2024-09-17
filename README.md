
```markdown
# Nextcloud_automatization

This repository contains a Bash script that automates the installation and configuration of [Nextcloud](https://nextcloud.com/), an open-source file sync and share solution. The script will install the required dependencies, configure Apache and MySQL, and set up Nextcloud on your server with minimal manual intervention.

## Author

**linoreki**

## Features

- Updates the system (`apt update` and `apt upgrade`)
- Installs all necessary dependencies for Nextcloud, including PHP 8.1, Apache, and MySQL
- Sets up Apache virtual host for Nextcloud
- Downloads and installs the latest version of Nextcloud
- Configures MySQL with user-provided credentials
- Starts and enables Apache and MySQL services automatically
- Sets appropriate permissions for Nextcloud files and directories
- Enables firewall rules for HTTP traffic (port 80)

## Prerequisites

Before running the script, make sure your server meets the following requirements:

- Ubuntu/Debian-based Linux distribution
- Sudo privileges on the server
- Internet connection to download packages and Nextcloud

## Usage

1. **Clone the repository:**

   ```bash
   git clone https://github.com/linoreki/Nextcloud_automatization.git
   cd Nextcloud_automatization
   ```

2. **Make the script executable:**

   ```bash
   chmod +x nextcloud_install.sh
   ```

3. **Run the script:**

   ```bash
   ./nextcloud_install.sh
   ```

4. **Follow the prompts:**

   The script will ask you to provide:
   - The MySQL root password
   - The MySQL password for the Nextcloud database user

5. **Access Nextcloud:**

   After the script finishes, open your browser and go to:

   ```
   http://your-server-ip
   ```

   You will be prompted to complete the installation through Nextcloud's web interface.

## Script Breakdown

The `nextcloud_install.sh` script performs the following steps:

1. **System Update:**
   Updates and upgrades your system packages using `sudo apt update && sudo apt upgrade`.

2. **Install Dependencies:**
   Installs Apache, MariaDB (MySQL), PHP 8.1, and all necessary PHP extensions required by Nextcloud.

3. **Download and Install Nextcloud:**
   - Downloads the latest version of Nextcloud.
   - Unzips and moves the files to `/var/www/html/nextcloud`.
   - Sets correct file permissions for Nextcloud to work seamlessly with Apache.

4. **Apache Configuration:**
   Configures an Apache virtual host for Nextcloud.

5. **MySQL Setup:**
   Prompts the user to provide a password and creates a MySQL user and database for Nextcloud.

6. **Start Services:**
   Enables and starts Apache and MySQL services.

7. **Firewall Configuration:**
   Opens port 80 for HTTP traffic.

## Example

After running the script, you should see output similar to the following:

```bash
Introduce la contraseña para el usuario de MySQL:
Introduce la contraseña para el usuario de Nextcloud (ej. talde1):
Actualizando el sistema...
Instalando dependencias necesarias...
Descargando e instalando Nextcloud...
Configurando Apache para Nextcloud...
Creando base de datos y usuario para Nextcloud en MySQL...
Iniciando servicios Apache y MySQL...
Instalación de Nextcloud completada. Accede a tu servidor para continuar con la configuración.
```

## Contributing

If you encounter any issues or have suggestions for improvements, feel free to open an [issue](https://github.com/linoreki/Nextcloud_automatization/issues) or submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
```

