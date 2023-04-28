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
	sleep 2

	temp1=$(cat /sys/class/hwmon/hwmon3/temp2_input)
	temp2=$(cat /sys/class/hwmon/hwmon3/temp3_input)

	if [ "$temp1" -gt "$temp2" ]
	then
		temp="$temp1"
	else
		temp="$temp2"
	fi

	case "$sp" in
		0)
			if [ "$temp" -gt 58000 ]
			then
				echo "0" > "$ctrlpath$dfast"
				echo "0" > "$ctrlpath$dmed"
				echo "1" > "$ctrlpath$dslow"
				sp=1
			fi
			;;

		1)
			if [ "$temp" -lt 44000 ]
			then
				echo "0" > "$ctrlpath$dfast"
				echo "0" > "$ctrlpath$dmed"
				echo "0" > "$ctrlpath$dslow"
				sp=0
			elif [ "$temp" -gt 62000 ]
			then
				echo "0" > "$ctrlpath$dfast"
				echo "1" > "$ctrlpath$dmed"
				echo "0" > "$ctrlpath$dslow"
				sp=2
			fi
			;;

		2)
			if [ "$temp" -lt 52000 ]
			then
				echo "0" > "$ctrlpath$dfast"
				echo "0" > "$ctrlpath$dmed"
				echo "1" > "$ctrlpath$dslow"
				sp=1
			elif [ "$temp" -gt 65000 ]
			then
				echo "1" > "$ctrlpath$dfast"
				echo "0" > "$ctrlpath$dmed"
				echo "0" > "$ctrlpath$dslow"
				sp=3
			fi
			;;

		3)
			if [ "$temp" -lt 62000 ]
			then
				echo "0" > "$ctrlpath$dfast"
				echo "1" > "$ctrlpath$dmed"
				echo "0" > "$ctrlpath$dslow"
				sp=2
			fi
			;;
		esac
	echo "$temp1 $temp2 $temp $sp"
done
