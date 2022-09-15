#!/bin/bash
#Copyright 2022. Uecker Lab. University Medical Center Göttingen.
set -eu
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )
source ../init.sh

for d in ./*/
do
(
	cd $d
	rm *.hdr || true
	rm *.hdr || true
)
CONFIG_DIR=$d make -fmodl.mk
done

wait