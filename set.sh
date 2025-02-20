#!/bin/bash
set -e

failure () {
    echo "failed at $1:$2"
}

trap 'failure "${LINENO}" "$BASH_COMMAND" ' ERR

echo "helo world"
echooo "helo world"

echo "helo world"

