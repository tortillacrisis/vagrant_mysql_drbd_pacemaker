#!/bin/bash  
# set -x
#Update /etc/hosts (list of known hosts)
# echo '192.168.22.11    sandbar1 sandbar1 centos7' >> /etc/hosts
# echo '192.168.22.12    sandbar2 sandbar2 centos7' >> /etc/hosts
echo '10.1.2.44       sandbar1 sandbar1 centos7' >> /etc/hosts
echo '10.1.2.45       sandbar2 sandbar2 centos7' >> /etc/hosts

node=$(hostname)
node=$(echo $node)
echo "$node is active. Generating SSH Tunnel."

work_dir="/tmp/provision"
root_home="/root"
vagrant_home="/home/vagrant"

#Create SSH keys on both nodes

# Generate the initial key pairs in the shared folder and copy them to the hosts
if [ ! -d "${work_dir}/.ssh" ]; then
   echo "Create SSH directory."
   sudo mkdir -p ${work_dir}/.ssh
   sudo chmod 777 ${work_dir}/.ssh
fi
if [ ! -d "${root_home}/.ssh" ]; then
   sudo mkdir -p ${root_home}/.ssh
fi
if [ ! -d "${vagrant_home}/.ssh" ]; then
   sudo mkdir -p ${vagrant_home}/.ssh
fi

