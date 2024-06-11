#!/bin/bash

# Variables
REPO_URL="https://github.com/evlar/Qsync.git"
REPO_DIR="Qsync"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if SSH client is installed
if ! command_exists ssh; then
    echo "SSH client not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y openssh-client
else
    echo "SSH client is already installed."
fi

# Check if nano editor is installed
if ! command_exists nano; then
    echo "Nano editor not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y nano
else
    echo "Nano editor is already installed."
fi

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
