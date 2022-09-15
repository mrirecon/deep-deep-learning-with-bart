#!/bin/bash
#Copyright 2022. Uecker Lab. University Medical Center Göttingen.
set -eu
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )
source ../init.sh

cd $REPO/00_data/
download https://zenodo.org/record/7002209/files/example_data.zip example_data.zip
unzip -n example_data.zip

cd $REPO/Figure_07/
download https://zenodo.org/record/7002209/files/timing_logs.zip timing_logs.zip
unzip -n timing_logs.zip