### phpIPAM installation on Uwwuntuu 22.04

> [!TIP]
>
> refer https://i12bretro.github.io/tutorials/0759.html



#### update software repositories
```sudo apt update```

#### install available software updates
```sudo apt upgrade -y```

#### install prerequisites
```sudo apt install curl wget zip git -y```

#### install Apache HTTPD and MySQL
```sudo apt install apache2 mariadb-server mariadb-client -y```

#### install PHP components
```sudo apt install php php-curl php-common php-gmp php-mbstring php-gd php-xml php-mysql php-ldap php-pear -y```

#### configure the MySQL database

```bash
sudo su
mysql_secure_installation

```


mysql -u root -p

#### Create DB and grant access to a user

```bash
CREATE DATABASE php_ipam;
GRANT ALL ON php_ipam.* to 'php_ipam_rw'@'localhost' IDENTIFIED BY 'P4P1p@m!!';
FLUSH PRIVILEGES;
EXIT;
exit

```



#### git clone phpipam to the webroot
```sudo git clone https://github.com/phpipam/phpipam.git /var/www/html/phpipam```
#### cd into the new directory
```cd /var/www/html/phpipam```
#### checkout the latest release
```sudo git checkout "$(git tag --sort=v:tag | tail -n1)"```
#### set the owner of the phpipam directory
```sudo chown -R www-data:www-data /var/www/html/phpipam```
#### copy sample config file
```sudo cp /var/www/html/phpipam/config.dist.php /var/www/html/phpipam/config.php```
#### edit config.php
```sudo vim /var/www/html/phpipam/config.php```



#### Update the database connection details

```bash
$db['host'] = '127.0.0.1';
$db['user'] = 'php_ipam_rw';
$db['pass'] = 'P4P1p@m!!';
$db['name'] = 'php_ipam';
$db['port'] = 3306;

```

#### Below the database connection, add the following line to define the BASE variable
```define('BASE', "/phpipam/");```



#### enable mod_rewrite
```sudo a2enmod rewrite```
#### restart apache2 service
```sudo systemctl restart apache2```


#### phpIPAM Web Installer
- Open a web browser and navigate to http://DNSorIP/phpipam  
- The phpipam Installation web installer should be load  
- Click the New phpipam installation button  
- Click the Automatic database installation button  
- Complete the database form as follows 

```bash
MySQL/MariaDB username: php_ipam_rw
MySQL/MariaDB password: P4P1p@m!!
MySQL/MariaDB database location: 127.0.0.1
MySQL/MariaDB database name: php_ipam
```

- Click the Show advanced options button  
- Uncheck Create new database and Set permissions to tables > Click the Install phpipam database button  
- Once the database is initialized, click the Continue button  
- Enter and confirm an admin user password > Click Save settings  
- Click the Proceed to login button  
- Login with the username admin and the admin password set earlier  
- Welcome to phpIPAM 



### Dockerise the phpIPAM

1. Dockerfile

``` yaml

# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Update and install required packages
RUN apt update && apt upgrade -y && \
    apt install -y curl wget zip git apache2 mariadb-server mariadb-client \
    php php-curl php-common php-gmp php-mbstring php-gd php-xml php-mysql php-ldap php-pear

# Configure MySQL and create the database
RUN service mysql start && \
    mysql_secure_installation && \
    mysql -u root -e "CREATE DATABASE php_ipam;" && \
    mysql -u root -e "GRANT ALL ON php_ipam.* to 'php_ipam_rw'@'localhost' IDENTIFIED BY 'P4P1p@m!!';" && \
    mysql -u root -e "FLUSH PRIVILEGES;"

# Clone the phpIPAM repository to the webroot
RUN git clone https://github.com/phpipam/phpipam.git /var/www/html/phpipam && \
    cd /var/www/html/phpipam && \
    git checkout "$(git tag --sort=v:tag | tail -n1)"

# Set the owner of the phpipam directory
RUN chown -R www-data:www-data /var/www/html/phpipam

# Copy the sample config file and update the database connection details
RUN cp /var/www/html/phpipam/config.dist.php /var/www/html/phpipam/config.php && \
    sed -i "s/\['host'\] =.*/['host'] = '127.0.0.1';/" /var/www/html/phpipam/config.php && \
    sed -i "s/\['user'\] =.*/['user'] = 'php_ipam_rw';/" /var/www/html/phpipam/config.php && \
    sed -i "s/\['pass'\] =.*/['pass'] = 'P4P1p@m!!';/" /var/www/html/phpipam/config.php && \
    sed -i "s/\['name'\] =.*/['name'] = 'php_ipam';/" /var/www/html/phpipam/config.php && \
    echo "define('BASE', \"/phpipam/\");" >> /var/www/html/phpipam/config.php

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Expose port 80 for Apache
EXPOSE 80

# Restart Apache and MySQL services
CMD service mysql start && service apache2 restart && tail -f /dev/null


```


2. Build the Docker image

```docker build -t phpipam-image .```


3. RUn a container with this image

```docker run -d -p 80:80 --name phpipam-container phpipam-image```

  

Calculated Docker image size is about 300Mb

```bash

# Let's calculate an approximate size of the Docker image by considering the sizes of the base image (Ubuntu 22.04)
# and the packages that will be installed.

# The base image Ubuntu 22.04 size is approximately 77MB.
ubuntu_base_size_mb = 77

# The sizes of the packages in MB (approximate):
apache2_size_mb = 52
mariadb_size_mb = 167
php_size_mb = 51
git_size_mb = 24
curl_wget_size_mb = 7
misc_packages_size_mb = 10  # For small packages like zip, pear, and dependencies

# Summing up all the package sizes
total_size_mb = (ubuntu_base_size_mb + apache2_size_mb + mariadb_size_mb +
                 php_size_mb + git_size_mb + curl_wget_size_mb + misc_packages_size_mb)

total_size_mb

Analysis
``` bash
# Let's calculate an approximate size of the Docker image by considering the sizes of the base image (Ubuntu 22.04)
# and the packages that will be installed.

# The base image Ubuntu 22.04 size is approximately 77MB.
ubuntu_base_size_mb = 77

# The sizes of the packages in MB (approximate):
apache2_size_mb = 52
mariadb_size_mb = 167
php_size_mb = 51
git_size_mb = 24
curl_wget_size_mb = 7
misc_packages_size_mb = 10  # For small packages like zip, pear, and dependencies

# Summing up all the package sizes
total_size_mb = (ubuntu_base_size_mb + apache2_size_mb + mariadb_size_mb +
                 php_size_mb + git_size_mb + curl_wget_size_mb + misc_packages_size_mb)

total_size_mb

```









