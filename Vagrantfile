# -*- mode: ruby -*-
# vi: set ft=ruby :

# Copyright 2013 Zürcher Hochschule für Angewandte Wissenschaften
# All Rights Reserved.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

Vagrant.configure("2") do |config|
  config.vm.define :sandbar1 do |sandbar1|

    sandbar1.vm.box = "centos/7"
    sandbar1.vm.box_url = "https://atlas.hashicorp.com/centos/boxes/7"

    sandbar1.vm.network "private_network", ip: "10.1.2.44"
    sandbar1.vm.network "private_network", ip: "192.168.22.11"
    sandbar1.vm.network "forwarded_port", guest: 80, host: 8088
    sandbar1.vm.network "forwarded_port", guest: 22, host: 2223

    sandbar1.vm.host_name = "sandbar1"

    sandbar1.vm"virtualbox" do |v|
        v.customize[
            'modifyvm', :id,
            '--name', node[:sandbar2],
            '--memory', 1024
          ]
      end

    # sandbar1.ssh.max_tries = 100

    #sandbar1.persistent_storage.location = "~/development/sourcehdd1.vdi"
    #sandbar1.persistent_storage.size = 50000

    sandbar1.vm.provision "shell", path: "prep.sh"
    # sandbar1.vm.provision :puppet do |sandbar1_puppet|
    #   sandbar1_puppet.pp_path = "/tmp/vagrant-puppet"
    #   sandbar1_puppet.module_path = "modules"
    #   sandbar1_puppet.manifests_path = "manifests"
    #   sandbar1_puppet.manifest_file = "site1.pp"
    #   sandbar1_puppet.facter = { "fqdn" => "sandbar1" }
    # end

    sandbar1.vm.provision "shell", path: "install.sh"
    # sandbar1.vm.provision "shell", path: "lvm-setup.sh"
    sandbar1.vm.provision "shell", path: "sshtunnel.sh"
    sandbar1.vm.provision "shell", path: "corosync-setup.sh"
    sandbar1.vm.provision "shell", path: "pacemaker-prepare.sh"
  end

  config.vm.define :sandbar2 do |sandbar2|

    sandbar2.vm.box = "centos/7"
    sandbar2.vm.box_url = "https://atlas.hashicorp.com/centos/boxes/7"

    sandbar2.vm.network "private_network", ip: "10.1.2.45"
    sandbar2.vm.network "private_network", ip: "192.168.22.12"
    sandbar2.vm.network "forwarded_port", guest: 80, host: 8089
    sandbar2.vm.network "forwarded_port", guest: 22, host: 2224
    sandbar2.vm.host_name = "sandbar2"

    sandbar2.vm"virtualbox" do |v|
        v.customize[
            'modifyvm', :id,
            '--name', node[:sandbar2],
            '--memory', 1024
          ]
      end

    # sandbar2.ssh.max_tries = 100

    #sandbar2.persistent_storage.location = "~/development/sourcehdd2.vdi"
    #sandbar2.persistent_storage.size = 50000

    sandbar2.vm.provision "shell", path: "prep.sh"
    # sandbar2.vm.provision :puppet do |sandbar2_puppet|
    #   sandbar2_puppet.pp_path = "/tmp/vagrant-puppet"
    #   sandbar2_puppet.module_path = "modules"
    #   sandbar2_puppet.manifests_path = "manifests"
    #   sandbar2_puppet.manifest_file = "site2.pp"
    #   sandbar2_puppet.facter = { "fqdn" => "sandbar2" }
    # end
    # sandbar2.vm.provision :shell, :path => "lvm-setup.sh"

    sandbar2.vm.provision "shell", path: "install.sh"
    sandbar2.vm.provision "shell", path: "sshtunnel.sh"
    sandbar2.vm.provision "shell", path: "corosync-setup.sh"
    sandbar2.vm.provision "shell", path: "pacemaker-prepare.sh"

    #sandbar2.vm.provision :shell, :path => "drbd-setup.sh"
  end
end
