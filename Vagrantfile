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

Vagrant::Config.run do |config|

  config.vm.define :sandbar1 do |sandbar1_config|

    sandbar1_config.vm.box = "centos/7"
    sandbar1_config.vm.box_url = "https://atlas.hashicorp.com/centos/boxes/7"

    # sandbar1_config.vm.boot_mode = :gui
    # sandbar1_config.vm.network :hostonly, "10.1.2.44"
#    sandbar1_config.vm.network :hostonly, "192.168.56.101"
    sandbar1_config.vm.network :hostonly, "10.1.2.44"
    sandbar1_config.vm.network :hostonly, "192.168.22.11"
    sandbar1_config.vm.host_name = "sandbar1"

    sandbar1_config.vm"virtualbox" do |v|
        v.customize[
            'modifyvm', :id,
            '--name', node[:sandbar2],
            '--memory', 1024
          ]
      end

    sandbar1_config.ssh.max_tries = 100
    sandbar1_config.vm.forward_port 80, 8088
    sandbar1_config.vm.forward_port 22, 2223

    #sandbar1_config.persistent_storage.location = "~/development/sourcehdd1.vdi"
    #sandbar1_config.persistent_storage.size = 50000

    sandbar1_config.vm.provision :shell, :path => "prep.sh"
    # sandbar1_config.vm.provision :puppet do |sandbar1_puppet|
    #   sandbar1_puppet.pp_path = "/tmp/vagrant-puppet"
    #   sandbar1_puppet.module_path = "modules"
    #   sandbar1_puppet.manifests_path = "manifests"
    #   sandbar1_puppet.manifest_file = "site1.pp"
    #   sandbar1_puppet.facter = { "fqdn" => "sandbar1" }
    # end

    #sandbar1_config.vm.provision :shell, :path => "script.sh"
    sandbar1_config.vm.provision :shell, :path => "lvm-setup.sh"
    sandbar1_config.vm.provision :shell, :path => "sshtunnel.sh"
  end

  config.vm.define :sandbar2 do |sandbar2_config|

    sandbar2_config.vm.box = "centos/7"
    sandbar2_config.vm.box_url = "https://atlas.hashicorp.com/centos/boxes/7/versions/1508.01"

    # sandbar1_config.vm.boot_mode = :gui
    sandbar2_config.vm.network :hostonly, "10.1.2.45"
    sandbar2_config.vm.network :hostonly, "192.168.22.12"
    sandbar2_config.vm.host_name = "sandbar2"

    sandbar2_config.vm"virtualbox" do |v|
        v.customize[
            'modifyvm', :id,
            '--name', node[:sandbar2],
            '--memory', 1024
          ]
      end

    sandbar2_config.ssh.max_tries = 100
    sandbar2_config.vm.forward_port 80, 8089
    sandbar2_config.vm.forward_port 22, 2224

    #sandbar2_config.persistent_storage.location = "~/development/sourcehdd2.vdi"
    #sandbar2_config.persistent_storage.size = 50000

    sandbar2_config.vm.provision :shell, :path => "prep.sh"
    # sandbar2_config.vm.provision :puppet do |sandbar2_puppet|
    #   sandbar2_puppet.pp_path = "/tmp/vagrant-puppet"
    #   sandbar2_puppet.module_path = "modules"
    #   sandbar2_puppet.manifests_path = "manifests"
    #   sandbar2_puppet.manifest_file = "site2.pp"
    #   sandbar2_puppet.facter = { "fqdn" => "sandbar2" }
    # end
    #sandbar2_config.vm.provision :shell, :path => "script.sh"
    # sandbar2_config.vm.provision :shell, :path => "lvm-setup.sh"
    sandbar2_config.vm.provision :shell, :path => "sshtunnel.sh"
    
    sandbar2_config.vm.provision :shell, :path => "corosync-setup.sh"
    sandbar2_config.vm.provision :shell, :path => "drbd-setup.sh"
    sandbar2_config.vm.provision :shell, :path => "pacemaker-prepare.sh"
  end
end
