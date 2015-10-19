#Update /etc/hosts (list of known hosts)
echo '192.168.22.11    sandbar1 sandbar1 centos7' >> /etc/hosts
echo '192.168.22.12    sandbar2 sandbar2 centos7' >> /etc/hosts
echo '10.1.2.44       sandbar1 sandbar1 centos7' >> /etc/hosts
echo '10.1.2.45       sandbar2 sandbar2 centos7' >> /etc/hosts

node=$(hostname)
node=$(echo $node)
echo "$node is active. Generating SSH Tunnel."


#Create SSH keys on both nodes
if [[ $node = "sandbar1" ]]; then
   if [ ! -d "~/vagrant/.ssh" ]; then
       echo "Create SSH directory."
       sudo mkdir ~/vagrant/.ssh
   fi
   if [ ! -f "~/vagrant/.ssh/id_rsa1" ]; then
       echo "Generate SSH key."
       sudo ssh-keygen -t rsa <<EOF
~/vagrant/.ssh/id_rsa1


EOF
   fi
elif [[ $node = "sandbar2" ]]; then
   if [ ! -d "~/vagrant/.ssh" ]; then
       echo "Create SSH directory."
       sudo mkdir ~/vagrant/.ssh
   fi
   if [ ! -f "~/vagrant/.ssh/id_rsa2" ]; then
       echo "Create SSH directory."
       sudo ssh-keygen -t rsa <<EOF
~/vagrant/.ssh/id_rsa2


EOF
   fi
else
   echo "Node not found."
fi


# Copy SSH keypairs to each node
if [[ $node = "sandbar1" ]]; then
   if [ ! -d "/root/.ssh" ]; then
       echo "Create root SSH directory to allow public keys."
       sudo mkdir /root/.ssh
   fi
   if [ ! -f "/root/.ssh/authorized_keys" ]; then
       echo "Copy public keys into SSH directory."
       sudo cat ~/vagrant/.ssh/id_rsa1.pub >> /root/.ssh/authorized_keys
       sudo cat ~/vagrant/.ssh/id_rsa2.pub >> /root/.ssh/authorized_keys
   fi
   # Add sandbar2 to list of known hosts
   echo "Adding nodes to list of known hosts."
   sudo ssh-keyscan -t rsa 10.1.2.44 >> ~/.ssh/known_hosts
   sudo ssh-keyscan -t rsa 10.1.2.45 >> ~/.ssh/known_hosts
   # Disable strict host key checking
   echo "Disabling strict host key checking."
   echo "Host sandbar2" >> /etc/ssh/ssh_config
   echo "   Hostname 10.1.2.45" >> /etc/ssh/ssh_config
   echo "   StrictHostKeyChecking no" >> /etc/ssh/ssh_config
   echo "   UserKnownHostsFile=/dev/null" >> /etc/ssh/ssh_config
elif [[ $node = "sandbar2" ]]; then
   # Boot into sandbar2 and authorize public keys
   if [ ! -d "/root/.ssh" ]; then
       echo "Create root SSH directory to allow public keys."
       sudo mkdir /root/.ssh
   fi
   if [ ! -f "/root/.ssh/authorized_keys" ]; then
       sudo cat ~/vagrant/.ssh/id_rsa1.pub >> /root/.ssh/authorized_keys
       sudo cat ~/vagrant/.ssh/id_rsa2.pub >> /root/.ssh/authorized_keys
   fi
   # Disable strict host key checking
   echo "Host sandbar1" >> /etc/ssh/ssh_config
   echo "   Hostname 10.1.2.44" >> /etc/ssh/ssh_config
   echo "   StrictHostKeyChecking no" >> /etc/ssh/ssh_config
   echo "   UserKnownHostsFile=/dev/null" >> /etc/ssh/ssh_config
   # Add sandbar1 to list of known hosts
   sudo ssh-keyscan -t rsa 10.1.2.44 >> ~/.ssh/known_hosts
   sudo ssh-keyscan -t rsa 10.1.2.45 >> ~/.ssh/known_hosts
   # SSH into sandbar1 and authorize public keys
   sshpass -p "vagrant" ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t -t vagrant@sandbar1 <<EOF
echo "SSH into sandbar1"
sudo su -
if [ ! -d "/root/.ssh" ];
then
  sudo mkdir /root/.ssh
fi
if [ ! -f "/root/.ssh/authorized_keys" ]; then
 sudo cat ~/vagrant/.ssh/id_rsa1.pub >> /root/.ssh/authorized_keys
 sudo cat ~/vagrant/.ssh/id_rsa2.pub >> /root/.ssh/authorized_keys
fi
exit
exit
EOF
fi
