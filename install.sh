sudo apt-get install -y build-essential git-core python libssl-dev gcc g++
git clone git://github.com/wearefractal/ipcannon.git /cannon
git clone https://github.com/joyent/node.git
cd node
git checkout v0.6.8
./configure --prefix=/opt/node
make
sudo make install
export PATH=$PATH:/opt/node/bin
echo "export PATH=$PATH:/opt/node/bin" >> ~/.bashrc
cd /cannon
npm install -g
echo "Installation completed!"
