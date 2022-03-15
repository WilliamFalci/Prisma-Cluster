#!/bin/bash
TBOLD=$(tput bold)
TREGULAR=$(tput sgr0)

TCBLACK=$(tput setaf 0)
TCRED=$(tput setaf 1)
TCGREEN=$(tput setaf 2)
TCYELLOW=$(tput setaf 3)
TCBLUE=$(tput setaf 4)
TCMAGENTA=$(tput setaf 5)
TCCYAN=$(tput setaf 6)
TCWHITE=$(tput setaf 7)
TCPURPLE=$(tput setaf 12345)

print_message(){
  icon=''           #-i
  error=''          #-e
  module=''         #-m
  service=''        #-s
  command=''        #-c
  action=''         #-a
  text=''           #-t
  warning=''        #-w

  last=''

  while getopts i:e:w:m:s:c:a:t: flag 
  do
    case "${flag}" in
      i) 
        if [ "$OPTARG" == "start" ]; then 
          icon="$TCBLACK"'╔'"$TREGULAR "
        fi
        if [ "$OPTARG" == "continue" ]; then 
          icon="$TCBLACK"'╠'"$TREGULAR "
        fi
        if [ "$OPTARG" == "end" ]; then 
          icon="$TCBLACK"'╚>'"$TREGULAR "
          last="$TBOLD"
        fi
        ;;
      e) error="$TBOLD$TCRED"'ERROR!'"$TREGULAR"' ⇨ ';;
      w) warning="$TBOLD$TCYELLOW"'WARNING!'"$TREGULAR"' ⇨ ';;
      m) module="$TCBLUE${OPTARG}$TREGULAR"' ⇨ ' ;;
      s) service="$TCCYAN${OPTARG}$TREGULAR"' ⇨ ' ;;
      c) command="$TCMAGENTA${OPTARG}$TREGULAR"' ⇨ ' ;;
      a) action="$TCPURPLE${OPTARG}$TREGULAR"' ⇨ ' ;;
      t) text=${OPTARG};;
    esac
  done

  echo "$last""$icon""$error""$warning""$module""$service""$command""$action""$text""$TREGULAR"
}