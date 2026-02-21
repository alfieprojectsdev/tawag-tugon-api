#!/bin/bash
# Utility script to quickly reconnect the physical testing device over Wi-Fi

ADB_PATH="/home/finch/Android/Sdk/platform-tools/adb"
DEVICE_IP="192.168.1.96"
PORT="5555"

echo "Restarting ADB Server..."
$ADB_PATH kill-server
$ADB_PATH start-server

echo "Setting TCP/IP port to $PORT..."
$ADB_PATH tcpip $PORT

# Slight delay to ensure the tcpip command succeeds before connecting
sleep 2

echo "Device connection process finished!"

# NOTE: For the Flutter physical device to access the API over Wi-Fi, 
# you MUST start the Uvicorn server bound to 0.0.0.0 instead of 127.0.0.1:
# uv run uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
