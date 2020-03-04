#!/bin/bash

ignored="$HOME/.measureit.ignore";

touch $ignored

function make_entry() {
json="{\"time_entry\":{\"description\":\"$1\",\"created_with\":\"measureit.sh\",\"start\":\"$2\",\"duration\":$3}}";
curl -v -u $4:api_token \
        -H "Content-Type: application/json" \
        -d "$json" \
        -X POST https://www.toggl.com/api/v8/time_entries 2> /dev/null > /dev/null
echo "Entry: $1 $2 $3";
}

if [ -z "$2" ]; then
echo "Usage: <toggl user name> <toggl password> [minimal interval]";
exit;
fi

TUSER=$1
TPASS=$2
INTERVAL=$3
if [ -z "$INTERVAL" ]; then
 INTERVAL=300
fi

n=0;
wold="";

while sleep 1
do
  w=`xdotool getactivewindow getwindowname`;
  if [ "$w" != "$wold" ]; then
    ig=$(cat $ignored|grep -ve "^$"|while read i
    do
        if [ -n "`echo -n "$wold"|grep "$i"`" ]; then
          echo "yes";
        fi
    done);
    if [ -z "$ig" ] && [ $n -gt $INTERVAL ]; then
        api_token=`curl -u $TUSER:$TPASS -X GET https://www.toggl.com/api/v8/me 2> /dev/null|jq -r ".data.api_token"`;
        make_entry "$wold" "`date +"%Y-%m-%dT%H:%M:%S+01:00"`" $n $api_token
    fi
    n=0;
    wold="$w";
  fi
  n=`expr $n + 1`;
done
