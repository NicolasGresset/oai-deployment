echo "Updating the system"
sudo apt update
# sudo apt upgrade -y

echo "Installing dependencies"
sudo apt install make -y
sudo apt install gcc -y
sudo apt install g++ -y
sudo apt install libsctp-dev lksctp-tools -y
sudo apt install iproute2 -y
sudo snap install cmake --classic

echo "Cloning the repository"
cd ~
git clone https://github.com/aligungr/UERANSIM

echo "Building the project"
cd ~/UERANSIM
make