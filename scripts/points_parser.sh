#!/bin/bash
IFS=$'\n'
if [ $# -lt 2 ]; then
  echo "usage $0 <FILENAME> <EVENT_DATE>"
  exit 1
fi

for LINE in `cat $1`; do 
if [[ "$LINE" =~ ^[A-Za-z] ]]; then 
    class=`echo $LINE | awk '{print $1}'`
    echo startofclass $class 
    class_id=`mysql -Bse "select id from classes where short_name='$class'" sdr_points`
    continue
fi

event_date="$2"
event_id=`mysql -Bse "select id from events where event_date='$event_date'" sdr_points`
place=`echo $LINE | cut -f1 -d,`
#class=`echo $LINE | cut -f2 -d,`
car_number=`echo $LINE | cut -f3 -d,`
club=`echo $LINE | cut -f6 -d,`
run1=`echo $LINE | cut -f7 -d,`
run2=`echo $LINE | cut -f8 -d,`
run3=`echo $LINE | cut -f9 -d,`
run4=`echo $LINE | cut -f10 -d,`
run5=NULL
#run5=`echo $LINE | cut -f11 -d,`
final=`echo $LINE | cut -f11 -d,`

if [ "$place" -eq 1 ]; then 
   class_time=$final;
fi

#calculate points
if [ $final == "DNF" ]; then
  final=0.000
  points=70
else
  points=`mysql -Bse "select round(($class_time/$final)*100,3)"`
fi

if [ -z "$club" ] ; then
    club=noclub 
fi
if [ "$car_number" -ge "1000" ]; then
    continue
fi
driver=`mysql -Bse "select concat(first_name,' ',substring(last_name,1,1)) from drivers where car_number=$car_number" sdr_points`
driver_id=`mysql -Bse "select id from drivers where car_number=$car_number" sdr_points`
# find cones and dnf;
find_cones () {
   retval=`echo $1 | cut -f2 -d+`
   echo $retval
}
conecount=0
dnfcount=0
soundcount=0
runcount=0

for run in $run1 $run2 $run3 $run4; do
  run_extra=`find_cones $run`
  case $run_extra in
    DNF|dnf )
      let dnfcount=$dnfcount+1
      ;;
    [1-8] )
      let conecount=$conecount+$run_extra
      ;;
    9[3-9].[0-9] )
      let soundcount=$soundcount+1
      ;;
    * )
  esac
  if [ "$run" > "0" ]; then let runcount=$runcount+1; fi
done

echo "$class,$driver,$car_number,$club,$run1,$run2,$run3,$run4,cones:$conecount,dnf:$dnfcount,sound:$soundcount,points:$points"

mysql -Bse "insert into event_results values (NULL,'$event_date',$event_id,$driver_id,$class_id,'${run1/+*}','${run2/+*}','${run3/+*}','${run4/+*}',NULL,$place,'$final','$points',$conecount,$dnfcount,$soundcount,$runcount,0,0)" sdr_points
echo "insert into event_results values (NULL,'$event_date',$event_id,$driver_id,$class_id,'${run1/+*}','${run2/+*}','${run3/+*}','${run4/+*}',NULL,$place,'$final','$points',$conecount,$dnfcount,$soundcount,$runcount,0,0)"



unset conecount
unset soundcount
unset club
done






#1,SS,61,Gary Samad,13 Porsche Boxster S,,53.046,52.604,51.234,51.701,51.234,-
#1,AS,856,William Flores,17 Chevrolet Camaro 1LE,SCNAX,51.803,50.85,50.55,50.489,50.489,[-]0.262
#2,AS,997,Eric Trigg,03 Chevrolet Corvette Z06,SCNAX,51.741,51.174,50.836,50.751,50.751,0.262
