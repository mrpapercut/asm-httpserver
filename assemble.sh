#!/bin/bash

for f in `find . -name '*.s'`; do
    filename=$(echo "$f" | sed 's/\.\/\(.*\)\.s/\1/')

    as -o $filename.o $filename.s
done

readarray -d '' objectfiles < <(find . -name '*.o' -print0)
args=()

for i in "${objectfiles[@]}"; do
    args+=("$i")
done

ld -o server "${args[@]}"
