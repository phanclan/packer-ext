# -*- mode: ruby -*-
# vi: set ft=ruby :

#----- Variables

# Networking
private_ip = ENV['PRIVATE_IP'] || "192.168.50.100"
consul_host_port = ENV['CONSUL_HOST_PORT'] || 8500
vault_host_port = ENV['VAULT_HOST_PORT'] || 8200
nomad_host_port = ENV['NOMAD_HOST_PORT'] || 4646
ubuntu_private_ip1 = "192.168.50.16"

TF_VERSION = "0.12.9"
CONSUL_VERSION = "1.6.1"
VAULT_VERSION = "1.2.3"

# Vault variables
vault_version = ENV['VAULT_VERSION'] || "1.2.3"
vault_ent_url = ENV['VAULT_ENT_URL']
vault_group = "vault"
vault_user = "vault"
vault_comment = "Vault"
vault_home = "/srv/vault"

$USERSCRIPT=<<-SHELL
  set -x
  # HashiCorp
  curl -s -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/0.11.14/terraform_0.11.14_linux_amd64.zip \
    &&  unzip -qqo -d /tmp/ /tmp/terraform.zip && mv /tmp/terraform /usr/local/bin/terraform11
  curl -s -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/#{TF_VERSION}/terraform_#{TF_VERSION}_linux_amd64.zip \
    &&  unzip -qqo -d /usr/local/bin/ /tmp/terraform.zip
  curl -s -o /tmp/vault.zip https://releases.hashicorp.com/vault/#{VAULT_VERSION}/vault_#{VAULT_VERSION}_linux_amd64.zip \
    &&  unzip -qqo -d /usr/local/bin/ /tmp/vault.zip
  curl -s -o /tmp/consul.zip https://releases.hashicorp.com/consul/#{CONSUL_VERSION}/consul_#{CONSUL_VERSION}_linux_amd64.zip \
    &&  unzip -qqo -d /usr/local/bin/ /tmp/consul.zip
SHELL

$vault_env = <<VAULT_ENV
sudo cat << EOF > /etc/profile.d/vault.sh
export VAULT_ADDR="http://192.168.50.100:8200"
export VAULT_SKIP_VERIFY=true
EOF
VAULT_ENV

Vagrant.configure("2") do |config|
  config.vm.define "hashistack" do |hashistack|
      hashistack.vm.box = "bento/ubuntu-18.04"
      # hashistack.vm.box_check_update = false
      hashistack.vm.hostname = "hashistack"

      #----- Setup Networking
      #hashistack.vm.network "public_network"
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
        vb.gui = false
        vb.memory = "4096"
        vb.cpus = "2"
      end

      #----- Enable provisioning with a shell script.
      hashistack.vm.provision "file", source: "../files/.bash_aliases", destination: "~/.bash_aliases"
      hashistack.vm.provision "shell", path: "../provisioners/base-install.sh"
      hashistack.vm.provision "shell", path: "../provisioners/vault.sh"
      hashistack.vm.provision "shell", inline: $USERSCRIPT
  end
  (1..3).each do |i|
      config.vm.define "ubuntu-#{i}" do |ubuntu|
          ubuntu.vm.box = "bento/ubuntu-18.04"
          # ubuntu.vm.box_check_update = false
          ubuntu.vm.hostname = "ubuntu-#{i}"

          #----- Setup Networking
          #ubuntu.vm.network "public_network"
          # ubuntu.vm.network "forwarded_port", guest: 80, host: "808#{i}"
          ubuntu.vm.network "private_network", ip: "192.168.50.10#{i}"
          # ubuntu.vm.provision :hosts, sync_hosts: true
          # ubuntu.vm.network "forwarded_port", guest: 8500, host: 850#{i} # Consul

          #----- Share an additional folder to the guest VM.
          ubuntu.vm.synced_folder "..", "/vagrant"
          # ubuntu.vm.synced_folder "./vagrant_data", "/vagrant_data" # Need folder

          ubuntu.vm.provider "virtualbox" do |vb|
            vb.gui = false
            vb.memory = "1024"
          end

          #----- Enable provisioning with a shell script.
          ubuntu.vm.provision "file", source: "../files/.bash_aliases", destination: "~/.bash_aliases"
          ubuntu.vm.provision "shell", path: "../provisioners/base-install.sh"
          ubuntu.vm.provision "shell", inline: "curl https://raw.githubusercontent.com/hashicorp/guides-configuration/master/shared/scripts/base.sh | bash"
          ubuntu.vm.provision "shell", inline: "curl https://raw.githubusercontent.com/hashicorp/guides-configuration/master/shared/scripts/setup-user.sh | bash",
            env: {
              "GROUP" => vault_group,
              "USER" => vault_user,
              "COMMENT" => vault_comment,
              "HOME" => vault_home,
            }
          ubuntu.vm.provision "shell", inline: "curl https://raw.githubusercontent.com/hashicorp/guides-configuration/master/vault/scripts/install-vault.sh | bash",
            env: {
              "VERSION" => vault_version,
              "URL" => vault_ent_url,
              "USER" => vault_user,
              "GROUP" => vault_group,
            }
          ubuntu.vm.provision "shell", inline: $vault_env
      end
  end

end
