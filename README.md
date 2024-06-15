
# Qsync Setup

This repository contains scripts and instructions to set up and manage multiple VPS instances for passwordless SSH access and synchronization. Follow the steps below to ensure all servers are properly configured.

## Installation Steps

### Step 1: Install Qsync

#### For Linux Users

1. **Open a Terminal**.

2. **Run the Setup Command**:
   ```sh
   wget -O - https://raw.githubusercontent.com/evlar/Qsync/main/setup.sh | bash
   ```

### Step 2: Set Up Passwordless SSH

Before running the synchronization script, you must set up passwordless SSH connections to all servers listed in `nodes.txt`.

#### Instructions for Setting Up Passwordless SSH

1. **Prepare `nodes.txt` File**:
   - Create a `nodes.txt` file with nano:
     ```sh
     nano $HOME/Qsync/nodes.txt
     ```
   - Use the arrow keys to navigate and edit the file.
   - To save your changes, press `Ctrl + O`, then press `Enter`.
   - To exit nano, press `Ctrl + X`.

   - List all your server addresses in the `nodes.txt` file in the format: `node_name username@ip_address`
   - Example:
     ```txt
     Q1 root@192.168.1.1
     Q2 root@192.168.1.2
     ```

3. **Run the Passwordless SSH Script**:
   - This script will configure passwordless SSH for each server listed in `nodes.txt`.
   - **Run the following command**:
     ```sh
     cd $HOME/Qsync && ./passwordless_ssh.sh
     ```

### Step 3: Synchronize Data Across Servers

Once the passwordless SSH connections are set up, you can synchronize data across all your servers.

1. **Run the Synchronization Script**:
   ```sh
   cd $HOME/Qsync && ./sync_all.sh
   ```

## Notes

- Ensure all server addresses and usernames are correctly listed in `nodes.txt` before running any scripts.
- The `sync_all.sh` script will only work after passwordless SSH is configured for all listed servers.
- `tmux` is required for running the scripts. The setup script will automatically open a `tmux` session unless one is already open.


