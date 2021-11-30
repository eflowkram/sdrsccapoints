#!/bin/bash
IFS=$'\n'

if [ $# -lt 2 ]; then
  echo "usage $0 <FILENAME> <EVENT_DATE>"
  exit 1
fi

for LINE in `cat $1`; do 

event_date="$2"
place=`echo $LINE | cut -f1 -d,`
#class=`echo $LINE | cut -f2 -d,`
car_number=`echo $LINE | cut -f3 -d,`
club=`echo $LINE | cut -f6 -d,`
final=`echo $LINE | cut -f9 -d,`
dnf=`echo $LINE | cut -f7 -d,`

if [ "$place" -eq 1 ]; then 
   class_time=$final;
fi

#calculate points
if [ $dnf == "DNF" ]; then 
  final=0
  points=70
else
  points=`mysql -Bse "select round(($class_time/$final)*100,3)"`
fi
if [ -z "$club" ] ; then
    club='noclub' 
fi
if [ "$car_number" -ge "1000" ] ; then
    continue
fi

driver_id=`mysql -Bse "select id from drivers where car_number=$car_number" sdr_points`
club_id=`mysql -Bse "select id from clubs where name='$club'" sdr_points` 

# find cones and dnf;
find_cones () {
   retval=`echo $1 | cut -f2 -d+`
   echo $retval
}
conecount=0
dnfcount=0
soundcount=0

echo "$place,$driver_id,$driver,$car_number,$club_id,$club,points:$points,final:$final"
mysql -Bse "INSERT ignore into pax_results (event_date,pax_place,driver_id,club_id,pax_time,points,nat_event) values ('$event_date',$place,$driver_id,$club_id,'$final','$points',0)" sdr_points

unset club
done
#pax
#1,M2EM,143,Jeff Kiesel,15 KFR Turbo Sprite,SCNAX,43.608,*0.894000 ,38.985,0,0
#2,STX,293,Derek Punch,13 Subaru BRZ,DCCSD,48.424,*0.813 ,39.368,0.383,0.383
