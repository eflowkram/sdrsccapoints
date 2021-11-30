#!/bin/bash

# use pax results to build driver table.
IFS=$'\n'
for LINE in `egrep "^[0-9]" $1`; do
first_name=`echo $LINE | cut -f4 -d, | cut -f1 -d\ `
last_name=`echo $LINE | cut -f4 -d, | cut -f2 -d\ `
car_number=`echo $LINE | cut -f3 -d,`
club=`echo $LINE | cut -f6 -d,`
if [ -z $club ]; then club="noclub"; fi

club_id=`mysql -Bse "select id from clubs where name='$club'" sdr_points`


if [ "$car_number" -lt 1000 ]; then
echo "INSERT ignore into drivers (first_name,last_name,car_number,club_id) values ('$first_name','$last_name','$car_number',$club_id);"

mysql -Bse "INSERT ignore into drivers (first_name,last_name,car_number,club_id) values ('$first_name','$last_name','$car_number',$club_id);" sdr_points
fi
unset club
done
