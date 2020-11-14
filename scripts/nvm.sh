<<EOF
        #!/bin/bash
        sudo yum install -y git 
        #Clone salt repo
        git clone https://github.com/juanchovelezpro/aik-portal /app/
        sudo chmod -R 777 /app/
        sudo curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
        . ~/.nvm/nvm.sh
        export NVM_DIR="$HOME/.nvm"
        sudo nvm install node
        cd /app/aik-app-ui
        sudo npm install
        sudo node server.js
        #Install Node
        #salt
        mkdir -p /srv/app
        sudo chmod 777 /srv/app
        git clone
        #install salt
        sudo yum install -y https://repo.saltstack.com/yum/redhat/salt-repo-latest.el7.noarch.rpm
        sudo yum clean expire-cache;sudo yum -y install salt-minion; chkconfig salt-minion off
        #config roles name
        sudo cp -r /srv/app/conf/minion.d /etc/salt/
        echo -e 'grains:\n roles:\n - aik-portal' > /etc/salt/minion.d/grains.conf

        sudo salt-call state.apply
EOF