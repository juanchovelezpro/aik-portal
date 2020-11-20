include:
  - nodejs

install_back_npm_dependencies:
  npm.bootstrap:
    - name: /srv/app/aik-app-api

api.service:
  file.managed:
    - name: /etc/systemd/system/api.service
    - source: salt://backend/files/api.service

/srv/app/aik-app-api/server.js:
  file.managed:
    - mode: 777

system-reload-backend:
  cmd.run:
    - name: "sudo systemctl --system daemon-reload"
  service.running:
    - name: api
    - reload: True
    - enable: True