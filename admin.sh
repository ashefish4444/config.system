#!/usr/bin/bash
#
installDotnet="n";
proceed="y"
ver="6"
list=()
shouldExist=0
#
ckcd() {
	list=()
	for cmd in $@
 	do
		if [ $shouldExist -ne 0 ] && ! command -v $cmd $> /dev/null
	 	then
	  		echo "'$cmd' is not installed but required."
     			proceed="n"
	    	elif [ $shouldExist -eq 0 ] && !! command -v $cmd $> /dev/null
	 	then
	  		echo "'$cmd' is already installed but required."
     			proceed="e"
	    	fi
     	done
}
## admin
adminAppInstall () {
    app=$@
	if [ "$proceed" == "y" ]; then 
		read -p "Do u want to continue installing '${app[@]}': " proceed
		if [ "$proceed" == "y" ]; then
			sudo apt install ${app[@]}
   			sudo apt update
      			source ~/.bashrc
		fi	
	fi	
}
userAppInstall () {
	app=$@
	if [ "$proceed" == "y" ]; then 
		echo "Installing ${app[@]}"
		`${app[@]}`
  		source ~/.bashrc
		read -p "Continue: " proceed
	fi	
}
#
adminInstall () {
	adminAppInstall git
	adminAppInstall curl
	adminAppInstall snap
	sudo snap install --classic code
	sudo apt update
 	read -p "Do u want to install ASP.NET Core (y/n): ": installDotnet
  	while [ "$installDotnet" != "y" ] && [ "$installDotnet" != "n" ]
   	do
    		read -p "Invalid answer. Do u want to install ASP.NET Core (y/n): ": reply
    	done
     	if [ "$installDotnet" == "y" ]
      	then
	 	adminAppInstall -y dotnet-sdk-$ver.0
		adminAppInstall -y aspnetcore-runtime-$ver.0
  	fi
}
##
userInstall () {
    #
    # node
    userAppInstall curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
    userAppInstall nvm install node
    #pnpm
    userAppInstall curl -fsSL https://get.pnpm.io/install.sh | sh -
    # dontnet tools
    if [ "$installDotnet" == "y" ]
    then
    	userAppInstall dotnet tool update --global dotnet-ef --version $ver.*
     fi
}
#######
cd ~
if [ "$USER" == "root" ]
then 
    read -p "Dotnet version: " ver
    if [ "$ver" == "" ]; then ver="6"; fi
    adminInstall
else
    userInstall
fi
