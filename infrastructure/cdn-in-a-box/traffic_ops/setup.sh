#!/usr/bin/bash

set -x
set -e

# First, we need to authenticate
curl -skc cookie.jar -d "{\"u\":\"$TO_ADMIN_USER\",\"p\":\"twelve\"}" https://localhost:6443/api/1.3/user/login
echo
# Now set up a new CDN...
curl -skb cookie.jar -d @/cdns.json https://localhost:6443/api/1.3/cdns
echo
#... and a delivery service
curl -skb cookie.jar -d @/deliveryservices.json https://localhost:6443/api/1.3/deliveryservices
echo
#... and a cachegroup
MID_LOC_ID=$(curl -skb cookie.jar https://localhost:6443/api/1.3/types | sed -re 's/\},\{/\n/g' | grep MID_LOC | tr ',' '\n' | grep '"id"' | cut -d : -f2)

# I have literally no idea why this is happening and it's so infuriating
if [[ -f '/cachegroup.jsone' ]]; then
	mv /cachegroup.jsone /cachegroup.json
fi


sed -ie "s/MID_LOC_ID/${MID_LOC_ID}/g" /cachegroup.json
curl -skb cookie.jar -d @/cachegroup.json https://localhost:6443/api/1.3/cachegroups
echo
#... and a division
curl -skb cookie.jar -d '{"name":"CDN_in_a_Box"}' https://localhost:6443/api/1.3/divisions
echo
#... and a region
curl -skb cookie.jar -d '{"name":"CDN_in_a_Box"}' https://localhost:6443/api/1.3/divisions/CDN_in_a_Box/regions
echo
#... and a physical location
curl -skb cookie.jar -d @/phys_location.json https://localhost:6443/api/1.3/regions/CDN_in_a_Box/phys_locations
echo


#cleanup at exit
rm cookie.jar