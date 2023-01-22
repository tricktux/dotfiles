#!/bin/bash

cwd=$(dirname "$0")

k="$cwd"/google-key.sh
i="$cwd"/traffic-info.sh
o="/tmp/g.json"

if [[ ! -f $k || ! -f $i ]]; then
	echo "E: no config"
	exit 0
fi

source "$k"
source "$i"

wifi_curr=$(iwgetid -r)

for w in "${home[@]}"; do
	if [[ $wifi_curr = $w ]]; then
		echo ""
		exit 0
	fi
done

[[ -f $o ]] && rm $o

# Make API call using curl
curl -o "$o" -s "https://maps.googleapis.com/maps/api/distancematrix/json?""\
origins=$origin_lat,$origin_lon""\
&destinations=$dest_lat,$dest_lon&key=$api_key""\
&traffic_model=best_guess&departure_time=now" >/dev/null 2>&1

if [[ ! -f $o ]]; then
	echo "E: no output"
	exit 0
fi

# Extract travel time and distance from API response
travel_time=$(cat "$o" | jq '.rows[0].elements[0].duration.value')
travel_time_in_traffic=$(cat "$o" | jq '.rows[0].elements[0].duration_in_traffic.value')
travel_distance=$(cat "$o" | jq '.rows[0].elements[0].distance.value')
travel_time=$(awk "BEGIN {print $travel_time/60}")
travel_time_in_traffic=$(awk "BEGIN {print $travel_time_in_traffic/60}")

# Print results
printf " %.2f/%.2f (min) \n" $travel_time $travel_time_in_traffic
