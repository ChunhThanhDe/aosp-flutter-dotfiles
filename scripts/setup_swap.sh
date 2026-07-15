#!/bin/bash

echo "Starting 64GB Swap configuration..."

# Disable and remove existing swap
sudo swapoff -a
sudo rm -f /swapfile

# Create and enable new 64GB swap
sudo fallocate -l 64G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make it permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Optimize swappiness for SSD
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

echo "Swap setup completed successfully. Current memory status:"
free -h
