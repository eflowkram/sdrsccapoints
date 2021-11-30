#!/bin/bash
declare -A driver_event_points
time_only_id=118  # class id for exclusion of timeonly depends on db.
#event_id=(`mysql -Bse "select events.id from events" sdr_points`)
event_date=(`mysql -Bse "select distinct event_date from events" sdr_points`)
event_count=${#event_date[@]}
drop=$(( $event_count/3 ))
limit=$(( $event_count - $drop ))
temp_sql=$( cat << EOF
DROP TABLE IF EXISTS driver_temp;
create table driver_temp (
  driver_id int(10),
  points decimal (10,3))
EOF
)


header_e=1
while [ $header_e -le $event_count ]; do h2="$h2\tpoints_$header_e";((header_e++)); done 
header="Class\t#\tDriver\tClub${h2}\tTotal\tRuns\tCones\tDNFS\tSound"
  for class_id in `mysql -Bse "select id from classes where id not in ($time_only_id) order by class_order ASC" sdr_points`; do 
#  for class_id in 31; do 
    long_name=`mysql -Bse "select long_name from classes where id=$class_id" sdr_points`
# figure out drivers for class
    for driver_id in `mysql -Bse "select driver_id from event_results where class_id=$class_id" sdr_points`; do
      driver_event_points[$driver_id]=`mysql -Bse "select group_concat(points,',',event_id) from event_results where driver_id=$driver_id and class_id=$class_id" sdr_points`
      total_driver_points[$driver_id]=`mysql -Bse "$temp_sql; insert into driver_temp select $driver_id,points from event_results where class_id=$class_id and driver_id=$driver_id order by points DESC limit $limit; select concat(sum(points),',',$driver_id) from driver_temp" sdr_points`
      driver_info1[$driver_id]=`mysql -Bse "select short_name as class, car_number as num, concat(first_name,' ',substring(last_name,1,1)) as driver, upper(clubs.name) from event_results join drivers on driver_id=drivers.id join classes on class_id=classes.id join clubs on drivers.club_id=clubs.id where class_id=$class_id and driver_id=$driver_id limit 1" sdr_points`
      driver_info2[$driver_id]=`mysql -Bse "select sum(run_count) as runs, sum(cone_count) as cones, sum(dnf_count) as DNF, sum(sound_violations) as Sound from event_results join drivers on driver_id=drivers.id join classes on class_id=classes.id join clubs on drivers.club_id=clubs.id where class_id=$class_id and driver_id=$driver_id" sdr_points`
    done


#spit it out

IFS=$'\n' 
sorted_points=($(sort -rn <<<"${total_driver_points[*]}"))
p=1
e=1
header_e=1
#build the header with appropriate event count.


echo $long_name
echo -e $header
for driver in ${sorted_points[@]}; do
  d_id=${driver#*,}
  while [ $e -le $event_count ]; do 
  event_points[$e]=`mysql -Bse "SELECT IFNULL( (SELECT points FROM event_results WHERE driver_id=$d_id and class_id=$class_id and event_id=$e),0) as points;" sdr_points`
  ((e++))
  done
  echo -e "${driver_info1[$d_id]}\t`echo ${event_points[@]} | sed -e 's/\ /\t/g'`\t$driver_event_points${total_driver_points[$d_id]%,*}\t${driver_info2[$d_id]}"
#  ((p++))
  e=1
done
unset driver_id driver_event_points total_driver_points driver_info1 driver_info2 header_e
done
