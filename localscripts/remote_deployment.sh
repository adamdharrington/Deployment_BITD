#!/usr/bin/bash
# Adam Harrington - x13113305 - adamdharrington@gmail.com

echo "* Please enter the following remote environment variables: "

# get remote ip address from user input
echo "Address: "
read remote_address

# get remote username for $remote_address
echo "Username for $remote_address: "
read remote_username

# get remote username for $remote_address
echo "Password for $remote_username for $remote_address: "
read -s remote_password

# get database password
echo "Database Password: "
read -s DB_password

echo ""
echo "**********************"
echo "Signing into $remote_address as $remote_username"
# Use SCP to send a deployment management 
# script to remote machine
scp manage_deployment.sh $remote_username@$remote_address:/tmp/
echo ""
echo "**********************"
echo "Beginning remote deployment"
# Use SSH to execute deployment management 
# script on remote machine
echo "$remote_password" | ssh -t $remote_address -l$remote_username "sudo -S bash /tmp/manage_deployment.sh '$remote_password' '$DB_password'"
echo ""
echo "**********************"
echo "Successful deployment"
echo "Cleanup remote environment..."
# Use SSH to remove the deployment management 
# script from remote machine
echo "$remote_password" | ssh -t $remote_address -l$remote_username "sudo -S rm /tmp/manage_deployment.sh"
echo ""
echo "**********************"
echo "Remote environment cleaned up"