#!/bin/sh -x
set -x

#==> Export environment variables
TERRAFORM_VERSION=0.12.28
VAULT_VERSION=1.4.3
CONSUL_VERSION=1.8.0
NOMAD_VERSION=0.12.0
CONSUL_TEMPLATE_VERSION=0.25.0
ENVCONSUL_VERSION=0.9.3
DOCKER_COMPOSE_VERSION=1.25.0
DL_URL="https://releases.hashicorp.com"

# sleep 30
echo "[*] Install base"
sudo apt-get update > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq jq unzip tree curl vim wget git pv make nginx > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get -qq install dnsutils iputils-ping net-tools netcat resolvconf > /dev/null

echo "[*] Install cloud tools"
sudo DEBIAN_FRONTEND=noninteractive apt-get -qq install awscli > /dev/null
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

echo "[*] Download HashiCorp"
curl -s -o /tmp/vault.zip ${DL_URL}/vault/${VAULT_VERSION}+ent/vault_${VAULT_VERSION}+ent_linux_amd64.zip
curl -s -o /tmp/consul.zip ${DL_URL}/consul/${CONSUL_VERSION}+ent/consul_${CONSUL_VERSION}+ent_linux_amd64.zip
curl -s -o /tmp/nomad.zip ${DL_URL}/nomad/${NOMAD_VERSION}+ent/nomad_${NOMAD_VERSION}+ent_linux_amd64.zip
curl -s -o /tmp/consul-template.zip ${DL_URL}/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip
curl -s -o /tmp/envconsul.zip ${DL_URL}/envconsul/${ENVCONSUL_VERSION}/envconsul_${ENVCONSUL_VERSION}_linux_amd64.zip
curl -s -o /tmp/terraform.zip ${DL_URL}/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip

echo "[*] Install HashiCorp"
install_from_zip() {
  cd /tmp
  sudo unzip -qqo -d /usr/local/bin "/tmp/${1}.zip" && sudo chmod +x "/usr/local/bin/${1}"
  # rm -rf "${1}.zip"
}

for i in terraform vault consul nomad consul-template envconsul; do
install_from_zip $i
done

echo "#==> Enable autocompletion"
terraform -install-autocomplete
vault -autocomplete-install
consul -autocomplete-install
nomad -autocomplete-install

for i in terraform vault consul nomad; do
complete -C /usr/local/bin/$i $i
done

echo "#--> Create folders"
sudo mkdir -p /vault/logs /consul /nomad /terraform
sudo chown -R $USER:$USER /vault /consul /nomad /terraform || true
for i in vault consul nomad; do
sudo useradd --system --home /etc/${i}.d --shell /bin/false ${i}
sudo mkdir -p /etc/${i}.d
sudo chown -R ${i}:${i} /etc/${i}
sudo chmod a+w /etc/${i}.d
sudo mkdir -p /opt/${i}
sudo chown -R ${i}:${i} /opt/${i}
done
# sudo mkdir -p /etc/vault.d /etc/vault
# sudo chmod a+w /etc/vault.d /etc/vault


echo "[*] Running build."
# sudo apt-get install -y python-dev python-pip
# sudo pip install ansible

# sudo ansible-playbook base_playbook.yml

#------------------------------------------------------------------------------
# Remove this in the future
#------------------------------------------------------------------------------

echo "[*] Build html"
# sudo mkdir -p /var/www/website
# sudo tee /var/www/html/index.html <<EOF
# <html> <head> <style> body { background-color: yellow; } </style> </head>
# <body> <h1> Hello, World $(hostname)! </h1>
# <p>DB address: ${db_address}</p>
# <p>DB port: ${db_port}</p>
# </body> </html>
# EOF