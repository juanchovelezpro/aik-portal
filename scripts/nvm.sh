#!/bin/bash
sudo yum update -y
sudo yum install -y git 
#Clone salt repo
mkdir -p /srv/app
sudo chmod 777 /srv/app
git clone https://github.com/juanchovelezpro/aik-portal /srv/app
cd /srv/app
git checkout develop
git pull
sudo curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
. ~/.nvm/nvm.sh
export NVM_DIR="$HOME/.nvm"
nvm install node
cd /srv/app
sudo chmod 777 aik-app-ui
cd aik-app-ui
sudo chmod 777 package-lock.json
sudo chmod 777 package.json
npm install
#install salt
sudo yum install -y https://repo.saltstack.com/yum/redhat/salt-repo-latest.el7.noarch.rpm
sudo yum clean expire-cache;sudo yum -y install salt-minion; chkconfig salt-minion off
#config roles name
sudo cp -r /srv/app/conf/minion.d /etc/salt/
echo -e 'grains:\n roles:\n - aik-portal' > /etc/salt/minion.d/grains.conf
sudo salt-call state.apply