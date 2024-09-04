#!/bin/bash

# THIS SCRIPT IS DEPENDENT ON: 'health-check.ssh' BOTH SCRIPTS SHOULD BE IN THE SAME FOLDER IN ORDER TO RUN IT

# Function to execute a command on a remote server using SSH config
function execute_on_server() {
  ssh -F ~/.ssh/ssh_config "$1" "health-check.sh"
}

# Array of server config names
servers=("server1" "server2" "server3")

# Loop through each server and execute the command
for server in "${servers[@]}"; do
  echo -e "\n\n** Server: $server **\n"

  # Execute the command on the server
  execute_on_server "$server" "health-check.sh"
done

