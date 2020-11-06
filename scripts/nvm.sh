<<EOF
        #!/bin/bash
        sudo yum install -y git 
        #Clone salt repo
        git clone https://github.com/juanchovelezpro/aik-portal /app/
        sudo chmod -R 777 /app/
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
        . ~/.nvm/nvm.sh
        export NVM_DIR="$HOME/.nvm"
        nvm install node
        cd /app/aik-app-ui
        npm install
        node server.js
        #Install Node
EOF