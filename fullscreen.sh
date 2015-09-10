#!/bin/bash
xTime=$(date +%s)
blockly=0
minecraft=0
while [ $(($(date +%s) - $xTime)) -le 10 ]
do
  if [ $(wmctrl -l | grep Minecraft | wc -l) -ne 0 ] && [ $minecraft -eq 0 ]
  then
    echo "in mc if"
    wmctrl -r "Minecraft" -b toggle,fullscreen
    minecraft=1
  fi

  if [ $(wmctrl -l | grep Blockly | wc -l) -ne 0 ] && [ $blockly -eq 0 ]
  then
    echo "in blockly if"
    wmctrl -r "Blockly" -b toggle,fullscreen
    blockly=1
  fi

  if [ $blockly -eq 1 ] && [ $minecraft -eq 1 ]
  then
    wmctrl -a "Minecraft"
    exit
  fi
done
