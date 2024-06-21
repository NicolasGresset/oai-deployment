echo "Installing docker" 
sudo apt-get update
sudo apt-get remove docker docker-engine docker.io containerd runc -y  
sudo apt-get update 
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y 
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - 
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" 
sudo apt-get update 
sudo apt-get install docker-ce=5:19.03.9~3-0~ubuntu-$(lsb_release -cs) docker-ce-cli=5:19.03.9~3-0~ubuntu-$(lsb_release -cs) containerd.io -y 

echo "Installing docker-compose" 
#install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose