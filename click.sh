#!/usr/bin/env bash
#

# this counts mouse clicks
# xinput test-xi2 --root 2 | awk 'BEGIN { count=0 } /16 \(RawButtonRelease\)/ { count=count+1; printf "\r%'"'"'d", count*13678 }'0;

# this makes mouse clicks
# xdotool click --repeat 10000000 --delay 35

BONUS_BUY_NUM=7

#xbindkeys allows us to use a key 'q' to close all the scripts
xbindkeys -f xbindkeys.conf

# $1 at bottom
if [[ $2 -gt 0 ]]; then
  COOKIES_PER_CLICK=$2
else
  COOKIES_PER_CLICK=1
fi
case $3 in
  m)
    COOKIE_VERB="Million"
    ;;
  b)
    COOKIE_VERB="Billion"
    ;;
  t)
    COOKIE_VERB="Trillion"
    ;;
  q)
    COOKIE_VERB="Quadrillion"
    ;;
  qu)
    COOKIE_VERB="Quintillion"
    ;;
  *)
    COOKIE_VERB="???"
    ;;
esac
if [[ $4 -gt 0 ]]; then
  CLICKS_BETWEEN_BUY=$4
else
  CLICKS_BETWEEN_BUY=100
fi
case $1 in
  n | normal)
    echo "Click Cookie, Buy Upgrades, Fortune Cookies & Buy Buildings"
    BUY_UPGRADE=1
    FORTUNE_MODE=1
    DOBUY_MODE=1
    ;;
  f | fortune)
    echo "Click Cookie & Fortune Cookies"
    FORTUNE_MODE=1
    ;;
  cb | clickBonus)
    echo "Sell Buildings & Click Mode"
    CLICKBONUS_MODE=1
    CLICKS_BETWEEN_BUY=230
    ;;
  cbf | clickBonusFortune)
    echo "Sell Buildings, Fortune & Click Mode"
    CLICKBONUS_MODE=1
    FORTUNE_MODE=1
    CLICKS_BETWEEN_BUY=230
    ;;
  cal | calibrate)
    echo "Calibration Mode"
    CALIBRATION_MODE=1
    ;;
  c | cookieonly | *)
    COOKIE_ONLY=1
    echo "Clicking Cookie Only!"
    ;;
esac

# GUI Pixel stuff
# eval gets us WINDOW,X,Y,WIDTH,HEIGHT
eval $(xdotool search --name "s - Cookie" getwindowgeometry --shell)

CONFIG_FILE=.window_${X}x${Y}.conf

CLICK_DELAY=35
CLICK_SLEEP=$(echo "scale=3; $CLICK_DELAY/1000" | bc)
TOP_LEFT=()
readConfig() {
  while read var x y; do
    eval "${var}=($x $y)"
  done < $CONFIG_FILE
  
  SPACE_BETWEEN_BUTTONS="${BUTTON_SPACE[1]}"
}
readConfig
moveAndClick() { xdotool mousemove --window $WINDOW $1 $2 click --delay 1 1; }
moveTo() { xdotool mousemove --window $WINDOW $1 $2; }
moveToCookie() { moveTo ${COOKIE[@]}; }
scrollMenuTop() { moveTo ${CURSOR_BUTTON[@]}; doClick 12 4; }
buyUpgrade() { moveAndClick ${UPGRADE_ICON[@]}; }
clickBuy() { moveAndClick ${BUY_BUTTON[@]}; }
click100() { moveAndClick ${B100_BUTTON[@]}; }
click10() { moveAndClick ${B10_BUTTON[@]}; }
click1() { moveAndClick ${B1_BUTTON[@]}; }
clickSell() { moveAndClick ${SELL_BUTTON[@]}; }
clickBuy100() { clickBuy; click100; }
clickSellAll() { clickSell; moveAndClick ${SELL_ALL_BUTTON[@]}; }
clickNewsTicker() { moveAndClick ${NEWS_TICKER[@]}; }
muteWizard() { 
  if [[ $COOKIE_ONLY ]]; then
    return
  fi
  moveAndClick ${WIZARD_MUTE[@]}
}

sellBuildingBonus() {
  if ! [[ $CLICKBONUS_MODE ]]; then
    return
  fi
  # *100
  local buyNum=$1
  scrollMenuTop

  clickSellAll
  clickButtonXFromCursorButton 3 1
  
  clickBuy100
  clickButtonXFromCursorButton 3 $buyNum
}

