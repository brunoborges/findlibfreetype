#!/bin/bash

# Determine package manager based on OS
if ls /usr/bin/apt-get &> /dev/null; then
    PACKAGE_MANAGER="apt-get"
elif ls /usr/bin/tdnf &> /dev/null; then
    PACKAGE_MANAGER="tdnf"
else
    exit 1
fi

# Install gawk
if [ "$PACKAGE_MANAGER" = "apt-get" ]; then
    apt-get update -qq > /dev/null 2>&1 && apt-get install -y -qq gawk > /dev/null 2>&1
else
    tdnf update -q > /dev/null 2>&1 && tdnf install -y -q gawk > /dev/null 2>&1
fi

# Function to install msopenjdk and check for libfreetype.so
check_version() {
    local version=$1

    if [ "$PACKAGE_MANAGER" = "apt-get" ]; then
        apt-get install -y -qq --allow-downgrades msopenjdk-$JDK_VERSION=$version > /dev/null 2>&1
    else
        tdnf install -y -q msopenjdk-$JDK_VERSION-$version > /dev/null 2>&1
    fi

    if [ -n "$JAVA_HOME" ] && [ -f "$JAVA_HOME/lib/libfreetype.so" ]; then
        versions_with_file+=($version)
    else
        versions_without_file+=($version)
    fi

    if [ "$PACKAGE_MANAGER" = "apt-get" ]; then
        apt-get remove -y -qq msopenjdk-$JDK_VERSION > /dev/null 2>&1
    else
        tdnf remove -y -q msopenjdk-$JDK_VERSION > /dev/null 2>&1
    fi
}

# Get list of versions
if [ "$PACKAGE_MANAGER" = "apt-get" ]; then
    versions=$(apt-cache madison msopenjdk-$JDK_VERSION | awk -F '|' '{print $2}' | tr -d ' ')
else
    versions=$(tdnf list msopenjdk-$JDK_VERSION | grep msopenjdk-$JDK_VERSION | awk '{print $2}')
fi

# Initialize arrays to store versions with and without the file
versions_with_file=()
versions_without_file=()

# Loop through each version and check
for version in $versions; do
    check_version $version
done

# Report the versions with and without the file
echo "## Versions with libfreetype.so:"
for version in "${versions_with_file[@]}"; do
    echo " * $version"
done

echo "## Versions without libfreetype.so:"
for version in "${versions_without_file[@]}"; do
    echo " * $version"
done
