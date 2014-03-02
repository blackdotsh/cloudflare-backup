#!/bin/bash
# Licensed under GPLv3
# created by "black" on LET
# please give credit if you plan on using this for your own projects
# https://github.com/blackdotsh

#TODO:
#	-add subdomain support
#	-switch back to main IP when the main server is online
#	-maybe add more reliable detection methods or even integrate other monitoring services

tkn=""; #cloudflare token
bkupIP=""; #backup IP
email=""; #your CF email
domain="" #change me
domainName="" #currently it only supports the main domain, so it should be the same as the domain variable (no subdomains)
srvceMode="1" #Status of CloudFlare Proxy, 1 = orange cloud, 0 = grey cloud.
sleepTime="60" #number of seconds to sleep for before checking again

function rec_load_all() {

curl https://www.cloudflare.com/api_json.html \
  -d 'a=rec_load_all' \
  -d "tkn=$tkn" \
  -d "email=$email" \
  -d "z=$1" -s | python -mjson.tool > results.txt
}

#$1 = searching for that zone's dns ID
function getDNSID() {
	dnsLineNum=`grep -E "$1" -n results.txt | head -n 1 |  cut -d ":" -f1`;
	echo "dns line #:$dnsLineNum";
	dnsIDLineNum=`echo "$dnsLineNum + 13" | bc -q`;
	echo "dns id line #: $dnsIDLineNum";
	DNSID=`sed -n "$dnsIDLineNum p" results.txt | cut -d ":" -f2 | sed "s/\"//g;s/ //;s/\,//";`
}


#$1=target domain
#$2=name of the DNS record
#$3=new ip address
#$4=service mode

function edit_rec() {
echo "DNSID: $DNSID";
curl -s https://www.cloudflare.com/api_json.html \
  -d 'a=rec_edit' \
  -d "tkn=$tkn" \
  -d "id=$DNSID" \
  -d "email=$email" \
  -d "z=$1" \
  -d "type=A" \
  -d "name=$2" \
  -d "content=$3" \
  -d "service_mode=$4" \
  -d "ttl=1" | grep '"result":"success"';

if [ $? -eq 0 ] 
then
	sleep 0;
	echo `date` "successfully changed servers to $bkupIP" >> cf.log
fi
}

while [ true ]
do
	curl -I -s testme.getipaddr.net | grep "HTTP/1.1 200 OK" -q;
	if [ $? -eq 1 ]
	then
		echo `date` "service is down, going to backup IP" >> cf.log
		rec_load_all "$domain";
		getDNSID "$domain";
		edit_rec "$domain" "$domainName" "$bkupIP" "$srvceMode";
		#add whatever else you want to do here, perhaps send yourself an email using mailx

	fi
sleep $sleepTime;
done

