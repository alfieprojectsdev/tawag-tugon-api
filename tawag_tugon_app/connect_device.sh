#!/bin/bash
# Utility script to quickly reconnect the physical testing device over Wi-Fi

ADB_PATH="/home/finch/Android/Sdk/platform-tools/adb"
PORT="5555"

# Automatically grab the first IP address from hostname -I
DEVICE_IP=$(hostname -I | awk '{print $1}')

echo "Detected laptop IP: $DEVICE_IP"

echo "Updating Flutter environment file..."
echo -e "// AUTO-GENERATED FILE. DO NOT EDIT.\nclass Env {\n  static const String serverIp = '$DEVICE_IP';\n}" > lib/env.dart

echo "Restarting ADB Server..."
$ADB_PATH kill-server
$ADB_PATH start-server

echo "Setting TCP/IP port to $PORT..."
$ADB_PATH tcpip $PORT

# Slight delay to ensure the tcpip command succeeds before connecting
sleep 2

echo "Connecting to device at $DEVICE_IP:$PORT..."
$ADB_PATH connect $DEVICE_IP:$PORT

echo "Device connection process finished!"

# NOTE: For the Flutter physical device to access the API over Wi-Fi, 
# you MUST start the Uvicorn server bound to 0.0.0.0 instead of 127.0.0.1:
# uv run uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
