sudo apt-get update

echo "Installing dependencies"
echo "Installing dependencies" 
echo "Installing docker"
echo "Installing docker" 
sudo apt-get remove docker docker-engine docker.io containerd runc -y  
sudo apt-get update 
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y 
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - 
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" 
sudo apt-get update 
sudo apt-get install docker-ce=5:19.03.9~3-0~ubuntu-$(lsb_release -cs) docker-ce-cli=5:19.03.9~3-0~ubuntu-$(lsb_release -cs) containerd.io -y 


echo "Installing docker-compose"
echo "Installing docker-compose" 
#install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

#add user to docker group
sudo usermod -aG docker vagrant


# pull docker images
echo "Pulling docker images"
echo "Pulling docker images" 
docker pull mysql:8.0
docker pull oaisoftwarealliance/oai-amf:v2.0.1
docker pull oaisoftwarealliance/oai-nrf:v2.0.1
docker pull oaisoftwarealliance/oai-upf:v2.0.1
docker pull oaisoftwarealliance/oai-smf:v2.0.1
docker pull oaisoftwarealliance/oai-udr:v2.0.1
docker pull oaisoftwarealliance/oai-udm:v2.0.1
docker pull oaisoftwarealliance/oai-ausf:v2.0.1
docker pull oaisoftwarealliance/oai-upf-vpp:v2.0.1
docker pull oaisoftwarealliance/oai-nssf:v2.0.1
docker pull oaisoftwarealliance/oai-pcf:v2.0.1
docker pull oaisoftwarealliance/oai-nef:v2.0.1


echo "Allow packet forwarding"
echo "Allow packet forwarding" 
#allow packet forwarding
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -P FORWARD ACCEPT

echo "Cloning OAI repository"
echo "Cloning OAI repository" 
#clone OAI repository
git clone --branch v2.0.1 https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed.git 
cd oai-cn5g-fed
git checkout -f v2.0.1 

# Synchronize all git submodules
./scripts/syncComponents.sh 

echo "done"
echo "done"