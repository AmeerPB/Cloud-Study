
## Automate chaning the mariadb config via AWS

<br>


### Default mariadb config

``` bash

#
# These groups are read by MariaDB server.
# Use it for options that only the server (but not clients) should see
#
# See the examples of server my.cnf files in /usr/share/mysql/
#

# this is read by the standalone daemon and embedded servers
[server]

# this is only for the mysqld standalone daemon
# Settings user and group are ignored when systemd is used.
# If you need to run mysqld under a different user or group,
# customize your systemd unit file for mysqld/mariadb according to the
# instructions in http://fedoraproject.org/wiki/Systemd
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
log-error=/var/log/mariadb/mariadb.log
pid-file=/run/mariadb/mariadb.pid


#
# * Galera-related settings
#
[galera]
# Mandatory settings
#wsrep_on=ON
#wsrep_provider=
#wsrep_cluster_address=
#binlog_format=row
#default_storage_engine=InnoDB
#innodb_autoinc_lock_mode=2
#
# Allow server to accept connections on all interfaces.
#
bind-address=0.0.0.0
#
# Optional setting
#wsrep_slave_threads=1
#innodb_flush_log_at_trx_commit=0

# this is only for embedded server
[embedded]

# This group is only read by MariaDB servers, not by MySQL.
# If you use the same .cnf file for MySQL and MariaDB,
# you can put MariaDB-only options here
[mariadb]

# This group is only read by MariaDB-10.5 servers.
# If you use the same .cnf file for MariaDB of different versions,
# use this group for options that older servers don't understand
[mariadb-10.5]


```

<br>


### Removed all the comments

``` bash

[server]

[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
log-error=/var/log/mariadb/mariadb.log
pid-file=/run/mariadb/mariadb.pid


[galera]
bind-address=0.0.0.0

[embedded]

[mariadb]

[mariadb-10.5]

```


### Via SSM


<br>

### Policy required is

`AmazonSSMManagedInstanceCore`


**To check the SSM agent status**

``` bash
yum info amazon-ssm-agent

systemctl status amazon-ssm-agent

```


### RunBook execution script


``` bash

'#!/usr/bin/env bash'
echo "testing" | tee -a /tmp/testing
'# Stop the MariaDB service'
sudo systemctl stop mariadb
''
'# Empty the configuration file'
sudo sh -c '> /etc/my.cnf.d/mariadb-server.cnf'
''
'# Write the new configuration to the file'
sudo tee /etc/my.cnf.d/mariadb-server.cnf > /dev/null <<EOL
'[server]'
''
'[mysqld]'
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock

```







> [!CAUTION]
>
> This step with S3 didn't succeed at the time of testing
>
>
> ### Policy required is
> 
> `AmazonS3ReadOnlyAccess`
> 
> 
> 
> ### Bucket policy for allowing the EC2 instance to access the S3 bucket
> 
> ``` bash
> {
>   "Id": "Policy1720088005925",
>   "Version": "2012-10-17",
>   "Statement": [
>     {
>       "Sid": "Stmt1720087999114",
>       "Action": [
>         "s3:GetObject"
>       ],
>       "Effect": "Allow",
>       "Resource": "arn:aws:s3:::test-bucket-openrc.digital/*",
>       "Principal": {
>         "AWS": [
>           "arn:aws:iam::851725254787:role/S3ReadOnlyAccessForEC2"
>         ]
>       }
>     }
>   ]
> }
> 
> ```
> 
> 
> 
> <br>
> 
> 
> 
> 
> ### Sample UserData with http
> 
> ``` bash
> 
> wget -P /tmp/ https://s3.us-east-2.amazonaws.com/test-bucket-openrc.digital/mariadb-exec.sh 
> chmod +x /tmp/mariadb-exec.sh 
> ./tmp/mariadb-exec.sh 
> 
> ```
> 
> ### Sample UserData with aws s3 cp 
> 
> 
> ``` bash
> aws s3 cp s3://test-bucket-openrc.digital/mariadb-exec.sh /tmp/
> chmod +x /tmp/mariadb-exec.sh 
> ./tmp/mariadb-exec.sh
> 
> ```















