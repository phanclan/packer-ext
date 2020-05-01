# -*- mode: ruby -*-
# vi: set ft=ruby :
# Get the latest version here: https://raw.githubusercontent.com/phanclan/packer-ext/master/Vagrantfile

#==> Variables
# Networking
private_ip = ENV['PRIVATE_IP'] || "192.168.50.100"
consul_host_port = ENV['CONSUL_HOST_PORT'] || 8500
vault_host_port = ENV['VAULT_HOST_PORT'] || 8200
nomad_host_port = ENV['NOMAD_HOST_PORT'] || 4646
ubuntu_private_ip1 = "192.168.50.16"

# Vault variables
vault_version = ENV['VAULT_VERSION'] || "1.2.3"
vault_ent_url = ENV['VAULT_ENT_URL']
vault_group = "vault"
vault_user = "vault"
vault_comment = "Vault"
vault_home = "/srv/vault"

$vault_env = <<VAULT_ENV
sudo cat << EOF > /etc/profile.d/vault.sh
export VAULT_ADDR="http://192.168.50.100:8200"
export VAULT_SKIP_VERIFY=true
EOF
VAULT_ENV

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-18.04"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
  end

  # still needed?
  config.vm.define "hashistack" do |hashistack|
    # hashistack.vm.box_check_update = false
    hashistack.vm.hostname = "hashistack"
    #----- Setup Networking
    hashistack.vm.network "private_network", ip: private_ip
    hashistack.vm.network "forwarded_port", guest: 8000, host: 8000
    hashistack.vm.network "forwarded_port", guest: 8080, host: 8080
    hashistack.vm.network "forwarded_port", guest: 8500, host: 8500 # Consul
    hashistack.vm.network "forwarded_port", guest: 8200, host: 8200 # Vault
    hashistack.vm.network "forwarded_port", guest: 4646, host: 4646 # Nomad
    #----- Share an additional folder to the guest VM.
    hashistack.vm.synced_folder "..", "/vagrant"
    #hashistack.vm.synced_folder "./vagrant_data", "/vagrant_data" # Need folder
    hashistack.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
      vb.cpus = "2"
    end
    #----- Enable provisioning with a shell script.
    hashistack.vm.provision "file", source: "../files/.bash_aliases", destination: "~/.bash_aliases"
    hashistack.vm.provision "shell", path: "../provisioners/base-install.sh"
    hashistack.vm.provision "shell", path: "../provisioners/vault.sh"
  end

  # 3-node config - Region A Servers
  (1..3).each do |i|
    config.vm.define "server-#{i}" do |u|
      u.vm.hostname = "server-#{i}"
      #==> Setup Networking
      u.vm.network "private_network", ip: "192.168.50.#{i+100}"
      if i == 1
        u.vm.network "forwarded_port", guest: 4646, host: "#{i+4645}"
      end
      # u.vm.provision :hosts, sync_hosts: true
      #==> Share an additional folder to the guest VM.
      u.vm.synced_folder "..", "/vagrant"
      # u.vm.synced_folder "./vagrant_data", "/vagrant_data" # Need folder
      #==> Enable provisioning with a shell script.
      # u.vm.provision "file", source: "../files/.bash_aliases", destination: "~/.bash_aliases"
      u.vm.provision "shell", inline: "curl -sfL https://raw.githubusercontent.com/phanclan/packer-ext/master/install.sh | sh -"
      u.vm.provision "shell", inline: "curl -sfL https://raw.githubusercontent.com/phanclan/packer-ext/master/install-docker.sh | sh -"
      u.vm.provision "shell", inline: "curl -sfL https://raw.githubusercontent.com/phanclan/packer-ext/master/install-dnsmasq.sh | sh -"
      # u.vm.provision "shell", path: "../provisioners/base-install.sh"
      # u.vm.provision "shell", inline: "curl https://raw.githubusercontent.com/hashicorp/guides-configuration/master/shared/scripts/base.sh | bash"
      # u.vm.provision "shell", inline: "curl https://raw.githubusercontent.com/hashicorp/guides-configuration/master/shared/scripts/setup-user.sh | bash",
      #   env: {
      #     "GROUP" => vault_group,
      #     "USER" => vault_user,
      #     "COMMENT" => vault_comment,
      #     "HOME" => vault_home,
      #   }
      # u.vm.provision "shell", inline: "curl https://raw.githubusercontent.com/hashicorp/guides-configuration/master/vault/scripts/install-vault.sh | bash",
      #   env: {
      #     "VERSION" => vault_version,
      #     "URL" => vault_ent_url,
      #     "USER" => vault_user,
      #     "GROUP" => vault_group,
      #   }
      # u.vm.provision "shell", inline: $vault_env
    end
  end

  # 2-node config - Region A Clients
  (1..2).each do |i|
    config.vm.define "client-#{i}" do |u|
      u.vm.box = "bento/ubuntu-18.04"
      u.vm.hostname = "client-#{i}"
      #==> Setup Networking
      u.vm.network "private_network", ip: "192.168.50.#{i+103}"
      if i == 1
        u.vm.network "forwarded_port", guest: 4646, host: "#{i+4645}", auto_correct: true
      end
      #==> Share an additional folder to the guest VM.
      u.vm.synced_folder "..", "/vagrant"
      #----- Enable provisioning with a shell script.
      # u.vm.provision "file", source: "../files/.bash_aliases", destination: "~/.bash_aliases"
      u.vm.provision "shell", inline: "curl -sfL https://raw.githubusercontent.com/phanclan/packer-ext/master/install.sh | sh -"
      u.vm.provision "shell", inline: "curl -sfL https://raw.githubusercontent.com/phanclan/packer-ext/master/install-docker.sh | sh -"
      u.vm.provision "shell", inline: "curl -sfL https://raw.githubusercontent.com/phanclan/packer-ext/master/install-dnsmasq.sh | sh -"
    end
  end
end