#!/bin/bash

# Function to check if the script is running inside a tmux session
ensure_tmux_session() {
    if [ -z "$TMUX" ]; then
        echo "Not running inside a tmux session. Starting a new tmux session..."
        tmux new-session -d -s sync_session "bash $0"
        tmux attach-session -t sync_session
        exit 0
    fi
}

ensure_tmux_session

## Variables
NODES_FILE="$HOME/Qsync/nodes.txt"
REMOTE_DIR="~/ceremonyclient/node/.config"
LOCAL_DIR_BASE="$HOME/Qsync/store_backups"
SSH_PORT=22
SSH_KEY="$HOME/.ssh/id_ed25519_quil"
SLEEP_INTERVAL=1800
RETRY_LIMIT=3
LOG_DIR="$HOME/Qsync/sync_logs"

mkdir -p $LOG_DIR

mapfile -t NODES < "$NODES_FILE"

sync_node() {
    LABEL=$1
    ADDRESS=$2
    RETRY_COUNT=0
    NODE_LOG_FILE="${LOG_DIR}/sync_log_${LABEL}.txt"

    LOCAL_DIR="${LOCAL_DIR_BASE}/${LABEL}"
    mkdir -p "${LOCAL_DIR}"

    ssh -i ${SSH_KEY} -p ${SSH_PORT} -o StrictHostKeyChecking=no ${ADDRESS} 'command -v rsync >/dev/null 2>&1 || { sudo apt-get update && sudo apt-get install -y rsync; }' | tee -a $NODE_LOG_FILE

    while [ $RETRY_COUNT -lt $RETRY_LIMIT ]; do
        echo "$(date): Starting sync for ${ADDRESS} to ${LOCAL_DIR}" | tee -a $NODE_LOG_FILE
        ionice -c2 -n7 nice -n19 rsync -avz --partial --inplace --progress --bwlimit=1000 -e "ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no -p ${SSH_PORT}" ${ADDRESS}:${REMOTE_DIR}/ ${LOCAL_DIR}/.config/ | tee -a $NODE_LOG_FILE
        if [ $? -eq 0 ]; then
            echo "$(date): Sync completed for ${ADDRESS}" | tee -a $NODE_LOG_FILE
            echo "Contents of ${LOCAL_DIR}/.config/:" | tee -a $NODE_LOG_FILE
            ls -a ${LOCAL_DIR}/.config/ | tee -a $NODE_LOG_FILE
            break
        else
            echo "$(date): Sync failed for ${ADDRESS} on attempt $((RETRY_COUNT + 1))" | tee -a $NODE_LOG_FILE
            tail -n 10 $NODE_LOG_FILE | grep -i "error" >> $NODE_LOG_FILE
            RETRY_COUNT=$((RETRY_COUNT + 1))
            if [ $RETRY_COUNT -lt $RETRY_LIMIT ]; then
                echo "$(date): Retrying sync for ${ADDRESS} ($RETRY_COUNT/$RETRY_LIMIT)" | tee -a $NODE_LOG_FILE
                sleep 5
            fi
        fi
    done

    if [ $RETRY_COUNT -eq $RETRY_LIMIT ]; then
        echo "$(date): Sync permanently failed for ${ADDRESS} after $RETRY_LIMIT attempts" | tee -a $NODE_LOG_FILE
    fi
}

progress_bar() {
    local progress=$1
    local total=$2
    local width=50
    local percent=$((progress * 100 / total))
    local completed=$((progress * width / total))
    local left=$((width - completed))

    printf "\rProgress: ["
    for ((i=0; i<completed; i++)); do
        printf "#"
    done
    for ((i=0; i<left; i++)); do
        printf " "
    done
    printf "] %d%% (%d/%d)" $percent $progress $total
}

while true; do
    start_time=$(date +%s)
    echo "$(date): Starting sync cycle"

    total_nodes=${#NODES[@]}
    completed_nodes=0

    for NODE in "${NODES[@]}"; do
        LABEL=$(echo "$NODE" | awk '{print $1}')
        ADDRESS=$(echo "$NODE" | awk '{print $2}')

        sync_node "${LABEL}" "${ADDRESS}"

        ((completed_nodes++))
        progress_bar $completed_nodes $total_nodes
    done

    wait

    end_time=$(date +%s)
    duration=$((end_time - start_time))

    echo
    echo "$(date): All sync operations completed"
    echo "Sync cycle took $(($duration / 60)) minutes and $(($duration % 60)) seconds."

    echo "Next sync in:"
    for ((i=SLEEP_INTERVAL; i>0; i--)); do
        printf "\r%02d:%02d" $((i/60)) $((i%60))
        sleep 1
    done
    echo

done
