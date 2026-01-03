#!/bin/sh
echo "Content-Type: text/plain"
echo ""

# 检测服务器是否在线
if ping -c 1 -W 2 x.x.x.x > /dev/null 2>&1; then
    echo "online"
else
    echo "offline"
fi