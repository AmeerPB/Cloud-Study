#### PI-Hole SSL configuration

#### Step 1:Locate the SSL Certificate and Private Key Files
Certificate file: Usually with extensions like .crt, .cer, or .pem.
Private key file: Usually with the extension .key.

#### Step 2. Combine the Certificate and Key Files
You need to concatenate the SSL certificate and the private key into a single file. This can be done using the cat command in a Unix-like environment.
``` bash
cat your_certificate.crt your_private.key > combined.pem
```

#### Step 2.1 Install the OpenSSL plugin on the host
``` bash
sudo apt update && sudo apt install -y lighttpd-mod-openssl
```


#### Step 3. Create the configuration file

/etc/lighttpd/conf-available/20-https.conf

``` bash
#Loading openssl
# Set the document root for your site
# server.document-root = "/var/www/html"  # Replace with the actual path to your website's root directory

server.modules += ( "mod_openssl" )

$SERVER["socket"] == ":443" {
 ssl.engine  = "enable"
 ssl.pemfile = "/etc/lighttpd/combined.pem"
 ssl.openssl.ssl-conf-cmd = ("MinProtocol" => "TLSv1.3", "Options" => "-ServerPreference")
}

# Redirect HTTP to HTTPS
$HTTP["scheme"] == "http" {
    url.redirect = ("" => "https://\${url.authority}\${url.path}\${qsa}")
    url.redirect-code = 308
}


```

#### Step 4. Copy the configuration file to lighttpd
``` bash
sudo cp 20-https.conf /etc/lighttpd/conf-available/
```

#### Step 5. Enable the configuration by creating a symbolic link
``` bash
sudo ln -s ../conf-available/20-https.conf \
  /etc/lighttpd/conf-enabled/20-https.conf
```

#### Ste 6. Check the lighttpd configuration
``` bash
lighttpd -tt -f /etc/lighttpd/lighttpd.conf
```


#### Step 7. Restart the Lighttpd service

``` bash

sudo service lighttpd restart && sudo service lighttpd status

```









