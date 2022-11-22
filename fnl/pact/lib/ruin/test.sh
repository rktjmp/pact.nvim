#!/usr/bin/env bash

if [[ -n $1 ]]; then
  tests=( $1 )
else
  tests=(fn let enum type either maybe result iter debug math)
fi

for f in "${tests[@]}"; do
  ./fennel.bin --correlate "$f/test-$f.fnl"
done
