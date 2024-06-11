#!/bin/bash

echo "Starting sync_setup.sh"

# Define the base directory
BASE_DIR="$HOME/Qsync"
NODES_FILE="$BASE_DIR/nodes.txt"

# Ensure necessary directories exist
mkdir -p $BASE_DIR/store_backups
mkdir -p $BASE_DIR/sync_logs

# Make the main sync script executable
chmod +x sync_all.sh
