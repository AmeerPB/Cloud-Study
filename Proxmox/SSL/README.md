#### Add custom SSL certificate and KEY to Proxmox Web UI

> sample acme.json file 

``` json
{
  "cloudflare": {
    "Account": {
      "Email": "xxxxxxxx@outlook.com",
      "Registration": {
        "body": {
          "status": "valid",
          "contact": [
            "mailto:xxxxxxxx@outlook.com"
          ]
        },
        "uri": "https://acme-v02.api.letsencrypt.org/acme/acct/1882220426"
      },
      "PrivateKey": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx==",
      "KeyType": "4096"
    },
    "Certificates": [
      {
        "domain": {
          "main": "xsec.in",
          "sans": [
            "*.xsec.in"
          ]
        },
        "certificate": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
        "key": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
        "Store": "default"
      }
    ]
  }

```


> [!NOTE]
>
> ### Steps to implement the SSL to proxmox web ui
> 
> ####Step 1: Extract the Certificate and Key
> 
> First, you need to extract the certificate and private key from the acme.json file. The certificate and key fields are already base64-encoded, so you'll need to decode them.
> 
> Extract the Certificate:
> 
> Copy the value of the certificate field from the acme.json.
> 
> Save it to a file (e.g., fullchain.pem), and decode it using a base64 decoder. You can do this in a Linux shell:
> 
> ``` bash
> echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxx" | base64 --decode > /etc/pve/local/pve-ssl.pem
> 
> ```
> 
> 
> #### Step 2 : Extract the Private Key:
> 
> Copy the value of the key field.
> 
> Save it to a file (e.g., privkey.pem), and decode it using a base64 decoder:
> 
> ``` bash
> echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxx" | base64 --decode > /etc/pve/local/pve-ssl.key
> 
> ```
> After addin both the keys, restart the pveproxy
> ``` bash
> systemctl restart pveproxy.service && systemctl status pveproxy.service
> ```

