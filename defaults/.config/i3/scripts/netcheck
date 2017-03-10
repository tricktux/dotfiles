#!/bin/bash
#
# Author: Raphael P. Ribeiro <raphaelpr01@gmail.com> 

ISON=$(ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null && echo On || echo Off) # IS ON?
echo $ISON #full_text
echo $ISON #short_text
if [ "$ISON" = "Off" ]; then # no internet? color will turn red
    echo "#FF0000"
fi
