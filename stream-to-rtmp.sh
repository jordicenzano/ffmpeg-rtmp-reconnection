#!/usr/bin/env bash

if [ $# -lt 1 ]; then
	echo "Use ./stream-to-rtmp.sh [rtmpUrl] [TEXT-TO-OVERLAY] [RTMP reconnect interval]\n"
    echo "Example: ./stream-to-rtmp.sh \"HELLO\" \"rtmps://abc.com/app/live\" \"hello\" 20"
	exit 1
fi

# Overlay base text
TEXT="SOURCE-"
if [ ! -z "$2" ]; then
    TEXT="$2"
fi

# Default reconnect inverval
RTMP_RECONNECT_INTERVAL_S="0"
if [ ! -z "$3" ]; then
    RTMP_RECONNECT_INTERVAL_S="$3"
fi

echo "Using Text: \"$TEXT\", and $RTMP_RECONNECT_INTERVAL_S"

# Select font path based in OS
# TODO: Probably (depending on the distribuition) for linux you will need to find the right path
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    FONT_PATH='/usr/share/fonts/dejavu/DejaVuSans-Bold.ttf'
elif [[ "$OSTYPE" == "darwin"* ]]; then
    FONT_PATH='/Library/Fonts/Arial.ttf'
fi

# Start test signal
./ffmpeg -hide_banner -y \
-f lavfi -re -i smptebars=size=1280x720:rate=30 \
-f lavfi -i sine=frequency=1000:sample_rate=48000 \
-pix_fmt yuv420p \
-vf "drawtext=fontfile=$FONT_PATH: text=\'${TEXT} 720p - Local time %{localtime\: %Y\/%m\/%d %H.%M.%S} (%{n})\': x=100: y=50: fontsize=30: fontcolor=pink: box=1: boxcolor=0x00000099" \
-c:v libx264 -b:v 6000k -g 60 -profile:v baseline -preset veryfast \
-c:a aac -b:a 48k \
-rtmp_reconnect_time "$RTMP_RECONNECT_INTERVAL_S" -f flv "$1"
