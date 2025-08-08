#!/bin/bash
cd ~
curl -O https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py
pip install git-remote-codecommit
sudo -u ec2-user -i <<EOF
sudo yum update -y
cd /home/ec2-user
sudo yum install -y ruby wget
sudo yum install -y aws-cli
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo service codedeploy-agent status
EOF

