include:
  - nodejs
  - frontend
  
install_back_npm_dependencies:
  npm.bootstrap:
    - name: /srv/app/aik-app-api

run_back_aik_portal:
  cmd.run:
    - name: "nohup node /srv/app/aik-app-api/server.js &"