#!/bin/bash
set -x
cd $HOME

for i in 1 2 3; do
vagrant ssh server-a-${i} -c \
"sudo rm nohup.out || true && sudo nohup /vagrant/nomad/setup-nomad-lab.sh & sleep 1"
done

echo "#==> Consul ACLs - Creating anonymous default allow"
# Change default to deny after token for demo purposes.
cat <<-EOF > /etc/consul.d/acl.json
{
  "primary_datacenter": "california",
  "acl": {
    "enabled": true,
    "default_policy": "allow",
    "enable_token_persistence": true
  }
}
EOF

mkdir /consul/policies

cat <<-EOF > /consul/policies/server.hcl
# server.hcl
node_prefix "ConsulServer" {
  policy = "write"
}
EOF

cat <<-EOF > /consul/policies/app.hcl
# app.hcl
node "App" {
  policy = "write"
}
EOF

consul acl bootstrap > /tmp/bootstrap.txt

# Form Consul Cluster
# ps -C consul
# retval=$?
# if [ $retval -eq 0 ]; then
#   sudo killall consul
# fi
# sudo cp /vagrant/consul-config/consul-server-west.hcl /etc/consul.d/consul-server-west.hcl
# sudo nohup consul agent --config-file /etc/consul.d/consul-server-west.hcl &>$HOME/consul.log &

echo "#==> START CONSUL ON ALL WEST NODES"
for i in 1 2 3; do
vagrant ssh server-a-${i} -c \
"pkill consul && rm -rf /tmp/consul/server"
done
# To rebuild Consul or Nomad you need to delete their data directory.

for i in 1 2 3; do
vagrant ssh server-a-${i} -c \
"consul agent -config-file /vagrant/nomad/consul-server-west.hcl > consul.log 2>&1 & sleep 1"
done
# doesn't work without sleep 1 at the end

vagrant ssh server-a-1 -c "ps -ef | grep consul"
vagrant ssh server-a-1 -c "consul members && sleep 3 && consul operator raft list-peers"
echo "#==> FINISH - START CONSUL ON ALL NODES"

#------------------------------------------------------------------------------

echo "#==> START NOMAD ON ALL WEST NODES"
for i in 1 2 3; do
vagrant ssh server-a-${i} -c \
"pkill nomad && rm -rf /tmp/nomad"
done
# To rebuild Consul or Nomad you need to delete their data directory.

for i in 1 2 3; do
vagrant ssh server-a-${i} -c \
"nohup nomad agent -config /vagrant/nomad/nomad-server-west.hcl > nomad.log 2>&1 & sleep 1"
done
# doesn't work without sleep 1 at the end

vagrant ssh server-a-1 -c "ps -ef | grep nomad"
echo "#==> FINISH NOMAD ON ALL WEST NODES"

echo #==> Validate Nomad server status
vagrant ssh server-a-1 -c "nomad server members"
echo #==> Validate Nomad client status
vagrant ssh server-a-1 -c "nomad node status"


#==> BEGIN WORKSHOP SETUP
wget https://raw.githubusercontent.com/hashicorp/field-workshops-nomad/master/instruqt-tracks/nomad-multi-server-cluster/automatic-clustering-with-consul/setup-nomad-server-1
chmod +x setup-nomad-server-1
sed -i -e 's/^  "client_addr.*/  "client_addr": "0.0.0.0",/' \
  -e 's/ens4/eth1/g' setup-nomad-server-1 \
  -e '/pkill/d' \
  -e '2 a set -x'
sudo ./setup-nomad-server-1
#==> END WORKSHOP SETUP


# Form Nomad Cluster
ps -C nomad
retval=$?
if [ $retval -eq 0 ]; then
  sudo killall nomad
fi
# sudo cp /vagrant/nomad-config/nomad-server-west.hcl /etc/nomad.d/nomad-server-west.hcl
# sudo nohup nomad agent -config /etc/nomad.d/nomad-server-west.hcl &>$HOME/nomad.log &