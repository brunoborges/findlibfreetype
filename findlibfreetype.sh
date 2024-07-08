#!/bin/bash

# Run apt-cache madison msopenjdk-17 and parse the output to get package versions
versions=$(apt-cache madison msopenjdk-17 | awk -F '|' '{print $2}' | tr -d ' ')

# Initialize arrays to store versions with and without the file
versions_with_file=()
versions_without_file=()

# Loop through each version and install it, then check for the file
for version in $versions; {
    echo "Installing msopenjdk-17 version $version"
    apt-get install -y --allow-downgrades msopenjdk-17=$version

    # Check if the file exists
    if ls /usr/lib/jvm/msopenjdk-17/lib/libfreetype.so 1> /dev/null 2>&1; then
        echo "File exists for version $version"
        versions_with_file+=($version)
    else
        echo "File does not exist for version $version"
        versions_without_file+=($version)
    fi

    # Optionally, you may want to remove the installed package before trying the next version
    apt-get remove -y msopenjdk-17
}

# Report the versions with and without the file
echo "Versions with libfreetype.so:"
for version in "${versions_with_file[@]}"; do
    echo $version
done

echo "Versions without libfreetype.so:"
for version in "${versions_without_file[@]}"; do
    echo $version
done
