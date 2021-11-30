#!/bin/bash
event_date=(`mysql -Bse "select distinct event_date from events" sdr_points`)
event_count=${#event_date[@]}
drop=$(( $event_count/3 ))
limit=$(( $event_count - $drop ))

row=1
event_sql=`while [ $row -le $event_count ]; do echo "points_${row} decimal(10,3),"; ((row++)); done`
event_out=`while [ $row -le $event_count ]; do echo "points_${row},"; ((row++)); done`

temp_sql=$( cat << EOF 
DROP TABLE IF EXISTS pax_temp;
create table pax_temp (
  driver_id int(10), 
  car_number int(10),
  name  varchar(50),
  club  varchar(10),
  $event_sql
  total_points decimal (10,3))
EOF
)

mysql -Bse "$temp_sql" sdr_points

# Walk the drivers
for driver_id in `mysql -Bse "select id from drivers" sdr_points`; do
#for driver_id in 12 17; do

total_sql=$( cat << EOF
create temporary table driver_total ( driver_id int,points decimal(10,3));
insert into driver_total
select 
    driver_id,
    points 
  from 
    pax_results 
  where
    driver_id=$driver_id
  order by points DESC
  limit $limit;
insert into pax_temp (driver_id,total_points) select driver_id, sum(points) from driver_total where driver_id=$driver_id
EOF
)
  mysql -Bse "$total_sql" sdr_points
  
fill_temp1=$( cat << EOF
  update pax_temp 
  join 
    drivers on driver_id=drivers.id 
  join 
    clubs on clubs.id=drivers.club_id 
  set 
    pax_temp.car_number=drivers.car_number, 
    pax_temp.name=concat(drivers.first_name,' ',substr(drivers.last_name,1,1)), 
    club=upper(clubs.name)
EOF
)
mysql -Bse "$fill_temp1" sdr_points

# fill event totals for all events
event_id=1
while [ $event_id -le $event_count ]; do
  
fill_temp2=$(cat << EOF
set @edate:=(select event_date from events where id=$event_id);
update pax_temp
set points_$event_id = (SELECT IFNULL( (SELECT points FROM pax_results WHERE driver_id=$driver_id and event_date=@edate),0)) where driver_id=$driver_id
EOF
)
mysql -Bse "$fill_temp2" sdr_points
((event_id++))
done
unset event_id
done
# spit it out
mysql -Be "set @place=0; select @place:=@place+1 as place, car_number, name, club, $event_out total_points from pax_temp where driver_id is not NULL order by total_points DESC" sdr_points

exit













mysql -Bse "create temporary table pax_temp ( car int, driver varchar(50), club varchar(10), points_1 decimal(10,3), total decimal(10,3));insert into pax_temp select car_number as car_number, concat(first_name,' ',substring(last_name,1,1)) as driver, clubs.name as Club, points as Event_1, points as Total from pax_results join drivers on driver_id=drivers.id join clubs on drivers.club_id=clubs.id order by points DESC;set @rownum=0;select @rownum := @rownum + 1 as positition, car, driver, upper(club), points_1 as Event_1, total from pax_temp order by total DESC, (SELECT @rownum );" sdr_points
#!/bin/bash
declare -A driver_event_points

#event_id=(`mysql -Bse "select events.id from events" sdr_points`)

limit=$(( ${#event_date[@]} % 3 ))
event_count=${#event_date[@]}

header_e=1
while [ $header_e -le $event_count ]; do h2="$h2\tpoints_$header_e";((header_e++)); done 
header="Position\tCar No\ttDriver\tClub${h2}\tTotal"
# figure out drivers for class
    for driver_id in `mysql -Bse "select driver_id from event_results where class_id=$class_id" sdr_points`; do
      driver_event_points[$driver_id]=`mysql -Bse "select group_concat(points,',',event_id) from pax_results where driver_id=$driver_id" sdr_points`
      total_driver_points[$driver_id]=`mysql -Bse "select concat(sum(points),',',$driver_id) from event_results where class_id=$class_id and driver_id=$driver_id order by points DESC limit $limit" sdr_points`
      driver_info1[$driver_id]=`mysql -Bse "select short_name as class, car_number as num, concat(first_name,' ',substring(last_name,1,1)) as driver, upper(clubs.name) from event_results join drivers on driver_id=drivers.id join classes on class_id=classes.id join clubs on drivers.club_id=clubs.id where class_id=$class_id and driver_id=$driver_id limit 1" sdr_points`
      driver_info2[$driver_id]=`mysql -Bse "select sum(run_count) as runs, sum(cone_count) as cones, sum(dnf_count) as DNF, sum(sound_violations) as Sound from event_results join drivers on driver_id=drivers.id join classes on class_id=classes.id join clubs on drivers.club_id=clubs.id where class_id=$class_id and driver_id=$driver_id" sdr_points`
    done


#spit it out

IFS=$'\n' sorted_points=($(sort -rn <<<"${total_driver_points[*]}"))
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
  echo -e "${driver_info1[$d_id]}\t`echo ${event_points[@]} | sed -e 's/\ /\t/'`\t$driver_event_points${total_driver_points[$d_id]%,*}\t${driver_info2[$d_id]}"
#  ((p++))
  e=1
done
unset driver_id driver_event_points total_driver_points driver_info1 driver_info2 header_e
done
