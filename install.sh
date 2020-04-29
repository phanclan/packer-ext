#!/bin/sh -x
TERRAFORM_VERSION=0.12.24
VAULT_VERSION=1.4.0
CONSUL_VERSION=1.7.2
NOMAD_VERSION=0.11.1
CONSUL_TEMPLATE_VERSION=0.25.0
ENVCONSUL_VERSION=0.9.3
DOCKER_COMPOSE_VERSION=1.25.0

# sleep 30
sudo apt-get update
#sudo apt-get install -qq redis-server
echo "[*] Install base"
sudo apt-get install -qq jq unzip tree curl vim wget git pv make nginx
sudo apt-get install -qq dnsutils iputils-ping net-tools netcat
echo "[*] Install cloud tools"
sudo apt-get install -qq awscli

echo "[*] Install HashiCorp"
curl -s -o /tmp/vault.zip https://releases.hashicorp.com/vault/${VAULT_VERSION}+ent/vault_${VAULT_VERSION}+ent_linux_amd64.zip
curl -s -o /tmp/consul.zip https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip && sudo unzip -qqo -d /usr/local/bin/ /tmp/consul.zip
curl -s -o /tmp/nomad.zip https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip && sudo unzip -qqo -d /usr/local/bin/ /tmp/nomad.zip
curl -s -o /tmp/consul-template.zip https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip
curl -s -o /tmp/envconsul.zip https://releases.hashicorp.com/envconsul/${ENVCONSUL_VERSION}/envconsul_${ENVCONSUL_VERSION}_linux_amd64.zip
curl -s -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip

install_from_zip() {
  cd /tmp
  sudo unzip -qqo -d /usr/local/bin "/tmp/${1}.zip"
  sudo chmod +x "/usr/local/bin/${1}"
  # rm -rf "${1}.zip"
}

for i in terraform vault consul nomad; do
install_from_zip $i
done

install_from_zip consul-template
install_from_zip envconsul

vault -autocomplete-install
consul -autocomplete-install
nomad -autocomplete-install

echo "#--> Create folders"
sudo mkdir -p /vault/logs /consul /nomad /terraform
sudo chown -R ubuntu:ubuntu /vault /consul /nomad /terraform

echo "[*] Install docker"
sudo apt-get install -qq apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -qq docker-ce
sudo usermod -aG docker $USER

echo "[*] Install docker-compose"
sudo curl -sL https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "[*] Running build."
# sudo apt-get install -y python-dev python-pip
# sudo pip install ansible

# sudo ansible-playbook base_playbook.yml

#------------------------------------------------------------------------------
# Remove this in the future
#------------------------------------------------------------------------------

echo "[*] Build html"
# sudo mkdir -p /var/www/website
sudo tee /var/www/html/index.html <<EOF
<html> <head> <style> body { background-color: yellow; } </style> </head>
<body> <h1> Hello, World $(hostname)! </h1>
<p>DB address: ${db_address}</p>
<p>DB port: ${db_port}</p>
</body> </html>
EOF