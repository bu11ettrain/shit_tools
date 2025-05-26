#!/usr/bin/env bash
source /hive/miners/custom/nptprover/h-manifest.conf

gpu_stats=$(< $GPU_STATS_JSON)
gpu_stats_nvidia=$(jq '[.brand, .temp, .fan, .busids] | transpose | map(select(.[0] == "nvidia")) | transpose' <<< $gpu_stats)
busids=($(jq -r '.[3][]' <<< "$gpu_stats_nvidia"))
temps=($(jq -r '.[1][]' <<< "$gpu_stats_nvidia"))
fans=($(jq -r '.[2][]' <<< "$gpu_stats_nvidia"))

hash_arr=()
busid_arr=()

for busid in "${!busids[@]}"; do
    if [[ "${busids[$busid]}" =~ ^([A-Fa-f0-9]+): ]]; then
        busid_arr+=($((16#${BASH_REMATCH[1]})))
    fi
    hash_arr+=(0)
done

hash_json=$(printf '%s\n' "${hash_arr[@]}" | jq -cs '.')
bus_numbers=$(printf '%s\n' "${busid_arr[@]}"  | jq -cs '.')
fan_json=$(printf '%s\n' "${fans[@]}"  | jq -cs '.')
temp_json=$(printf '%s\n' "${temps[@]}"  | jq -cs '.')

uptime=$(( `date +%s` - `stat -c %Y $CUSTOM_CONFIG_FILENAME` ))
algo='neptune'
version="1.13.2"
stats=""
unit="H/s"
khs=0

khs=$(tail -n 100 /hive/miners/custom/nptprover/nptprover.log |grep "Last 1m speed(KP/s)" | awk 'END {print}'| awk '{print $5}')

khs_num=$(echo "$khs" | jq -R . | jq -s 'map(tonumber)[0]')

stats=$(jq -nc --argjson khs "$khs_num" \
        --arg hs_units "$unit" \
        --argjson hs "$hash_json" \
        --arg ver "$version" \
        --arg algo "$algo" \
        --argjson bus_numbers "$bus_numbers" \
		--argjson fan "$fan_json" \
		--argjson temp "$temp_json" \
		--arg uptime "$uptime" \
        '{$khs, $hs_units, $hs, $temp, $fan, $bus_numbers, $uptime, $ver, $algo}')

echo "$stats"
