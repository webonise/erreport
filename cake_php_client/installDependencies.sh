
nodeExists="$(node -v)"
if [ -z "$nodeExists" ]; then
	echo "Installing node ..."
	sudo apt-get install python-software-properties python g++ make
	sudo add-apt-repository ppa:chris-lea/node.js
	sudo apt-get update
	sudo apt-get install nodejs
else
	echo "Node is already installed"
fi

