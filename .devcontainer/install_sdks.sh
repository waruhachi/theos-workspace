#!/bin/bash

# Exit script on any error
set -e

# Variables
REPO_URL="https://github.com/theos/sdks/archive/master.zip"
DEST_DIR="$THEOS/sdks"
TMP_DIR=$(mktemp -d)

# Functions
cleanup() {
    echo "Cleaning up temporary files..."
    rm -rf "$TMP_DIR"
}

trap cleanup EXIT

# Ensure the destination directory exists
mkdir -p "$DEST_DIR"

# Download and extract the repository
echo "Downloading repository..."
curl -L "$REPO_URL" -o "$TMP_DIR/repo.zip"

echo "Extracting repository..."
unzip -q "$TMP_DIR/repo.zip" -d "$TMP_DIR"

# Find SDKs in the extracted folder
SDK_PATH=$(find "$TMP_DIR" -type d -name "*sdk*")
if [[ -z "$SDK_PATH" ]]; then
    echo "No SDKs found in the repository. Exiting."
    exit 1
fi

echo "SDKs found at: $SDK_PATH"

# Move all SDKs to the destination directory
echo "Moving all SDKs to $DEST_DIR..."
cp -r "$SDK_PATH"/* "$DEST_DIR/"

echo "All SDKs have been successfully moved to $DEST_DIR."