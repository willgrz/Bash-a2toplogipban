#!/bin/bash
#William <william @ william.si> 2013
#spcially good as base for other scripts based on a2top.log string searches
string=$1
 
for IP in $(\
        tail -20000 /var/log/apache2/a2top.log \
        | grep POST \
        | grep $string \
        | /etc/alternatives/nawk -F";" '{for (i=1;i<=NF;i++) {a[i]=$i} print a[3]}' \
        | sort \
        | uniq); do
                #get geolocation
                /usr/local/bin/geoiplookup -i $IP \
                | egrep '(Country)' \
                | xargs \
                | awk '{print "Loc:",$4,$5,$6,$7}'
                #get network range and echo this data in custom format
                        /usr/local/bin/geoiplookup -i $IP \
                        | egrep '(range_by_ip|network num)' \
                        | xargs \
                        | sed -e 's/::/\//' \
                        | awk '{print "Net:",$2,"-",$4,"#","Mask:",$10}'
                #ask if ip should be iptabled
                echo "block $IP?"
                        select yn in "Yes" "No"; do
                                case $yn in Yes )
                                        echo "Banning $IP";
                                        iptables_add $IP;
                                        break;;
                                No )
                                        break;;
                        esac
        done
 
done