# echo "Generate the keypair"
# sudo ssh-keygen -t rsa -q -N "" -f ${root_home}/.ssh/id_rsa

 if [[ $node = "sandbar1" ]]; then
   if [ ! -f "${work_dir}/.ssh/id_rsa" ]; then
    echo "Generate SSH key for node1 (sandbar1)."
    runuser -l vagrant -c "ssh-keygen -t rsa -q -N '' -f ${work_dir}/.ssh/id_rsa"
    sudo cp ${work_dir}/.ssh/id_rsa* ${root_home}/.ssh/
    sudo cp ${work_dir}/.ssh/id_rsa* ${vagrant_home}/.ssh/
    sudo chmod 777 ${work_dir}/.ssh/*
   fi
 fi
 if [[ $node = "sandbar2" ]]; then
   if [ ! -f "${work_dir}/.ssh/id_rsa" ]; then
    echo "Generate SSH key for node2 (sandbar2)."
    runuser -l vagrant -c "ssh-keygen -t rsa -q -N '' -f ${work_dir}/.ssh/id_rsa"
    # ssh-keygen -t rsa -q -N "" -f ${work_dir}/.ssh/id_rsa
    sudo cp ${work_dir}/.ssh/id_rsa* ${root_home}/.ssh/
    sudo cp ${work_dir}/.ssh/id_rsa* ${vagrant_home}/.ssh/
    sudo chmod 777 ${work_dir}/.ssh/*
   fi
 fi
 # else
 #    echo "Node not found."
 # fi

# # Copy respective keys to perminent location .ssh
# if [[ $node = "sandbar1" ]]; then
#   cp ${work_dir}/.ssh/id_rsa1 ~/.ssh/id_rsa

# elif [[ $node = "sandbar2" ]]; then
#   cp ${work_dir}/.ssh/id_rsa2 ~/.ssh/id_rsa

# Copy SSH keypairs to each node
if [[ $node = "sandbar1" ]]; then
   # if [ ! -d "/root/.ssh" ]; then
   #     echo "Create root SSH directory to allow public keys."
   #     sudo mkdir /root/.ssh
   # fi
   if [ ! -f "/root/.ssh/authorized_keys" ]; then
       echo "Copy public keys into SSH directory."
       sudo cat ${work_dir}/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
       # sudo cat ${work_dir}/.ssh/id_rsa2.pub >> /root/.ssh/authorized_keys
   fi
   # Add sandbar2 to list of known hosts
   # echo "Adding nodes to list of known hosts."
   # sudo ssh-keyscan -t rsa 10.1.2.44 >> ~/.ssh/known_hosts
   # sudo ssh-keyscan -t rsa 10.1.2.45 >> ~/.ssh/known_hosts

   # Disable strict host key checking
   echo "Disabling strict host key checking."
   echo "Host sandbar2" >> /etc/ssh/ssh_config
   echo "   Hostname 10.1.2.45" >> /etc/ssh/ssh_config
   echo "   StrictHostKeyChecking no" >> /etc/ssh/ssh_config
   echo "   UserKnownHostsFile=/dev/null" >> /etc/ssh/ssh_config

elif [[ $node = "sandbar2" ]]; then
   # Boot into sandbar2 and authorize public keys
   # if [ ! -d "/root/.ssh" ]; then
   #     echo "Create root SSH directory to allow public keys."
   #     sudo mkdir /root/.ssh
   # fi

   echo "Add sandbar1 to list of known hosts"
   sudo ssh-keyscan -t rsa 10.1.2.44 >> ~/.ssh/known_hosts
   sudo ssh-keyscan -t rsa 10.1.2.45 >> ~/.ssh/known_hosts

   echo "Exchange keys"
   # SSH into sandbar1 and authorize public keys
#    /bin/sshpass -p "vagrant" /bin/ssh-copy-id -i /tmp/provision/.ssh/id_rsa.pub vagrant@sandbar1
#   /bin/sshpass -p "vagrant" /bin/ssh-copy-id -i /tmp/provision/.ssh/id_rsa.pub -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no vagrant@sandbar1
#    /bin/sshpass -p "vagrant" ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t -t vagrant@sandbar1 <<EOF
# echo "SSH into sandbar2 to copy the key"
# /bin/sshpass -p "vagrant" /bin/ssh-copy-id -i /tmp/provision/.ssh/id_rsa.pub vagrant@sandbar2
# exit
# EOF

   sshpass -p "vagrant" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no vagrant@sandbar1:${work_dir}/.ssh/id_rsa.pub ${work_dir}/.ssh/id_rsa1.pub
   sshpass -p "vagrant" scp  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${work_dir}/.ssh/id_rsa.pub vagrant@sandbar1:${work_dir}/.ssh/id_rsa2.pub

   if [ ! -f "/root/.ssh/authorized_keys" ]; then
       echo "Authorizing node 1"
       sudo cat ${work_dir}/.ssh/id_rsa1.pub >> ${root_home}/.ssh/authorized_keys
       sudo cat ${work_dir}/.ssh/id_rsa1.pub >> ${vagrant_home}/.ssh/authorized_keys
       echo "Authorizing node 2"
       sudo cat ${work_dir}/.ssh/id_rsa.pub >> ${root_home}/.ssh/authorized_keys
       sudo cat ${work_dir}/.ssh/id_rsa.pub >> ${vagrant_home}/.ssh/authorized_keys
   fi
   # Disable strict host key checking
   echo "Host sandbar1" >> /etc/ssh/ssh_config
   echo "   Hostname 10.1.2.44" >> /etc/ssh/ssh_config
   echo "   StrictHostKeyChecking no" >> /etc/ssh/ssh_config
   echo "   UserKnownHostsFile=/dev/null" >> /etc/ssh/ssh_config


   # SSH into sandbar1 and authorize public keys
   sshpass -p "vagrant" ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t -t vagrant@sandbar1 <<EOF
echo "SSH into sandbar1"
sudo su -
if [ ! -d "/root/.ssh" ];
then
  sudo mkdir /root/.ssh
fi
if [ ! -f "/root/.ssh/authorized_keys" ]; then
  sudo cat ${work_dir}/.ssh/id_rsa2.pub >> ${root_home}/.ssh/authorized_keys
  sudo cat ${work_dir}/.ssh/id_rsa2.pub >> ${vagrant_home}/.ssh/authorized_keys
  sudo ssh-keyscan -t rsa 10.1.2.44 >> ${vagrant_home}/.ssh/known_hosts
  sudo ssh-keyscan -t rsa 10.1.2.45 >> ${vagrant_home}/.ssh/known_hosts
fi
exit
exit
EOF
fi
