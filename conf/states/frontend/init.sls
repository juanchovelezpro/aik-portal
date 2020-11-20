include:
  - nodejs

install_npm_dependencies:
  npm.bootstrap:
    - name: /srv/app/aik-app-ui

aik-ui.service:
  file.managed:
    - name: /etc/systemd/system/aik-ui.service
    - source: salt://frontend/files/aik-ui.service

/srv/app/aik-app-ui/server.js:
  file.managed:
    - mode: 777

system-reload:
  cmd.run:
    - name: "sudo systemctl --system daemon-reload"
  service.running:
    - name: aik-ui
    - reload: True
    - enable: True