#!/bin/bash
set -e
set -o pipefail

echo "==> Starting Cleanup & Sizing Optimization"

echo "--> Stopping services"
sudo systemctl stop fck-nat || true
sudo systemctl stop amazon-cloudwatch-agent || true
sudo systemctl stop amazon-ssm-agent || true

echo "--> Cleaning Cloud-Init state"
sudo cloud-init clean --logs || true
sudo rm -rf /var/lib/cloud/*

echo "--> Cleaning Package Cache"
sudo dnf clean all
sudo rm -rf /var/cache/dnf/*

echo "--> Cleaning Temporary Directories"
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

echo "--> Cleaning Logs"
sudo find /var/log -type f -exec truncate -s 0 {} \;

echo "--> Cleaning Network and Machine State"
# Remove DHCP leases
sudo rm -f /var/lib/dhclient/*
# Truncate machine-id
sudo truncate -s 0 /etc/machine-id
# Remove ssh host keys
sudo rm -f /etc/ssh/ssh_host_*

echo "--> Removing Bash History"
sudo rm -f /root/.bash_history
sudo rm -f /home/*/.bash_history
unset HISTFILE

echo "--> Syncing Filesystem"
sudo sync

echo "--> Trimming Free Space (AWS-native)"
sudo fstrim -av

echo "==> Cleanup Completed Successfully"
