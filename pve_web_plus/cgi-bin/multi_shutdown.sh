#!/bin/ash
echo "Content-Type: text/plain"
echo ""

PVE_HOST="xx.xx.xx.xx"
WIN_HOST="xx.xx.xx.xx"
WIN_PASSWORD="your_windows_password"
PVE_TOKEN_ID="your_pve_api_token_id"
PVE_TOKEN_SECRET="your_pve_api_token_secret"

# 使用tcping检测是哪个系统在线，发送相应的关机命令
if tcping -p 8006 -c 1 -t 2 192.168.6.217 > /dev/null 2>&1; then
    if curl -k -s --connect-timeout 2 --max-time 3 -X POST \
  -H "Authorization: PVEAPIToken=${PVE_TOKEN_ID}=${PVE_TOKEN_SECRET}" \
  -d "command=shutdown" \
  "https://${PVE_HOST}:8006/api2/json/nodes/pve/status" > /dev/null 2>&1; then
    echo "OKK"
  fi
elif tcping -p 3389 -c 1 -t 2 192.168.6.217 > /dev/null 2>&1; then
    if sshpass -p "$WIN_PASSWORD" ssh -o StrictHostKeyChecking=no Mtest@"$WIN_HOST" "shutdown /s /t 0" > /dev/null 2>&1; then
    echo "OKK"
  fi
fi
