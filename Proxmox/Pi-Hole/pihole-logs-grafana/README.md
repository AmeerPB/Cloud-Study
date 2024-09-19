#### Send the following pihole log files to grafana for monitoring  

1. FTL.log
1. FTL.log.1
1. pihole.log
1. pihole.log.1


  

### Steps

1. Install promtail on pihole instance
1. Add the scrape jobs in the /etc/promtail/config.yml file
1. Restart promtail service
4. Enable promtail service
6. Configure Loki in grafana and add source (if not already done)
7. Setup local dns for FQDN (eg: loki.xsec.in) OR /etc/hosts in pihole


### Configuration files are :

1. /etc/promtail/config.yml
1. loki docker-compose


  

  


