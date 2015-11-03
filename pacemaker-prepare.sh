#!/bin/bash
#
# 
set -x

_sync_dir=/home/vagrant/sync
source ${_sync_dir}/config.sh

node=$(hostname)
node=$(echo $node)
echo "$node is active."


if [[ $node = "sandbar2" ]]; then
	# Update firewall rules for pacemaker
	firewall-cmd --add-port=2224/tcp --permanent
	firewall-cmd --reload

	sudo systemctl enable pacemaker
	sudo systemctl start pacemaker
	sudo systemctl enable pcsd
	sudo systemctl start pcsd

	# Add password for cluster user
	echo "${hacluster_u}:${hacluster_p}" | sudo chpasswd

	sshpass -p "vagrant" ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t -t vagrant@sandbar1 <<EOF
# Update firewall rules for pacemaker
firewall-cmd --add-port=2224/tcp --permanent
firewall-cmd --reload

sudo systemctl enable pacemaker
sudo systemctl start pacemaker
sudo systemctl enable pcsd
sudo systemctl start pcsd

# Add password for cluster user
echo "${hacluster_u}:${hacluster_p}" | sudo chpasswd
exit
EOF

	echo "Configure the cluster on ${node2_name}"
	/usr/bin/expect ${sync_dir}/pcs.expect ${node1_ip} ${node2_ip} ${hacluster_u} ${hacluster_p}

	sshpass -p "vagrant" ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t -t vagrant@sandbar1 <<EOF
echo "Configure the cluster on sandbar1"
/usr/bin/expect /home/vagrant/sync/pcs.expect  10.1.2.45 10.1.2.44 hacluster passy
exit
EOF

#/usr/bin/expect ${sync_dir}/pcs.expect ${node2_ip} ${node1_ip} ${hacluster_u} ${hacluster_p}
	# Create the cluster grouping 
	sudo pcs cluster setup --force --name ${cluster_name} ${node1_name} ${node2_name}
fi

# if [[ $node = "grizzly2" ]]; then

# #Configure DRBD resource "mysql.res"
# sudo crm configure primitive p_drbd_mysql ocf:linbit:drbd params drbd_resource="mysql" drbdconf="/etc/drbd.conf" op start interval="0" timeout="90s" op stop interval="0" timeout="180s" op promote interval="0" timeout="180s" op demote interval="0" timeout="180s" op monitor interval="10s" role="Slave" timeout="20s" op monitor interval="11s" role="Master" timeout="21s"
 
# #Configure Master
# sudo crm configure ms ms_drbd_mysql p_drbd_mysql meta master-max="1" master-node-max="1" clone-max="2" clone-node-max="1" notify="true"

# #Configure DRBD Volume Group
# sudo crm configure primitive p_lvm_mysql ocf:heartbeat:LVM params volgrpname="VG_PG" op start interval="0" timeout="30" op stop interval="0" timeout="30"
# #Configure DRBD Filesystem to work with LVM
# sudo crm configure primitive p_fs_mysql ocf:heartbeat:Filesystem params device="/dev/VG_PG/LV_DATA" directory="/db/mysql" fstype="xfs" options="noatime,nodiratime" op start timeout="60s" op stop timeout="180s" op monitor interval="60s" timeout="60s"
# #Configure LSB to work with MySQL
# #sudo crm configure primitive p_lsb_mysql lsb:mysql op monitor interval="30" timeout="60" op start interval="0" timeout="60" op stop interval="0" timeout="60"
# #Create Virtual IP for MySQL
# sudo crm configure primitive p_ip_mysql ocf:heartbeat:IPaddr2 params ip="10.1.2.101" iflabel="mysqlvip" cidr_netmask="24" nic="eth1" op monitor interval="30s"
# #Load MySQL configs
# sudo crm configure primitive p_mysql ocf:heartbeat:mysql params additional_parameters="--bind-address=10.1.2.101" config="/db/mysql/mysql/my.cnf" pid="/var/run/mysqld/mysqld.pid" socket="/var/run/mysqld/mysqld.sock" log="/var/log/mysql/mysqld.log" op monitor interval="20s" timeout="10s" op start interval="0" timeout="120s" op stop interval="0" timeout="120s" meta target-role="Started"
# #Create Service Group
# sudo crm configure group g_mysql p_ip_mysql p_lvm_mysql p_fs_mysql p_mysql 
# #Configure Colocation
# sudo crm configure colocation c_mysql_on_drbd inf: g_mysql ms_drbd_mysql:Master
# #Configure order
# sudo crm configure order o_drbd_before_mysql inf: ms_drbd_mysql:promote g_mysql:start

# #Cleanup MySQL resource to let Pacemaker take over control 
# sudo crm resource cleanup p_mysql

# #sudo crm configure ms ms_mysql p_mysql meta clone-max=2

# fi
