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
