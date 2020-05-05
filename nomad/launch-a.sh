#!/bin/bash
set -x
cd $HOME

# Form Consul Cluster
ps -C consul
retval=$?
if [ $retval -eq 0 ]; then
  sudo killall consul
fi
# sudo cp /vagrant/consul-config/consul-server-west.hcl /etc/consul.d/consul-server-west.hcl
# sudo nohup consul agent --config-file /etc/consul.d/consul-server-west.hcl &>$HOME/consul.log &
wget https://raw.githubusercontent.com/hashicorp/field-workshops-nomad/master/instruqt-tracks/nomad-multi-server-cluster/automatic-clustering-with-consul/setup-nomad-server-1
chmod +x setup-nomad-server-1
sed -i -e 's/^  "client_addr.*/  "client_addr": "0.0.0.0",/' \
  -e 's/ens4/eth1/g' setup-nomad-server-1 \
  -e '/pkill/d' \
  -e '2 a set -x'
sudo ./setup-nomad-server-1


# Form Nomad Cluster
ps -C nomad
retval=$?
if [ $retval -eq 0 ]; then
  sudo killall nomad
fi
# sudo cp /vagrant/nomad-config/nomad-server-west.hcl /etc/nomad.d/nomad-server-west.hcl
# sudo nohup nomad agent -config /etc/nomad.d/nomad-server-west.hcl &>$HOME/nomad.log &