#!/bin/bash

# Variables
REPO_URL="https://github.com/evlar/Qsync.git"
REPO_DIR="Qsync"

# Install Git and tmux (example for Ubuntu/Debian)
sudo apt-get update
sudo apt-get install -y git tmux

# Clone the repository
git clone $REPO_URL

# Change to the repository directory
cd $REPO_DIR

# Make the install script executable and run it
chmod +x install.sh
./install.sh