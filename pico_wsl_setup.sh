#!/bin/bash
#
# Configures WSL for the Raspberry Pi Pico and Visual Studio Code.
# - Based on the official raspberrypi/pico-setup.sh script
#

# Exit immediately if a command exits with a non-zero status.
set -o errexit

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

# Pick up the new variables we just defined
source ~/.bashrc

echo "======= Configuration Complete ========="
echo "To configure Visual Studio code follow the instructions at"
echo "https://paulbupejr.com/raspberry-pi-pico-windows-development/"
exit 1