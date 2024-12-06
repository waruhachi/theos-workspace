#!/bin/bash

set -e

SWIFT_VERSION="6.0.2"
SWIFT_PLATFORM="ubuntu2204"
SWIFT_PLATFORM_VERSION="ubuntu22.04"
SWIFT_INSTALL_DIR="$HOME/swift-$SWIFT_VERSION-RELEASE-$SWIFT_PLATFORM_VERSION"

SDK_REPO_URL="https://github.com/theos/sdks/archive/master.zip"
SDK_DEST_DIR="$THEOS/sdks"
SDK_TMP_DIR=$(mktemp -d)

LIBGC_REPO_URL="https://github.com/MrGcGamer/LibGcUniversalDocumentation"
LIBGC_TMP_DIR=$(mktemp -d)

cleanup() {
    echo "Cleaning up temporary files..."
    rm -rf "$SDK_TMP_DIR"
    rm -rf "$LIBGC_TMP_DIR"
}

installSwift() {
    echo "Installing Swift dependencies..."

    sudo apt-get update
    sudo apt-get install -y \
        binutils \
        git \
        gnupg2 \
        libc6-dev \
        libcurl4-openssl-dev \
        libedit2 \
        libgcc-11-dev \
        libpython3-dev \
        libsqlite3-0 \
        libstdc++-11-dev \
        libxml2-dev \
        libz3-dev \
        pkg-config \
        python3-lldb-13 \
        tzdata \
        unzip \
        zlib1g-dev

    echo "Downloading Swift $SWIFT_VERSION for $SWIFT_PLATFORM_VERSION..."
    curl -L "https://download.swift.org/swift-$SWIFT_VERSION-release/$SWIFT_PLATFORM/swift-$SWIFT_VERSION-RELEASE/swift-$SWIFT_VERSION-RELEASE-$SWIFT_PLATFORM_VERSION.tar.gz" -o "/tmp/swift-$SWIFT_VERSION-$SWIFT_PLATFORM_VERSION.tar.gz"

    echo "Extracting Swift archive..."
    tar xzf "/tmp/swift-$SWIFT_VERSION-$SWIFT_PLATFORM_VERSION.tar.gz" -C "$HOME"

    echo "Adding Swift to PATH..."
    export PATH="$SWIFT_INSTALL_DIR/usr/bin:$PATH"
    echo "Swift $SWIFT_VERSION has been installed successfully."
}

installSDK() {
    echo "Ensuring the SDK destination directory exists..."
    mkdir -p "$SDK_DEST_DIR"

    echo "Downloading SDK repository..."
    curl -L "$SDK_REPO_URL" -o "$SDK_TMP_DIR/repo.zip"

    echo "Extracting SDK repository..."
    unzip -q "$SDK_TMP_DIR/repo.zip" -d "$SDK_TMP_DIR"

    local sdk_paths
    sdk_paths=$(find "$SDK_TMP_DIR" -type d -name "*.sdk")
    
    if [[ -z "$sdk_paths" ]]; then
        echo "No SDKs found in the repository. Exiting."
        exit 1
    fi

    echo "Copying SDK directories to $SDK_DEST_DIR..."
    for sdk_path in $sdk_paths; do
        cp -r "$sdk_path" "$SDK_DEST_DIR/"
    done

    echo "All SDKs have been successfully copied to $SDK_DEST_DIR."
}

installLibGC() {
    echo "Cloning the LibGcUniversal repository..."
    git clone "$LIBGC_REPO_URL" "$LIBGC_TMP_DIR"

    echo "Navigating to the LibGcUniversal repository directory..."
    cd "$LIBGC_TMP_DIR"

    if [[ -x "./install.sh" ]]; then
        echo "Running the install.sh script..."
        ./install.sh
    else
        echo "install.sh script not found or not executable."
        exit 1
    fi
}

trap cleanup EXIT

installSwift
installSDK
installLibGC