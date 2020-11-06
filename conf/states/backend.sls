Install Saltstack in EC2 instances and install git:
    cmd.run:
    - name: "sudo rpm --import http://opensource.wandisco.com/RPM-GPG-KEY-WANdisco && sudo yum -y install git"