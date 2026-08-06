#!/bin/ash

echo "Content-Type: application/json"
echo ""

curl 127.0.0.1:3770/status
