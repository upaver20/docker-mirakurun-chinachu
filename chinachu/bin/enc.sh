#!/bin/bash

log=/home/upaver20/chinachu/log/encode

echo -----start encoding @$(date +%Y/%m/%d/%H:%M:%S)----- >> $log
start=$(date +%s)
echo $1 >> $log

/usr/local/bin/ffmpeg \
   -vaapi_device /dev/dri/renderD128 -hwaccel vaapi -hwaccel_output_format vaapi \
   -i "$1" -y \
   -analyzeduration 5M -probesize 5M \
   -acodec libfdk_aac -vcodec h264_vaapi -aspect 16:9 -qp 24 -bf 2 -threads 2\
   -vf 'format=nv12|vaapi,hwupload,scale_vaapi=w=1280:h=720' \
   ${1%.*}.mp4 2>&1 | grep "^[^f]" >> $log

end=$(date +%s)
diff=$(expr $end - $start)
echo about $(expr $diff / 60) min. >> $log
echo ---finish encoding @$(date +%Y/%m/%d/%H:%M:%S)--- >> $log
echo >> $log

mv $1 /media/TV/tmp
recorded_json=/home/upaver20/chinachu/data/recorded.json
recorded=`cat $recorded_json`
id=`echo $2 | jq -r .id`
echo $recorded | jq -c --arg id $id --arg mp4 "${1%.*}.mp4" '(.[] | select(.id == $id) | .recorded) |= $mp4' > $recorded_json

exit 0
