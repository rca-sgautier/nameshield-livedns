# nameshield-livedns

The purpose of this container is to update DNS zone records using Nameshield API's with your WAN IP.

This image is extremely lightweight  (Alpine Linux based) and has very few dependencies. The actual DNS update program is coded in shell script only.
This project is based of : https://github.com/jbbodart/gandi-livedns

## Configuration
Mandatory variables:
* APIKEY: your Gandi API key
* DOMAIN: your Gandi domain
* RECORD_LIST: DNS records to update separated by ";"

Optional variables :
* REFRESH_INTERVAL: Delay between updates (default: 10mn)
* TTL: Set Time To Live for records (default: 300)
* SET_IPV4: Update A record (default: yes)
* SET_IPV6: Update AAAA record (default: no)
* FORCE_IPV4: Force the IPv4 address to be used in DNS A records
* FORCE_IPV6: Force the IPv6 address to be used in DNS AAAA records

## Examples
The easiest way to run nameshield-livedns is simply to *docker run* it from a computer in your network, leaving it running in the background with all the default settings.
```sh
docker run -d \
	-e "APIKEY=<YOUR_VERY_SECRET_API_KEY>" \
	-e "RECORD_LIST=blog;www;@" \
	-e "DOMAIN=your-gandi-hosted-domain.com" \
	GIP-RECIA/nameshield-livedns
```
This will update **blog.your-nameshield-hosted-domain.com**, **www.your-nameshield-hosted-domain.com**, and **your-nameshield-hosted-domain.com** with your internet-facing IP (IPv4) every 10 minutes

An equivalent setup using docker-compose could look like this:  
**docker-compose.yml**
```yml
version: '3.7'
...
    services:
    ...
        dyndns:
            image: GIP-RECIA/nameshield-livedns
            restart: unless-stopped
            env_file:
                - "dyndns.env"
```

**dyndns.env**
```properties
APIKEY=<YOUR_VERY_SECRET_API_KEY>
RECORD_LIST=blog;www;@
DOMAIN=your-nameshield-hosted-domain.com
```
