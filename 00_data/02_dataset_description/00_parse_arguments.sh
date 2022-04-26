
apply_trj=${apply_trj:=}
apply_pat=${apply_pat:=}
apply_ksp=${apply_ksp:=}
apply_col=${apply_col:=}
apply_out=${apply_out:=}

train_trj=${train_trj:=}
train_pat=${train_pat:=}
train_ksp=${train_ksp:=}
train_col=${train_col:=}
train_ref=${train_ref:=}

eval_trj=${eval_trj:=}
eval_pat=${eval_pat:=}
eval_ksp=${eval_ksp:=}
eval_col=${eval_col:=}
eval_ref=${eval_ref:=}

valid_trj=${valid_trj:=}
valid_pat=${valid_pat:=}
valid_ksp=${valid_ksp:=}
valid_col=${valid_col:=}
valid_ref=${valid_ref:=}


apply_files=""
if [ -n "$apply_trj" ]; then apply_files+=" --trajectory=$apply_trj"; fi
if [ -n "$apply_pat" ]; then apply_files+=" --pattern=$apply_pat"; fi

apply_files="$apply_files $apply_ksp $apply_col $weights $apply_out"

eval_files=""
if [ -n "$eval_trj" ]; then eval_files+=" --trajectory=$eval_trj"; fi
if [ -n "$eval_pat" ]; then eval_files+=" --pattern=$eval_pat"; fi

eval_files="$eval_files $eval_ksp $eval_col $weights $eval_ref"

train_files=""
if [ -n "$train_trj" ]; then train_files+=" --trajectory=$train_trj"; fi
if [ -n "$train_pat" ]; then train_files+=" --pattern=$train_pat"; fi

train_files="$train_files $train_ksp $train_col $weights $train_ref"

valid_files=""
if [ -n "$valid_ksp" ]; then

    valid_files=" --valid-data k=$valid_ksp"
    valid_files+=" --valid-data c=$valid_col"
    valid_files+=" --valid-data r=$valid_ref"

    if [ -n "$valid_trj" ]; then valid_files+=" --valid-data t=$valid_trj"; fi
    if [ -n "$valid_pat" ]; then valid_files+=" --valid-data p=$valid_pat"; fi
fi
