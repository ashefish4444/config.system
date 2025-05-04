#!/usr/bin/bash
#
instalIndex=0
debianIndex=0
separators=(
	"############################################################"
	"============================================================"
	"------------------------------------------------------------"
)
messages=()
messagesSub=()
message=""
folder="./.temp/af4-config-system"
# helpers
showSeparator() {
	index=$(($1+0))
	echo "${separators[$index]}"
}
displayMessage() {
    showSeparator 0
	echo "Configuring system."
    showSeparator 2
    for m in ${messages[@]}
   	do
		showSeparator 1
		echo "$m"
	done
}
getRemoteScript() {
    instalIndex=$(($instalIndex+1))
    filePath="$folder/install-$instalIndex.sh"
	curl -L $1 -o $filePath
    chmod +x $filePath
    echo $filePath
}
installRemoteDebian() {
	debianIndex=$(($debianIndex+1))
    filePath="$folder/debian-$debianIndex.deb"
	curl -L $1 -o $filePath
    sudo apt install $filePath
    rm -rf $filePath
}
# installers
## single installers
### shared installers
singleInstall () {
    appIndex=${#messages[@]}
    appName=$2
    appCommand=$1
	read -p "Do u want to install '$appName'  (y/<any other key to skip>): " proceed
    messages+=("Installing '$appName'...")
    displayMessage
	if [ "$proceed" == "y" ]; then
        `$appCommand`
      	source ~/.bashrc
        messages[$appIndex]="Installed '$appName'"
	else
		messages[$appIndex]="Skiped '$appName'"
	fi
    displayMessage
}
singleAdminInstall () {
    sudo apt update
	sudo $@
}
singleAdminAptInstall () {
    singleAdminInstall apt $@
}
### specific app installers
installGit () {
    singleAdminAptInstall git
}
installVSCode () {
    installRemoteDebian https://vscode.download.prss.microsoft.com/dbazure/download/stable/17baf841131aa23349f217ca7c570c76ee87b957/code_1.99.3-1744761595_amd64.deb
}
dotNetVer="8.0"
dotNetScript=""
installDotnetVersion () {
    `$dotNetScript --channel $dotNetVer`
    read -p "Enter the version of ASP.NET Core version to install [(<Major>.<Minor>)|<press enter to skip>)]: ": dotNetVer
}
installDotnet () {
    dotnetIndex=${#messages[@]}
    dotNetScript=`getRemoteScript https://dot.net/v1/dotnet-install.sh`
    installRemoteDebian https://dot.net/v1/dotnet-install.sh -o ./install-temp/dotnet-install.sh
    while [ "$dotNetVer" != "" ]
   	do
		singleInstall installDotnetVersion ASP.net-core-$dotNetVer
	done
}
installNVM () {
    curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
	source .bashrc
    nvm install 20.9.0
}
installPNPM () {
    curl -fsSL https://get.pnpm.io/install.sh | sh -
}
#######
cd ~
displayMessage
gs=(`groups`)
isSudoer=0
for g in ${gs[@]}
do 
    if [ "$g" == "sudo" ]; then isSudoer=0; fi
done
if [ $isSudoer -eq 1 ]
then
    singleInstall installGit Git
    singleInstall installVSCode VSCOde
fi
singleInstall installNVM NVM
singleInstall installPNPM PNPM
singleInstall installDotnet ASP.net-core


