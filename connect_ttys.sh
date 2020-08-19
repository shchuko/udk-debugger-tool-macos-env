#!/bin/bash

if [[ "$#" -ne 2 ]]; then
	echo "Wrong args"
	echo "Usage: ./connect_ttys.sh /dev/ttys004 /dev/ttys005"
	exit 1
fi

TTY_FIRST="$1"
TTY_SECOND="$2"

sudo socat "$TTY_FIRST",rawer,ispeed=115200,ospeed=115200 "$TTY_SECOND",rawer,ispeed=115200,ospeed=115200

