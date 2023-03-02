#!/usr/bin/bash
#
proceed="y"
ver="6"
#
## admin
adminAppInstall () {
    app=$@
	if [ "$proceed" == "y" ]; then 
		read -p "Do u want to continue installing '${app[@]}': " proceed
		if [ "$proceed" == "y" ]; then
			apt update
			apt install ${app[@]}
		fi	
	fi	
}
userAppInstall () {
	app=$@
	if [ "$proceed" == "y" ]; then 
		echo "Installing ${app[@]}"
		`${app[@]}`
		read -p "Continue: " proceed
	fi	
}
#
adminInstall () {
	adminAppInstall git
	adminAppInstall curl
	adminAppInstall snap
	adminAppInstall -y dotnet-sdk-$ver.0
	adminAppInstall -y aspnetcore-runtime-$ver.0
	sudo apt update
	sudo snap install --classic code
}
##
userInstall () {
    #pnpm
    userAppInstall curl -fsSL https://get.pnpm.io/install.sh | sh -
    #
    # node
    userAppInstall curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
    source ~/.bashrc
    userAppInstall nvm install 12
    userAppInstall nvm install 14
    userAppInstall nvm install 16
    userAppInstall nvm use --lts
    # dontnet tools
    userAppInstall dotnet tool update --global dotnet-ef --version $ver.*
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
