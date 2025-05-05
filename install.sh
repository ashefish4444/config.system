#!/usr/bin/bash
#
instalIndex=0
debianIndex=0
separators=(
	"###################################################"
	"==================================================="
	"---------------------------------------------------"
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
formatMessage() {
    # x=$1
    # formattedMessageLevel=$(($x+1))
    formattedMessage=""
    iam=0
    while [ $iam -lt $(($1+0)) ]
    do
        formattedMessage="$formattedMessage####"
        iam=$(($iam+1))
    done
    iam=0
    for w in $@
    do
        if [ $iam -gt 0 ]
        then
            formattedMessage="$formattedMessage#$w"
            iam=$(($iam+1))
        fi
        iam=$(($iam+1))
    done
	echo " $formattedMessage"
}
displayMessage() {
	clear
    showSeparator 0
	echo "Configuring system."
    showSeparator 2
    for m in ${messages[@]}
   	do
		echo "$m" | tr '#' ' '
	done
    showSeparator 1
}
getRemoteScript() {
    instalIndex=$(($instalIndex+1))
    filePath="$folder/install-$instalIndex.sh"
	curl -L $1 -o $filePath
    chmod +x $filePath
    echo $filePath
}
getRemoteDebian() {
	debianIndex=$(($debianIndex+1))
    filePath="$folder/debian-$debianIndex.deb"
	curl -L $1 -o $filePath
    echo $filePath
}
# installers
#single installers
### shared installers
singleInstall () {
    appName=$2
    appCommand=$1
    currentMessage=`formatMessage $3 Installing "'$appName'..."`
    messages+=($currentMessage)
    currentMessageIndex=${#messages[@]}
    displayMessage
	read -p "Do u want to install '$appName'  (y/<any other key to skip>): " proceed   
	if [ "$proceed" == "y" ]; then
        `$appCommand`
      	source ~/.bashrc
        messages[$currentMessageIndex]=`formatMessage "$3 Installed '$appName'"`
	else
		messages[$currentMessageIndex]=`formatMessage "$3 Skipped '$appName'"`
	fi
    displayMessage
}
singleAdminInstallWrapper () {
    sudo apt update
    sudo apt upgrade
	`$@`
    sudo apt update
    sudo apt upgrade
}
singleAdminInstall () {
    singleAdminInstallWrapper sudo $@
}
singleAdminAptInstall () {
    singleAdminInstall apt $@
}
singleAdminDbpkInstall () {
    singleAdminInstall dbpk -i $@
}
### specific app installers
installGit () {
    singleAdminAptInstall git
}
installVSCode () {
    vscodeFilePath=`getRemoteDebian https://vscode.download.prss.microsoft.com/dbazure/download/stable/17baf841131aa23349f217ca7c570c76ee87b957/code_1.99.3-1744761595_amd64.deb`
    singleAdminDbpkInstall $vscodeFilePath
    sudo apt update
    singleAdminAptInstall code
}
installChrome () {
    sudo mkdir -p /etc/apt/sources.list.d
    sudo echo 'deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main' > /etc/apt/sources.list.d/google-chrome.list
    sudo wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    singleAdminAptInstall google-chrome-stable
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
		singleInstall installDotnetVersion ASP.net-core-$dotNetVer 1
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
    if [ "$g" == "sudo" ]; then isSudoer=1; fi
done
if [ $isSudoer -eq 1 ]
then
    singleInstall installGit Git 0
    singleInstall installVSCode VSCode 0
    singleInstall installChrome Chrome 0
fi
singleInstall installNVM NVM 0
singleInstall installPNPM PNPM 0
singleInstall installDotnet ASP.net-core 0


