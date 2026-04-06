#!/bin/sh
echo "Content-Type: text/plain"
echo ""

# 检测服务器是否在线 (使用tcping检测端口8006和3389)
if tcping -p 8006 -c 1 -t 2 x.x.x.x > /dev/null 2>&1; then
    echo "pveonline"
elif tcping -p 3389 -c 1 -t 2 x.x.x.x > /dev/null 2>&1; then
    echo "winonline"
else
    echo "offline"
fi