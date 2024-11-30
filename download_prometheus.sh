#!/bin/bash

# Exit on error
set -e

URL="https://github.com/prometheus/prometheus/releases/download/v3.0.1/prometheus-3.0.1.linux-amd64.tar.gz"
DOWNLOAD_DIR="./prometheus_download"

# Download Prometheus binary
echo "Downloading Prometheus binary from $URL..."

# Use curl to download the tar and put it in the DOWNLOAD_DIR
mkdir -p "$DOWNLOAD_DIR"
curl -L "$URL" -o "${DOWNLOAD_DIR}/prometheus-3.0.1.linux-amd64.tar.gz"

# Extract the binary
echo "Extracting Prometheus binary..."
tar -xzf "${DOWNLOAD_DIR}/prometheus-3.0.1.linux-amd64.tar.gz" -C "$DOWNLOAD_DIR"

# Copy the binary to the project directory
cp "${DOWNLOAD_DIR}/prometheus-3.0.1.linux-amd64/prometheus" .
cp "${DOWNLOAD_DIR}/prometheus-3.0.1.linux-amd64/promtool" .

# Give execute permissions
chmod +x prometheus
chmod +x promtool

# Cleanup
rm -rf "$DOWNLOAD_DIR"

# Output
echo "Prometheus and promtool has been downloaded and extracted"

