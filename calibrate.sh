#!/usr/bin/env bash

# Get Window Info - WINDOW, X, Y, WIDTH, HEIGHT, SCREEN
# My sytem reports all 3 monitors as one large screen
eval $(xdotool search --name "s - Cookie Clicker - " getwindowgeometry --shell)
GLOBAL_WINDOW=$WINDOW
GLOBAL_X=$X
GLOBAL_Y=$Y
GLOBAL_WIDTH=$WIDTH
GLOBAL_HEIGHT=$HEIGHT

CONFIG_FILE=.window_${X}x${Y}.conf
waitForClick() {
  if [[ $1 -eq 0 ]]; then
    local button=1
  else
    local button=$1
  fi
  #xinput test-xi2 --root 2 | awk 'BEGIN { count=0 } /16 \(RawButtonRelease\)/ { exit }'0;
  local release=0
  xinput test-xi2 --root 2 | while read -r p1 p2 p3 p4; do
  if [[ "$p4" == "(RawButtonRelease)" ]]; then
      release=1
  fi
  if [[ $release -eq 1 ]] && \
     [[ "$p1" == "detail:" ]] && \
     [[ $p2 -eq $button ]]; then
    echo "(Move Mouse)"
    break
  fi
  done
  eval $(xdotool getmouselocation --shell)
  X=$((X-GLOBAL_X))
  Y=$((Y-GLOBAL_Y))
}

getRelativeMousePos() {
  clear
  printf "$1\n"
  waitForClick $2
  clear
}

writeConfig() {
  echo $1 $X $Y >> $CONFIG_FILE
}

deleteConfig() {
  rm $CONFIG_FILE
}

printArray() {
  # USE: printArray ${TOP_LEFT[@]}
  echo "$@"
}

printConfig() {
  printf "$CONFIG_FILE\n"
  cat $CONFIG_FILE | while read -r line; do
   printf "\t$line\n"
 done
}

getRelMousePosPrintExit() {
  getRelativeMousePos "Right Click the position you want to know the relative position of." 3
  echo $X $Y
  exit
}

doAddToConfig() {
  clear
  echo Adding $addToConfig to $CONFIG_FILE
  echo Waiting for Relative Mouse Position
  getRelativeMousePos "Right Click the area to add to the config" 3
  writeConfig $addToConfig $X $Y
  printConfig
  exit
}

parseArgs() {
  # just in case we call this twice make OPTIND local
  local OPTIND OPT

  die() { echo "$*" >&2; exit 2; }  # complain to STDERR and exit with error
  needs_arg() { if [ -z "$OPTARG" ]; then die "No arg for --$OPT option"; fi; }

  # Defaults (to be thorough, you could also assign alpha="" and charlie="")
  bravo="$HOME/Downloads"       # Overridden by the value set by -b or --bravo
  charlie_default="brown"       # Only set given -c or --charlie without an arg
  
  while getopts ab:c-: OPT; do  # allow -a, -b with arg, -c, and -- "with arg"
    # support long options: https://stackoverflow.com/a/28466267/519360
    if [ "$OPT" = "-" ]; then   # long option: reformulate OPT and OPTARG
      OPT="${OPTARG%%=*}"       # extract long option name
      OPTARG="${OPTARG#$OPT}"   # extract long option argument (may be empty)
      OPTARG="${OPTARG#=}"      # if long option argument, remove assigning `=`
    fi
    case "$OPT" in
      
      printRelMouseLocation ) getRelMousePosPrintExit ;;
      addToConfig )  needs_arg; addToConfig="$OPTARG" ;;
      b | bravo )    needs_arg; bravo="$OPTARG" ;;
      c | charlie )  charlie="${OPTARG:-$charlie_default}" ;;  # optional argument
      \? )           exit 2 ;;  # bad short option (error reported via getopts)
      * )            die "Illegal option --$OPT" ;;            # bad long option
    esac
  done
  shift $((OPTIND-1)) # remove parsed options and args from $@ list
}

#SO WE APPEND TO NEW FILE
#deleteConfig
parseArgs "$@"
if [[ $addToConfig  ]]; then doAddToConfig
fi
exit

getRelativeMousePos "Please 'Mute' all Middle areas\n\tMiddle Click to Continue" 2
getRelativeMousePos "Click the Center of the Cookie"
writeConfig "COOKIE"

getRelativeMousePos "Click the top left Game Edge just below the bakery title"
writeConfig "TOP_LEFT"
TOP_LEFT=($X $Y)

getRelativeMousePos "Click the bottom right Game Edge"
writeConfig "BOTTOM_RIGHT"

getRelativeMousePos "Click the right Cookie border below the top middle bar"
writeConfig "TOP_MIDDLE_BAR"

getRelativeMousePos "Click the Wizard Icon"
writeConfig "WIZARD_ICON"

getRelativeMousePos "Click Wizard area 'Mute'"
writeConfig "WIZARD_MUTE"

getRelativeMousePos "Right Click Upgade Spot" 3
writeConfig "UPGRADE_ICON"

getRelativeMousePos "Right Click Top Buy Button" 3
writeConfig "BUY_ICON_TOP"
tmp_x=$X
tmp_y=$Y

getRelativeMousePos "Right Click Next Buy Button(second)" 3
X=$((X-tmp_x))
Y=$((Y-tmp_y))
writeConfig "BUTTON_SPACE"

getRelativeMousePos "Right Click Last(lowest) Buy Button" 3
writeConfig "LAST_BUTTON"

printConfig
