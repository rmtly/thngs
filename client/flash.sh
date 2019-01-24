#!/bin/bash
ERR='\033[1;31m'
WARN='\033[1;33m'
OK='\033[1;32m'
NC='\033[0m'

DEBUG=${FLASH_DEBUG:-false}
BAUD=115200
RESTART_NODEMCU=true
POST_RESTART_DELAY=2
PRE_RESTART_DELAY=1
START_SCREEN=${START_SCREEN:-true}
tty="${LUATOOL_DEV:-/dev/tty.usbserial-1440}"
SCREEN_CMD="screen $tty $BAUD"
LUATOOL="../luatool"
RESTART_LUA="../restart.lua"

if [ $# -ne 0 ]; then
    if [ "$1" == "-h" ]; then
        echo 1>&2 "Usage: $0"
        echo 1>&2 "   Flashes all lua files in current dir, and generic files from 'mqtt' dir"
        exit
    elif [ "$1" == "-s" ]; then
        START_SCREEN=false
    fi

    files="$*"
fi

# remember dir we were called from
wd=$PWD
# change to dir with script (some files are relative to this dir)
sd="`dirname $0`/mqtt"
cd "$sd" || {
    echo -e 1>&2 "$0: $ERR[FAILED ]$NC Unable to change to script dir '$sd'; exiting..."
    exit 10
}

# config
blank="../blank/init.lua"
init_lua="../init.lua"
scripts="config wifi init main post secrets"
app_scripts="pre config_app app"
blank_retry_sleep=0.25

# lib
function restart_nodemcu {
    if $RESTART_NODEMCU; then
        echo "$0: [RESTART] $tty"
        $LUATOOL -d "$RESTART_LUA" &>/dev/null
        sleep $POST_RESTART_DELAY
    fi
}

function send_file {
    echo "$0: [SEND   ] $1"
    if $DEBUG; then
        $LUATOOL "$1"
        ret=$?
    else
        $LUATOOL "$1" &>/dev/null
        ret=$?
    fi
    if [ $ret -eq 0 ]; then
        echo "$0: [SENT   ] $1"
    else
        echo -e "$0: $WARN[FAILED ]$NC Failed to send '$1' ($ret)"
    fi
    return $ret
}

# flash blank init first, to break any reboot loops
restart_nodemcu
num_retries=10
tries=1
while [[ $tries -le $num_retries ]]; do
    echo "$0: [BLANK  ] $tries/$num_retries"
    send_file "$PWD/$blank" && {
        break
    } || {
        echo -e "$0: $WARN[FAILED ]$NC Flash failed. Trying again after $blank_retry_sleep seconds..."
        sleep "$blank_retry_sleep"
    }
    let tries++
done

if [[ $tries -gt $num_retries ]]; then
    echo 1>&2 -e "$0: $ERR[FAILED ]$NC Unable to flash blank init.lua; aborting..."
    exit 11
else
    echo -e "$0: $OK[BLANKED]$NC"
fi

restart_nodemcu

if [ -n "$files" ]; then
    echo -e "$0: [FLASH  ] $files"
    sleep $blank_retry_sleep
    for file in $files; do
        filename="$wd/$file"
        send_file "$filename" || {
            echo 1>&2 -e "$0: $ERR[FAILED ]$NC Unable to flash $filename; aborting..."
            exit 13
        }
    done
    send_file "$init_lua"
else
    echo -e "$0: [FLASH  ] $scripts $app_scripts"
    sleep $blank_retry_sleep
    for file in $scripts $app_scripts; do
        filename="$wd/$file".lua
        if ! [ -f "$filename" ] && [[ $filename == */* ]]; then
            filename="$wd/../mqtt/$file".lua
            if ! [ -f "$filename" ] && [[ $filename == */* ]]; then
                filename="$wd/../$file".lua
                if ! [ -f "$filename" ]; then
                    echo -e "$0: $WARN[MISSING]$NC $filename"
                    continue
                fi
            fi
        fi
        send_file "$filename" || {
            echo 1>&2 -e "$0: $ERR[FAILED ]$NC Unable to flash $filename; aborting..."
            exit 13
        }
    done
fi
echo -e "$0: $OK[FLASHED]$NC"

sleep $PRE_RESTART_DELAY
restart_nodemcu

echo -e "$0: $OK[SUCCESS]$NC"
if $START_SCREEN; then
    $SCREEN_CMD
fi
