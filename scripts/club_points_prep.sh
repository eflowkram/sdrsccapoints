mysql -Bse "create temporary table club_points_temp (event_id int(10), class_id int(10)); insert into club_points_temp select event_id,class_id from event_results join drivers on driver_id=drivers.id join classes on class_id=classes.id where club_id in (1,2,4) group by class_id,event_id having count(distinct club_id) > 1;
update event_results join club_points_temp using(event_id,class_id) set club_points=1;" sdr_points

event_count=`mysql -Bse "select count(1) from events" sdr_points`
echo $event_count

event_counter=1;
while [ $event_counter -le $event_count ]; do 
  echo $event_counter
  mysql -Bse "insert ignore into club_points select NULL,club_id,event_id, round(avg(points),4) from event_results join drivers on driver_id=drivers.id join clubs on club_id=clubs.id  where club_id in (1,2,4) and club_points = 1 and event_id= $event_counter group by club_id, event_id;" sdr_points 
  let event_counter++
done

