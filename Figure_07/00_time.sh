log_gpu()
(
    CMD=$1
    LOG=$2

    set -eux

    if [ "drad-ue-rado" = "$(uname -n)" ]; then
    id=$((CUDA_VISIBLE_DEVICES+1))
    else
    id=${CUDA_VISIBLE_DEVICES}
    fi

    date=$(date '+%Y_%m_%d_%H_%M_%S')
    gpu=$(nvidia-smi --id=${id} --query-gpu=name --format=csv,noheader)
    gpu=$(echo ${gpu// /-})

    LOG=${LOG}_${gpu}_${date}

    nvidia-smi --id=${id} --query-gpu=timestamp,name,pci.bus_id,driver_version,pstate,pcie.link.gen.max,pcie.link.gen.current,temperature.gpu,utilization.gpu,utilization.memory,memory.total,memory.free,memory.used --format=csv --loop-ms=1000 >${LOG}_gpu.log &
    PID=$!

    #{ nvprof --unified-memory-profiling off bash -c "$CMD" >> $LOG.log; } 2>> $LOG.log
    { time bash -c "$CMD" >> $LOG.log; } 2>> $LOG.log

    kill $PID
)

log_gpu_time()
(
    CMD=$1
    LOG=$2

    set -eux

    if [ "drad-ue-rado" = "$(uname -n)" ]; then
    id=$((CUDA_VISIBLE_DEVICES+1))
    else
    id=${CUDA_VISIBLE_DEVICES}
    fi

    date=$(date '+%Y_%m_%d_%H_%M_%S')
    gpu=$(nvidia-smi --id=${id} --query-gpu=name --format=csv,noheader)
    gpu=$(echo ${gpu// /-})

    LOG=${LOG}_${gpu}_${date}

    nvidia-smi --id=${id} --query-gpu=timestamp,name,pci.bus_id,driver_version,pstate,pcie.link.gen.max,pcie.link.gen.current,temperature.gpu,utilization.gpu,utilization.memory,memory.total,memory.free,memory.used --format=csv --loop-ms=1000 >${LOG}_gpu.log &
    PID=$!

    #{ nvprof --unified-memory-profiling off bash -c "$CMD" >> $LOG.log; } 2>> $LOG.log
    { time bash -c "$CMD" >> $LOG.log; } 2>> $LOG.log
    nsys profile --stats=true bash -c "$CMD" >> ${LOG}_nvprof.log;
    
    kill $PID
)