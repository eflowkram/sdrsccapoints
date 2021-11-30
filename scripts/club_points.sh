#!/bin/bash
mysql -Bse "create temporary table club_points_temp (event_id int(10), class_id int(10)); insert into club_points_temp select event_id,class_id from event_results join drivers on driver_id=drivers.id join classes on class_id=classes.id where club_id in (1,2,4) group by class_id,event_id having count(distinct club_id) > 1; update event_results join club_points_temp using(event_id,class_id) set club_points=1;" sdr_points

prep_event_count=`mysql -Bse "select count(1) from events" sdr_points`
prep_event_counter=1;
while [ $prep_event_counter -le $prep_event_count ]; do
  mysql -Bse "insert ignore into club_points select NULL,club_id,event_id, round(avg(points),4) from event_results join drivers on driver_id=drivers.id join clubs on club_id=clubs.id  where club_points = 1 and event_id= $prep_event_counter group by club_id, event_id;" sdr_points
  let prep_event_counter++
done



declare -A total_club_points
event_date=(`mysql -Bse "select distinct event_date from events" sdr_points`)
event_count=${#event_date[@]}
drop=$(( $event_count/3 ))
limit=$(( $event_count - $drop ))
temp_sql=$( cat << EOF
DROP TABLE IF EXISTS club_temp;
create table club_temp (
  club_id int(10),
  points decimal (10,4))
EOF
)


header_e=1
while [ $header_e -le $event_count ]; do h2="$h2\tEvent $header_e";let header_e++; done 
header="Club${h2}\tTotal"
# figure out drivers for class
    for club_id in {1..4}; do
      total_club_points[$club_id]=`mysql -Bse "$temp_sql; insert into club_temp select $club_id, club_points from club_points where club_id=$club_id order by club_points DESC limit $limit; select concat(sum(points),',',$club_id) from club_temp" sdr_points`
      club_name[$club_id]=`mysql -Bse "select upper(name) from clubs where id=$club_id" sdr_points`
    done

IFS=$'\n' 
sorted_points=($(sort -rn <<<"${total_club_points[*]}"))
p=1
e=1
header_e=1
#build the header with appropriate event count.

echo -e $header
for club in ${sorted_points[@]}; do
  c_id=${club#*,}
  while [ $e -le $event_count ]; do 
    event_points[$e]=`mysql -Bse "SELECT IFNULL( (SELECT club_points FROM club_points WHERE club_id=$c_id and event_id=$e),0) as points;" sdr_points`
     ((e++))
  done
  echo -e "${club_name[$c_id]}\t`echo ${event_points[@]} | sed -e 's/\ /\t/g'`\t${total_club_points[$c_id]%,*}\n"
#  ((p++))
  e=1
done
unset club_id club_event_points total_club_points header_e
