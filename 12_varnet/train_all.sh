#!/bin/bash
set -eu
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )

for d in ./*/
do
CONFIG_DIR=$d make -fvarnet.mk
done

wait