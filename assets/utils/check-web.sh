#!/bin/bash

DURATION=$(</dev/stdin)
if (($DURATION <= 5000)); then
    exit 60
else
    if curl --silent --fail sensei.embassy:5401 &>/dev/null; then
        echo "Sensei UI is unreachable" >&2
        exit 1
    fi
fi