#!/bin/bash
dns=$(/usr/bin/python ./createcname.py -d $1 -c $2 -h $3)
nslookup $dns

while [ $? -eq 1 ]
do
        sleep 5
        nslookup $dns
done
