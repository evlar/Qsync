#!/bin/bash

# Variables
REPO_URL="https://github.com/evlar/Qsync.git"
REPO_DIR="$HOME/Qsync"

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

# Check if Git is installed
if ! command_exists git; then
    echo "Git not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y git
else
    echo "Git is already installed."
fi

# Check if tmux is installed
if ! command_exists tmux; then
    echo "tmux not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y tmux
else
    echo "tmux is already installed."
fi

# Install and configure UFW
if ! command_exists ufw; then
    echo "UFW not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y ufw
fi

echo "Configuring UFW to allow SSH connections..."
sudo ufw allow 22/tcp
sudo ufw enable

# Clone the repository if it doesn't exist
if [ -d "$REPO_DIR" ]; then
    echo "$REPO_DIR already exists. Using the existing directory."
else
    git clone $REPO_URL $REPO_DIR
fi

# Change to the repository directory
cd $REPO_DIR

# Ensure necessary directories exist
mkdir -p $REPO_DIR/store_backups
mkdir -p $REPO_DIR/sync_logs

# Make the scripts executable
chmod +x sync_all.sh
chmod +x passwordless_ssh.sh

# Optionally, run any additional setup scripts
# ./sync_setup.sh

echo "Setup complete."
