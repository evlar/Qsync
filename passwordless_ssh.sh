#!/bin/bash

# Path to the SSH key pair
SSH_KEY="$HOME/.ssh/id_ed25519_quil"
SSH_KEY_PUB="${SSH_KEY}.pub"

# File containing VPS labels, usernames, and IP addresses
NODES_FILE="$HOME/Qsync/nodes.txt"

# Check if the SSH key exists, create it if it doesn't
if [ ! -f "$SSH_KEY" ]; then
    echo "SSH key not found. Creating a new SSH key pair..."
    ssh-keygen -t ed25519 -f "$SSH_KEY" -N ""
fi

# Function to check if the host key is already in known_hosts
check_known_hosts() {
    VPS_IP=$1
    ssh-keygen -F "$VPS_IP" > /dev/null
    return $?
}

# Function to add host key to known_hosts
add_host_key() {
    VPS_IP=$1
    echo "Adding host key for $VPS_IP to known_hosts"
    ssh-keyscan -H "$VPS_IP" >> ~/.ssh/known_hosts
}

# Function to set up passwordless SSH for a single VPS
setup_passwordless_ssh() {
    VPS_LABEL=$1
    VPS_USER_IP=$2
    VPS_IP=$(echo $VPS_USER_IP | awk -F@ '{print $2}')
    
    echo "Setting up passwordless SSH for $VPS_USER_IP (Label: $VPS_LABEL)"

    # Check if host key is known
    if ! check_known_hosts $VPS_IP; then
        add_host_key $VPS_IP
    fi

    if [ "$ALL_SAME_PASSWORD" == "y" ]; then
        PASSWORD=$COMMON_PASSWORD
    else
        echo "Enter the password for $VPS_USER_IP:"
        read -s PASSWORD
    fi

    # Use sshpass to automate the password input for ssh-copy-id
    sshpass -p "$PASSWORD" ssh-copy-id -i $SSH_KEY_PUB $VPS_USER_IP
}

# Prompt if all VPS instances share the same password
echo "Do all VPS instances share the same password? (y/n)"
read ALL_SAME_PASSWORD

if [ "$ALL_SAME_PASSWORD" == "y" ]; then
    echo "Enter the common password for all VPS instances:"
    read -s COMMON_PASSWORD
fi

# Iterate over each VPS label, user@IP and set up passwordless SSH
while IFS= read -r NODE; do
    LABEL=$(echo "$NODE" | awk '{print $1}')
    USER_IP=$(echo "$NODE" | awk '{print $2}')
    setup_passwordless_ssh $LABEL $USER_IP
done < $NODES_FILE

echo "Passwordless SSH setup completed for all VPS instances."
