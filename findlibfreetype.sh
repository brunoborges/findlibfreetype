#!/bin/bash

# Determine package manager based on OS
if ls /usr/bin/apt-get &> /dev/null; then
    PACKAGE_MANAGER="apt-get"
elif ls /usr/bin/tdnf &> /dev/null; then
    PACKAGE_MANAGER="tdnf"
else
    echo "Unsupported package manager. Exiting."
    exit 1
fi

# Function to install msopenjdk-17 and check for libfreetype.so
check_version() {
    local version=$1
    echo "Installing msopenjdk-17 version $version"

    if [ "$PACKAGE_MANAGER" = "apt-get" ]; then
        sudo apt-get install -y --allow-downgrades msopenjdk-17=$version
    else
        sudo tdnf install -y msopenjdk-17-$version
    fi

    if [ -n "$JAVA_HOME" ] && [ -f "$JAVA_HOME/lib/libfreetype.so" ]; then
        echo "File exists for version $version"
        versions_with_file+=($version)
    else
        echo "File does not exist for version $version"
        versions_without_file+=($version)
    fi

    if [ "$PACKAGE_MANAGER" = "apt-get" ]; then
        sudo apt-get remove -y msopenjdk-17
    else
        sudo tdnf remove -y msopenjdk-17
    fi
}

# Get list of versions
if [ "$PACKAGE_MANAGER" = "apt-get" ]; then
    versions=$(apt-cache madison msopenjdk-17 | awk -F '|' '{print $2}' | tr -d ' ')
else
    versions=$(tdnf list msopenjdk-17 | grep msopenjdk-17 | awk '{print $2}')
fi

# Initialize arrays to store versions with and without the file
versions_with_file=()
versions_without_file=()

# Loop through each version and check
for version in $versions; do
    check_version $version
done

# Report the versions with and without the file
echo "Versions with libfreetype.so:"
for version in "${versions_with_file[@]}"; do
    echo $version
done

echo "Versions without libfreetype.so:"
for version in "${versions_without_file[@]}"; do
    echo $version
done
