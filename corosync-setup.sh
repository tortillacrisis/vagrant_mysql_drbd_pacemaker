node=$(hostname)
node=$(echo $node)
echo "$node is active."

# TODO - add firewall rules for both nodes
firewall-cmd --permanent --add-port=5404/udp
firewall-cmd --permanent --add-port=5405/udp
firewall-cmd --reload


#if [[ $node = "sandbar2" ]]; then

	# Enable the corosyn
	sudo systemctl enable corosync

	# sudo sed -i 's/=no/=yes/' /etc/default/corosync
	sudo cp /home/vagrant/sync/corosync.conf /etc/corosync/corosync.conf
	export ais_port=5405
	export ais_mcast=239.255.42.1
	export ais_addr=`ip addr | grep "inet " | tail -n 1 | awk '{print $4}' | sed s/255/0/`

	echo "Binding corosync configuration to ip address : $ais_addr"
	sed -i.bak "s/.*mcastaddr:.*/mcastaddr:\ $ais_mcast/g" /etc/corosync/corosync.conf
	sed -i.bak "s/.*mcastport:.*/mcastport:\ $ais_port/g" /etc/corosync/corosync.conf
	sed -i.bak "s/.*bindnetaddr:.*/bindnetaddr:\ $ais_addr/g" /etc/corosync/corosync.conf

	echo "Restarting Interfaces"
	sudo ifdown eth1 && sudo ifup eth1
	sudo ifdown eth2 && sudo ifup eth2

	if [[ $? = "0" ]]; then
		echo "Successfully restarted."
	else
		echo "No success."
	fi

# 	sshpass -p "vagrant" ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t -t vagrant@sandbar1 <<EOF
# echo "SSH into sandbar1"
# sudo update-rc.d corosync enable
# sudo sed -i 's/=no/=yes/' /etc/default/corosync
# sudo scp /home/vagrant/sync/corosync.conf /etc/corosync/corosync.conf
# export ais_port=5405
# export ais_mcast=239.255.42.1
# export ais_addr=`ip addr | grep "inet " | tail -n 1 | awk '{print $4}' | sed s/255/0/`
# exit
# EOF

if [[ $node = "sandbar2" ]]; then
	if [ ! -f /etc/corosync/authkey ]; then 
		echo "No Corosync key. Installing it..."
	else echo "There." 
		sudo rm /etc/corosync/authkey
	fi

	# Generate corosync authkey with help from urandom
	until [ -f /etc/corosync/authkey ]
		do dd if=/dev/urandom of=/tmp/100 bs=1024 count=100000
		for i in {1..10} 
			do cp /tmp/100 /tmp/tmp_$i_$RANDOM
		done 
		rm -f /tmp/tmp_* /tmp/100
	done & sudo /usr/sbin/corosync-keygen

	#sudo rm /home/vagrant/sync/authkey
	sudo touch /home/vagrant/sync/authkey
	sudo chmod 0777 /home/vagrant/sync/authkey
	sudo scp /etc/corosync/authkey /home/vagrant/sync/authkey

	# Distribute authkey to other node
	sshpass -p "vagrant" scp /home/vagrant/sync/authkey vagrant@sandbar1:/home/vagrant/sync/authkey
	sshpass -p "vagrant" ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t -t vagrant@sandbar1 <<EOF
echo "SSH into sandbar1"
sudo touch /etc/corosync/authkey
sudo chmod 0777 /etc/corosync/authkey
sudo scp /home/vagrant/sync/authkey /etc/corosync/authkey
exit
EOF

	sudo systemctl start corosync
	sudo corosync-cfgtool -s
	# sudo corosync-objctl runtime.totem.pg.mrp.srp.members

	sshpass -p "vagrant" ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t -t vagrant@sandbar1 <<EOF
echo "SSH into sandbar1"
sudo systemctl start corosync
#sudo systemctl start pacemaker
exit
EOF

	# sudo systemctl start pacemaker

	# sudo crm configure property no-quorum-policy="ignore"
	# sudo crm configure property pe-warn-series-max="1000"
	# sudo crm configure property pe-input-series-max="1000"
	# sudo crm configure property pe-error-series-max="1000"
	# sudo crm configure property cluster-recheck-interval="5min"
	# sudo crm configure property stonith-enabled="false"
	# sudo crm configure property default-resource-stickiness="100"

fi
