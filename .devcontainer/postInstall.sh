#!/bin/bash

# Exit script on any error
set -e

# Variables
SDK_REPO_URL="https://github.com/theos/sdks/archive/master.zip"
SDK_DEST_DIR="$THEOS/sdks"
SDK_TMP_DIR=$(mktemp -d)

LIBGC_REPO_URL="https://github.com/MrGcGamer/LibGcUniversalDocumentation"
LIBGC_TMP_DIR=$(mktemp -d)

# Functions
cleanup() {
    echo "Cleaning up temporary files..."
    rm -rf "$SDK_TMP_DIR"
}

trap cleanup EXIT

installSDK() {
    echo "Ensuring the SDK destination directory exists..."
    mkdir -p "$SDK_DEST_DIR"

    # Download and extract the repository
    echo "Downloading SDK repository..."
    curl -L "$SDK_REPO_URL" -o "$SDK_TMP_DIR/repo.zip"

    echo "Extracting SDK repository..."
    unzip -q "$SDK_TMP_DIR/repo.zip" -d "$SDK_TMP_DIR"

    # Find SDKs in the extracted folder
    local sdk_path
    sdk_path=$(find "$SDK_TMP_DIR" -type d -name "*sdk*")
    if [[ -z "$sdk_path" ]]; then
        echo "No SDKs found in the repository. Exiting."
        exit 1
    fi

    echo "SDKs found at: $sdk_path"

    # Move all SDKs to the destination directory
    echo "Moving all SDKs to $SDK_DEST_DIR..."
    cp -r "$sdk_path"/* "$SDK_DEST_DIR/"

    echo "All SDKs have been successfully moved to $SDK_DEST_DIR."
}

installLibGC() {
    echo "Cloning the LibGcUniversal repository..."
    git clone "$LIBGC_REPO_URL" "$LIBGC_DEST_DIR"

    echo "Navigating to the LibGcUniversal repository directory..."
    cd "$LIBGC_DEST_DIR"

    if [[ -x "./install.sh" ]]; then
        echo "Running the install.sh script..."
        ./install.sh
    else
        echo "install.sh script not found or not executable."
        exit 1
    fi
}

# Main Script Execution
installSDK
installLibGC
