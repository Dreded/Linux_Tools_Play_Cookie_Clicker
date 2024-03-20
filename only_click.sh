#!/usr/bin/env bash
#

# this counts mouse clicks
# xinput test-xi2 --root 2 | awk 'BEGIN { count=0 } /16 \(RawButtonRelease\)/ { count=count+1; printf "\r%'"'"'d", count*13678 }'0;

# this makes mouse clicks
# xdotool click --repeat 10000000 --delay 35

#xbindkeys allows us to use a key 'q' to close all the scripts
xbindkeys -f xbindkeys.conf
if [[ $1 -gt 0 ]]
then
  COOKIES_PER_CLICK=$1
else
  COOKIES_PER_CLICK=1
fi

if [[ $2 -gt 0 ]]
then
  CLICKS_BETWEEN_BUY=$2
else
  CLICKS_BETWEEN_BUY=100
fi

# GUI Pixel stuff
# eval gets us WINDOW,X,Y,WIDTH,HEIGHT
eval $(xdotool search --name "Cookie Clicker" getwindowgeometry --shell)
SPACE_BETWEEN_BUTTONS=70
COOKIE_X=230
COOKIE_Y=600

CLICK_DELAY=35
CLICK_SLEEP=$(echo "scale=3; $CLICK_DELAY/1000" | bc)
moveTo() { xdotool mousemove --window $WINDOW $1 $2; }
moveToCookie() { moveTo $COOKIE_X $COOKIE_Y; }

doClick () {
  if [[ $1 -gt 1 ]]
  then
    xdotool click --repeat $1 --delay $CLICK_DELAY 1 
  else
    xdotool click --delay 1 1 
  fi
}
counter=1

moveToCookie
while [ 1 ]
do
  doClick 1;
  ((counter++))
  printf {"\rClicks:\t%d\nCookies:%'-30d\033[1A",$counter,$((counter*COOKIES_PER_CLICK))} 
  sleep $CLICK_SLEEP
done
