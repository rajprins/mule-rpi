#!/bin/bash

function bold {
    tput bold
    echo $1
    tput rmso
}

function introBanner {
    clear
    echo
    bold "+-----------------------------------------------------------------------+"
    bold "| (\_/)     M U L E   R U N T I M E    I N S T A  L L E R               |"
    bold "| /   \     Mule 3 EE for Raspbian Stretch                              |"
    bold "+-----------------------------------------------------------------------+"
}

function preInstallationOps {
    echo
    echo "This script will download, extract and install the Mule 3 CE runtime and"
    echo "several other required packages. Some actions require root access using"
    echo "the 'sudo' command. Your password might be asked."
    sudo -v
}

function installPackages {
    echo;bold ">>> Installing required packages"
    sudo apt-get update
    sudo apt-get install oracle-java8-jdk wget
}

function createUser {
    echo;bold ">>> Preparing user 'mule'"
    if ! [ `id -u mule 2>/dev/null || echo -1` -ge 0 ]; then 
        echo "Creating user 'mule'"
        sudo useradd -s /bin/bash -d /home/mule -U -G sudo mule
        sudo mkdir /home/mule
        sudo chown mule:mule /home/mule
	sudo passwd mule <<EOF
mule
mule
EOF
	echo "User created. Default password for user 'mule' is 'mule'."
    else
        echo "User 'mule' already exists. No action required."
    fi
}

function createBaseDir {
    echo;bold ">>> Creating installation directory"
    if ! [[ -d ${BASE_DIR} ]] ; then
        echo "Creating directory ${BASE_DIR}"
        sudo mkdir ${BASE_DIR}
        sudo chown mule:mule ${BASE_DIR}
    else
        echo "Target directory ${BASE_DIR} already exists. No action required."
    fi
    cd ${BASE_DIR}
}

function downloadMule {
    cd ${BASE_DIR}
    echo;echo ">>> Downloading Mule EE runtime"
    sudo wget https://s3.amazonaws.com/new-mule-artifacts/mule-ee-distribution-standalone-${MULE_VERSION}.zip
    echo;echo ">>> Extracting Mule EE runtime. Please wait..."
    sudo unzip -q ${BASE_DIR}/mule-ee-distribution-standalone-${MULE_VERSION}.zip
}

function downloadServiceWrapper {
    cd ${BASE_DIR}
    echo;bold ">>> Downloading Tanuki wrapper"
    sudo wget https://download.tanukisoftware.com/wrapper/${WRAPPER_VERSION}/wrapper-linux-armhf-32-${WRAPPER_VERSION}.tar.gz
    echo;bold ">>> Extracting Tanuki wrapper"
    sudo tar zxf wrapper-linux-armhf-32-${WRAPPER_VERSION}.tar.gz
}

function patchMuleServiceWrapper {
    echo;bold ">>> Patching Mule runtime libraries"
    sudo cp ${BASE_DIR}/wrapper-linux-armhf-32-${WRAPPER_VERSION}/lib/libwrapper.so ${MULE_HOME}/lib/boot/libwrapper-linux-armhf-32.so
    sudo cp ${BASE_DIR}/wrapper-linux-armhf-32-${WRAPPER_VERSION}/lib/wrapper.jar ${MULE_HOME}/lib/boot/wrapper-3.2.3.jar
    sudo cp ${BASE_DIR}/wrapper-linux-armhf-32-${WRAPPER_VERSION}/bin/wrapper ${MULE_HOME}/lib/boot/exec/wrapper-linux-armhf-32
}

function setMuleConfiguration {
    echo;bold ">>> Modifying wrapper.conf configuration file"
    sudo sed -i 's/wrapper.java.initmemory=1024/wrapper.java.initmemory=256/g' ${MULE_HOME}/conf/wrapper.conf
    sudo sed -i 's/wrapper.java.maxmemory=1024/wrapper.java.maxmemory=512/g' ${MULE_HOME}/conf/wrapper.conf

    echo;bold ">>> Modifying mule launch script"
    sudo sed -i 's/case "$PROC_ARCH" in/case "$PROC_ARCH" in\n   'armv7l')\n        echo "Armhf architecture detected"\n        DIST_ARCH="armhf"\n        DIST_BITS="32"\n        break;;/' ${MULE_HOME}/bin/mule
}

function setPermissions {
    echo;bold ">>> Setting permissions for user 'mule' on ${BASE_DIR}"
    sudo chown -R mule:mule ${BASE_DIR}
}

function postInstallationOps {
    echo
    echo "All done. Log in as user 'mule' and start Mule runtime using this command:"
    bold "${MULE_HOME}/bin/mule start"
    echo "Do not forget to install a license, otherwise this installation will behave as a 30-day trial version."
}

##############################################################################
# Main
##############################################################################

MULE_VERSION=3.9.1
WRAPPER_VERSION=3.5.29
BASE_DIR=/opt/mule
MULE_HOME=${BASE_DIR}/mule-enterprise-standalone-${MULE_VERSION}

introBanner
preInstallationOps
installPackages
createUser
createBaseDir
downloadMule
downloadServiceWrapper
patchMuleServiceWrapper
setMuleConfiguration
setPermissions
postInstallationOps
