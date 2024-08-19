####### phpIPAM installation on Uwwuntuu 22.04

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











