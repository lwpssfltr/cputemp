#!/bin/bash
echo "disabling thermal zones... "

for i in {0..5}
do
	echo "disabled" > /sys/class/thermal/thermal_zone"$i"/mode
done

ctrlpath="/sys/class/thermal/cooling_device"
dslow="2/cur_state"
dmed="1/cur_state"
dfast="0/cur_state"

for i in {0..15}
do
	echo "0" > "$ctrlpath$i"/cur_state
done

echo "done"

sp=0
while true
do
	sleep 3
	temp1=$(cat /sys/class/hwmon/hwmon1/temp4_input)
	temp2=$(cat /sys/class/hwmon/hwmon1/temp3_input)
	if [ "$temp1" -gt "$temp2" ]
	then
		temp="$temp1"
	else
		temp="$temp2"
	fi

	if [ "$temp" -lt 44000 ]
	then
		if [ "$sp" -ne 1 ]
		then
			echo "0" > "$ctrlpath$dfast"
			echo "0" > "$ctrlpath$dmed"
			echo "0" > "$ctrlpath$dslow"
			sp=1
		fi
	elif [ "$temp" -ge 44000 -a "$temp" -lt 54000 ]
	then
		if [ "$sp" -gt 2 ]
		then
			echo "0" > "$ctrlpath$dfast"
			echo "0" > "$ctrlpath$dmed"
			echo "1" > "$ctrlpath$dslow"
			sp=2
		fi
	elif [ "$temp" -ge 54000 -a "$temp" -lt 64000 ]
	then
		if [ "$sp" -ne 3 ]
		then
			echo "0" > "$ctrlpath$dfast"
			echo "1" > "$ctrlpath$dmed"
			echo "0" > "$ctrlpath$dslow"
			sp=3
		fi
	elif [ "$temp" -ge 64000 ]
	then
		if [ "$sp" -ne 4 ]
		then
			echo "1" > "$ctrlpath$dfast"
			echo "0" > "$ctrlpath$dmed"
			echo "0" > "$ctrlpath$dslow"
			sp=4
		fi
	fi
	echo "$temp1 $temp2 $temp $sp"
done
