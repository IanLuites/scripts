#/bin/sh
# https://pkg.jenkins.io/debian/

set -e

# wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
# sudo echo "deb https://pkg.jenkins.io/debian binary/" >> /etc/apt/sources.list
# sudo apt-get update
# sudo apt-get install -y jenkins


wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | apt-key add -
echo "deb https://pkg.jenkins.io/debian binary/" >> /etc/apt/sources.list
apt-get update
apt-get install -y jenkins

