# install pre-requisites 
apt-get update && apt-get install -y gcc make python unzip vim 

# download and install ghost
mkdir /usr/src/ghost
cd /usr/src/ghost/
wget -c https://ghost.org/archives/ghost-0.10.1.zip
unzip ghost-0.10.1.zip
npm install --production 

# Write the config

cd /usr/src/ghost; mv config.example.js config.js

# Edit config.js 
# vim config.js
# scroll to development block and change the server config to use 0.0.0.0 instead of 127.0.0.1
# e.g. 
#             host: '0.0.0.0',

# cleanup
apt-get purge -y --auto-remove gcc make python unzip vim 
rm -rf /var/lib/apt/lists/*
rm ghost-0.10.1.zip
npm cache clean
rm -rf /tmp/npm*


# To launch a container with the above images in a development mode, use
#docker run -d -w /usr/src/ghost  -p 2368 schoolofdevops/ghost:0.1.0 npm start

# To launch ghost in production mode later , use 
#  docker run -d -w /usr/src/ghost  -e NODE_ENV=production -p 2368 schoolofdevops/ghost:0.1.0 npm start
# this will read production block of config.js, which should be configured properly