clickButtonXFromCursorButton() {
  # need menu to be scrolled to top
  # $1=0 = CURSOR_BUTTON
  local button=$1
  local clickTimes=$2
  #mostly used to buy and sell Mine, Factory, and Bank

  local x=${CURSOR_BUTTON[0]}
  local y=$((${CURSOR_BUTTON[1]}+($1*$SPACE_BETWEEN_BUTTONS)))
  moveTo $x $y
  doClick $clickTimes
}

clickEachBuy() {
  local x=${BUY_ICON_TOP[0]}
  local y=${BUY_ICON_TOP[1]}
  local bottom_y=${LAST_BUTTON[1]}
  local direction=-1
  local items=$(echo "scale=2;(${bottom_y}-${y})/${SPACE_BETWEEN_BUTTONS}" | bc)
  items=$(printf "%.0f" $items)
  if [[ $direction -lt 0 ]]; then
    y=$((y+items*SPACE_BETWEEN_BUTTONS))
  fi
  for i in $(eval echo "{0..$items}")
  do
    moveTo $x $y
    ((y+=SPACE_BETWEEN_BUTTONS*direction))
    sleep $CLICK_SLEEP
  done
}
findGoldCookies() {
  if [[ $FORTUNE_MODE -eq 0 ]]; then
    return
  fi
  
  local start_x=$((${TOP_LEFT[0]}+50))
  start_x="${TOP_MIDDLE_BAR[0]}"
  local start_y="${TOP_MIDDLE_BAR[1]}"
  local x_jumps=$(((BOTTOM_RIGHT[0]-start_x)/14))
  local y_jumps=$(((BOTTOM_RIGHT[1]-start_y)/14))

  #click a 10x10 grid
  for y in {0..14}
  do
    for x in {0..14}
    do
     moveAndClick $((start_x+x*x_jumps)) $((start_y+y*y_jumps))
     sleep .01
    done
  done
  moveToCookie
}

startSequence () {
  counter=5
  #echo "Click Cookie Clicker Window..."
  while [ $counter -ne 0 ]
  do
    printf {"\rStarting Clicking in ... %-2d",$counter}
    ((counter--))
    sleep 1
  done
}

cookieOffset=20
cookieOffsetDir=6
cookieAnimationHold=0
cookieAnimationHoldFrames=0
clickCookie() {
  local offset=60
  local x=${COOKIE[0]}
  local y=${COOKIE[1]}
  if [[ $COOKIE_ONLY ]]; then doClick; return;
  fi;

  ((x+=cookieOffset))
  ((y+=50))
  moveAndClick $x $y
  if [[ $cookieAnimationHold -eq 1 ]] && [[ $cookieAnimationHoldFrames -gt 0 ]]; then
    ((cookieAnimationHoldFrames-=1))
  else
    ((cookieOffset+=cookieOffsetDir))
    if [[ $cookieOffset -gt $offset ]] || [[ $cookieOffset -lt $((-1*offset)) ]]; then
      cookieOffsetDir=$((cookieOffsetDir*-1))
      cookieAnimationHold=1
      cookieAnimationHoldFrames=5
    fi
  fi
}

doClick () {
  # doClick REPEAT_INT MOUSE_BUTTON_INT
  local mouse_button=1
  if [[ $2 -gt 1 ]]; then mouse_button=$2
  fi
  if [[ $1 -gt 1 ]]; then
    xdotool click --repeat $1 --delay $CLICK_DELAY $mouse_button
  else
    xdotool click --delay 1 $mouse_button 
  fi
}

doBuy() {
  if ! [[ $DOBUY_MODE ]]; then
    return
  fi
  
  if [[ $((counter%CLICKS_BETWEEN_BUY)) -eq 0 ]]; then
    if [[ $BUY_UPGRADE ]]; then
      buyUpgrade
    fi
  fi
  
  if [[ $((counter%CLICKS_BETWEEN_BUY*10)) -eq 0 ]]; then
    clickEachBuy
  fi
}

sleep .1
counter=1
muteWizard
sellBuildingBonus $BONUS_BUY_NUM
moveToCookie
while [ 1 ]
do 
  if [[ $((counter%CLICKS_BETWEEN_BUY)) -eq 0 ]]; then
    doBuy
    clickNewsTicker
    findGoldCookies
    sellBuildingBonus $BONUS_BUY_NUM
  fi
  clickCookie
  ((counter++))
  printf {"\rClicks:\t%d\nCookies:%'d %s\033[1A",$counter,$((counter*COOKIES_PER_CLICK)),$COOKIE_VERB} 
  sleep $CLICK_SLEEP
done
