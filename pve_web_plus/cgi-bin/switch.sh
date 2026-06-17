#!/bin/ash
echo "Content-Type: text/plain"
echo ""

PVE_HOST="x.x.x.x"
PVE_PASSWORD="your_password"
WIN_HOST="xx.xx.xx.xx"
WIN_PASSWORD="your_windows_password"

if tcping -p 8006 -c 1 -t 2 192.168.6.217 > /dev/null 2>&1; then
    if sshpass -p "$PVE_PASSWORD" ssh -o StrictHostKeyChecking=no root@"$PVE_HOST" "efibootmgr --bootnext 0000 && reboot" > /dev/null 2>&1; then
    echo "OKK"
fi
elif tcping -p 3389 -c 1 -t 2 192.168.6.217 > /dev/null 2>&1; then
    if sshpass -p "$WIN_PASSWORD" ssh -o StrictHostKeyChecking=no Mtest@"$WIN_HOST" "shutdown /r /t 0" > /dev/null 2>&1; then
    echo "OKK"
  fi
fi
