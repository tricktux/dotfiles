#!/usr/bin/env bash
#AccuWeather (r) RSS weather tool for conky
#
#USAGE: weather.sh UKXX0062
#
#(c) Michael Seiler 2007
METRIC=0 #Should be 0 or 1; 0 for F, 1 for C
if [ -z $1 ]; then
echo
echo "USAGE: weather.sh <locationcode>"
echo
exit 0;
fi
# This line prints not only weather conditions but also temp
curl -s http://rss.accuweather.com/rss/liveweather_rss.asp\?metric\=${METRIC}\&locCode\=$1 | perl -ne 'if (/Currently/) {chomp;/\<title\>Currently: (.*)?\<\/title\>/; print "$1"; }'
# This line prints only temp
# curl -s http://rss.accuweather.com/rss/liveweather_rss.asp\?metric\=${METRIC}\&locCode\=$1 | perl -ne 'if (/Currently/) {chomp;/\<title\>Currently: (.*)?\<\/title\>/; print substr("$1", index("$1", ":")+2, length("$1")); }'
