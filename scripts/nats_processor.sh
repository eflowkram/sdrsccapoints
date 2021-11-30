#!/bin/bash
for row in `cat $1`;do
  driver_id=`echo $row|cut -f1 -d,`
  class_id=`echo $row|cut -f2 -d,`
  club_id=`echo $row|cut -f3 -d,`
  event_date=`echo $row|cut -f4 -d,`

#echo $driver_id, $class_id, $event_date


#process pax first
  pax_avg=`mysql -Bse "select avg(points) from pax_results where driver_id=${driver_id} and nat_event=0" sdr_points`
  class_avg=`mysql -Bse "select avg(points) from event_results where driver_id=${driver_id} and class_id=${class_id} and nat_event=0" sdr_points`
  event_id=`mysql -Bse "select id from events where event_date=${event_date}" sdr_points`

#echo $pax_avg $class_avg


  mysql -Bse "insert into event_results (event_date,event_id,driver_id,class_id,points,nat_event) values (${event_date},${event_id},$driver_id,$class_id,${class_avg},1) on duplicate key update points=${class_avg}" sdr_points
  mysql -Bse "insert into pax_results (event_date, driver_id, club_id, points, nat_event) values (${event_date},${driver_id},${club_id},${pax_avg},1) on duplicate key update points=${pax_avg}" sdr_points

done
