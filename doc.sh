#!/usr/bin/env bash

if [[ -n $1 ]]; then
  dirs=( $1 )
else
  dirs=(fn let enum type monad either maybe result use iter debug math)
fi

for f in "${dirs[@]}"; do
  rm "$f/README.md"
  echo "# ruin/$f" >> "$f/README.md"
  echo "" >> "$f/README.md"

  if [[ -e "$f/head.md" ]]; then
    cat "$f/head.md" >> "$f/README.md"
    echo "" >> "$f/README.md"
  fi

  if [[ -e "$f/init.fnl" ]]; then
    echo "- **[functions](#initfnl)**" >> "$f/README.md"
  fi
  if [[ -e "$f/init-macros.fnl" ]]; then
    echo "- **[macros](#init-macrosfnl)**" >> "$f/README.md"
  fi
  echo "- **[tests](#tests)**" >> "$f/README.md"

  if [[ -e "$f/init.fnl" ]]; then
    ./fenneldoc.bin --out-dir . "$f/init.fnl"
    cat "$f/init.md" >> "$f/README.md"
    rm "$f/init.md"
  fi

  if [[ -e "$f/init-macros.fnl" ]]; then
    ./fenneldoc.bin --out-dir . "$f/init-macros.fnl"
    cat "$f/init-macros.md" >> "$f/README.md"
    rm "$f/init-macros.md"
  fi

  echo "" >> "$f/README.md"
  echo "# tests" >> "$f/README.md"
  echo "\`\`\`" >> "$f/README.md"
  ./test.sh $f | sed -e 's/\x1b\[[0-9;]*m//g' >> "$f/README.md"
  echo "\`\`\`" >> "$f/README.md"
done
