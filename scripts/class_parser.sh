#!/bin/bash
IFS=$'\n'
for LINE in `egrep "^[A-Z,a-z]" $1`; do
sname=`echo $LINE | cut -f1 -d\ `
long_name=`echo $LINE | cut -f2 -d\'`
mysql -Bse "INSERT ignore into classes (short_name,long_name) values ('$sname','$long_name');" sdr_points
done
