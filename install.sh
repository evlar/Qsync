#!/bin/bash

# Variables
REPO_URL="https://github.com/evlar/Qsync.git"
INSTALL_DIR="$HOME/Qsync"

# Check if the directory already exists
if [ -d "$INSTALL_DIR" ]; then
    echo "$INSTALL_DIR already exists. Using the existing directory."
else
    # Clone the repository
    git clone $REPO_URL $INSTALL_DIR
fi

# Change to the repository directory
cd $INSTALL_DIR

# Make the setup script executable
chmod +x sync_setup.sh

# Run the setup script
./sync_setup.sh