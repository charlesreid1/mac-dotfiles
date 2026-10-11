#!/bin/bash

# Diff every file bootstrap.sh would copy into ~. The list comes from an rsync
# dry run with the same exclude list, so the two scripts always agree.
EMPTY_DIR=$(mktemp -d)
for file in $(rsync -an --exclude-from "bootstrap_exclude.txt" --out-format "%n" . "${EMPTY_DIR}/" | grep -v '/$'); do
    if [[ -f ~/$file ]]; then
        echo "------------"
        echo "$file exists in home directory, calculating diff..."
        $(which git) diff --no-index --exit-code ~/$file $file && echo "No differences in $file!"
        # order is important - home file first, shows changes to be deleted in red
    fi
done
rmdir "${EMPTY_DIR}"
