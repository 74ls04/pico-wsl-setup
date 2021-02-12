#!/bin/bash
#
# Configures WSL for the Raspberry Pi Pico and Visual Studio Code.
# - Based on the official raspberrypi/pico-setup.sh script
#

# Exit immediately if a command exits with a non-zero status.
set -o errexit

# Ensure script is running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)" 1>&2
   exit 1
fi

# Base directory for the SDK
OUTDIR="$(pwd)/pico"

# Install dependencies
SDK_DEPS="git cmake gcc-arm-none-eabi libnewlib-arm-none-eabi build-essential"

echo "Installing Dependencies"
sudo apt update
sudo apt install -y $SDK_DEPS

echo "Creating $OUTDIR"
# Create pico directory to put everything in
mkdir -p $OUTDIR
cd $OUTDIR

# Clone sw repos
GITHUB_PREFIX="https://github.com/raspberrypi/"
GITHUB_SUFFIX=".git"
SDK_BRANCH="master"

for REPO in sdk examples extras playground
do
    DEST="$OUTDIR/pico-$REPO"

    if [ -d $DEST ]; then
        echo "$DEST already exists so skipping"
    else
        REPO_URL="${GITHUB_PREFIX}pico-${REPO}${GITHUB_SUFFIX}"
        echo "Cloning $REPO_URL"
        git clone -b $SDK_BRANCH $REPO_URL

        # Any submodules
        cd $DEST
        git submodule update --init
        cd $OUTDIR

        # Define PICO_SDK_PATH in ~/.bashrc
        VARNAME="PICO_${REPO^^}_PATH"
        echo "Adding $VARNAME to ~/.bashrc"
        echo "export $VARNAME=$DEST" >> ~/.bashrc
        export ${VARNAME}=$DEST
    fi
done

cd $OUTDIR

# Pick up new variables we just defined
source ~/.bashrc


# Install WSL extensions
echo "Installing WSL extensions"
code --install-extension marus25.cortex-debug
code --install-extension ms-vscode.cmake-tools
code --install-extension ms-vscode.cpptools


