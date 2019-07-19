#!/bin/bash

function bold {
    tput bold
    echo $1
    tput rmso
}

function introBanner {
    clear
    echo
    echo "┌───────────────────────────────────────────────────────────────────────┐"
    echo "│ (\_/)    M U L E   R U N T I M E   I N S T A L L E R                  │"
    echo "│ /   \    Mule 4 CE runtime installer for Raspbian Stretch/Buster      │"
    echo "└───────────────────────────────────────────────────────────────────────┘"
}

function preInstallationOps {
    echo
    echo "This script will download, extract and install the Mule 4 CE runtime and"
    echo "several other required packages. Some actions require root access using"
    echo "the 'sudo' command. Your password might be asked."
    sudo -v
}

function installPackages {
    echo;bold ">>> Installing required packages"
    sudo apt-get update
    sudo apt-get -y install openjdk-8-jdk-headless unzip
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
    echo;echo ">>> Downloading Mule 4 CE runtime"
    wget https://repository-master.mulesoft.org/nexus/content/repositories/releases/org/mule/distributions/mule-standalone/${MULE_VERSION}/mule-standalone-${MULE_VERSION}.tar.gz
    echo;echo ">>> Extracting Mule 4 CE runtime. Please wait..."
    tar zxf mule-standalone-${MULE_VERSION}.tar.gz
}

function downloadServiceWrapper {
    cd ${BASE_DIR}
    echo;bold ">>> Downloading Tanuki wrapper"
    wget https://download.tanukisoftware.com/wrapper/${WRAPPER_VERSION}/wrapper-linux-armhf-32-${WRAPPER_VERSION}.tar.gz
    echo;bold ">>> Extracting Tanuki wrapper"
    tar zxf wrapper-linux-armhf-32-${WRAPPER_VERSION}.tar.gz
}

function patchMuleServiceWrapper {
    echo;bold ">>> Patching Mule 4 runtime libraries"
    cp ${BASE_DIR}/wrapper-linux-armhf-32-${WRAPPER_VERSION}/lib/libwrapper.so ${MULE_HOME}/lib/boot/libwrapper-linux-armhf-32.so
    cp ${BASE_DIR}/wrapper-linux-armhf-32-${WRAPPER_VERSION}/lib/wrapper.jar ${MULE_HOME}/lib/boot/wrapper-${WRAPPER_VERSION}.jar
    cp ${BASE_DIR}/wrapper-linux-armhf-32-${WRAPPER_VERSION}/bin/wrapper ${MULE_HOME}/lib/boot/exec/wrapper-linux-armhf-32
}

function setMuleConfiguration {
    echo;bold ">>> Modifying wrapper.conf configuration file"
    sed -i 's/wrapper.java.initmemory=1024/wrapper.java.initmemory=256/g' ${MULE_HOME}/conf/wrapper.conf
    sed -i 's/wrapper.java.maxmemory=1024/wrapper.java.maxmemory=512/g' ${MULE_HOME}/conf/wrapper.conf

    echo;bold ">>> Modifying mule launch script"
    sed -i 's/case "$PROC_ARCH" in/case "$PROC_ARCH" in\n   'armv7l')\n        echo "Armhf architecture detected"\n        DIST_ARCH="armhf"\n        DIST_BITS="32"\n        break;;/' ${MULE_HOME}/bin/mule
}

function setPermissions {
    echo;bold ">>> Setting permissions for user 'mule' on ${BASE_DIR}"
    sudo chown -R mule:mule ${BASE_DIR}
}

function postInstallationOps {
    echo;bold ">>> Cleaning up"
    cd ${BASE_DIR}
    sudo rm -r wrapper-linux-armhf-32-${WRAPPER_VERSION}*
    sudo rm mule-standalone-${MULE_VERSION}.tar.gz  
    echo
    echo "All done. Log in as user 'mule' and start Mule runtime using this command:"
    bold "${MULE_HOME}/bin/mule start"
    echo
}

##############################################################################
# Main
##############################################################################

MULE_VERSION=4.2.0
WRAPPER_VERSION=3.5.37
BASE_DIR=/opt/mule
MULE_HOME=${BASE_DIR}/mule-standalone-${MULE_VERSION}

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
