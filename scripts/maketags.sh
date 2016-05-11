#! /bin/bash

if [ $# -lt 1 ]; then
    echo "Please specify processor type"
    exit 1
fi

iofile_path=$(echo "#include <avr/io.h>" | avr-gcc -E -mmcu=$1 - | egrep '"[^"]*include/avr/io[^"]+.h"' -o | tr -d '"' | sort -u)
include_dir=$(dirname $(dirname $iofile_path))
iofile=$(basename $iofile_path)
all_files=$(echo $include_dir/* $include_dir/avr/{[a-h]*,i[^o]*,[j-z]*,io.h,$iofile})
ctags ${all_files}

