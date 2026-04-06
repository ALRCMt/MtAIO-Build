#!/bin/ash
echo "Content-Type: text/plain"
echo ""

# 唤醒PVE主机
PVE_MAC="xx:xx:xx:xx:xx:xx"  # 替换为PVE主机的MAC地址

# 使用etherwake工具 
etherwake -D -i "br-lan" "$PVE_MAC" > /dev/null 2>&1
echo "OKK"