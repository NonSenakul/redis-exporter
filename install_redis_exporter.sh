#!/bin/bash

# Install Go 1.20.6
echo "Installing Go 1.20.6..."
cd /tmp
wget https://dl.google.com/go/go1.20.6.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.20.6.linux-amd64.tar.gz

# Update bashrc
echo "Updating ~/.bashrc..."
echo 'export PATH=/usr/local/go/bin:$PATH' >> ~/.bashrc
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc
source ~/.bashrc

# Verify Go installation
echo "Verifying Go installation..."
go version

# Clone Redis Exporter repository
echo "Cloning Redis Exporter repository..."
git clone https://github.com/oliver006/redis_exporter.git
cd redis_exporter

# Build Redis Exporter
echo "Building Redis Exporter..."
go build .

# Copy redis_exporter binary to /usr/bin
echo "Copying redis_exporter to /usr/bin..."
cp redis_exporter /usr/bin/

# Create redis_exporter.service
echo "Creating redis_exporter.service..."
cat <<EOT > /etc/systemd/system/redis_exporter.service
[Unit]
Description=Redis Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=root
Group=root
Type=simple
ExecStart=/usr/bin/redis_exporter \\
    -web.listen-address ":9121" \\
    -redis.addr "redis://<ip:redis-server>:6379" \\
    -redis.password "<redis password>"

[Install]
WantedBy=multi-user.target
EOT

# Reload systemd daemon and start redis_exporter
echo "Reloading systemd daemon and starting redis_exporter..."
systemctl daemon-reload
systemctl restart redis_exporter

# Check redis_exporter status
echo "Checking redis_exporter status..."
systemctl status redis_exporter

# Verify metrics endpoint
echo "Verifying metrics endpoint..."
curl http://<ip:redis-server>:9121/metrics

echo "Redis Exporter installation and setup completed."
