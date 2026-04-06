#!/bin/ash
echo "Content-Type: text/plain"
echo ""

PVE_HOST="x.x.x.x"
PVE_PASSWORD="your_password"

if sshpass -p "$PVE_PASSWORD" ssh -o StrictHostKeyChecking=no root@"$PVE_HOST" "efibootmgr --bootnext 0000 && reboot" > /dev/null 2>&1; then
    echo "OKK"
fi
