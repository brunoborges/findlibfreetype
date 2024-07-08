# Use the base image
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

# Copy the findlibfreetype.sh script into the container
COPY findlibfreetype.sh /usr/local/bin/findlibfreetype.sh

# Ensure the script is executable
RUN chmod +x /usr/local/bin/findlibfreetype.sh

# Set the entrypoint to the script
CMD ["/usr/local/bin/findlibfreetype.sh"]
