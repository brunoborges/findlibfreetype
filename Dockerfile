# Use the base image
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

# Update the package list and install gawk
RUN apt-get update && apt-get install -y gawk

# Copy the findlibfreetype.sh script into the container
COPY findlibfreetype.sh /usr/local/bin/findlibfreetype.sh

# Ensure the script is executable
RUN chmod +x /usr/local/bin/findlibfreetype.sh

# Set the entrypoint to the script
CMD ["/usr/local/bin/findlibfreetype.sh"]
