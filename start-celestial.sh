#!/bin/sh

echo "Preparing to start Celestial..."
echo "Moving files..."
sudo mv ./*.img /celestial

echo "Stopping systemd-resolved..."
sudo systemctl stop systemd-resolved

echo "Starting Celestial..."
sudo ./celestial.bin