#!/bin/ash
echo "Content-Type: text/plain"
echo ""

PVE_HOST="x.x.x.x"
# 别忘了改用户名与密钥
if curl -k -s --connect-timeout 2 --max-time 3 -X POST \
  -H "Authorization: PVEAPIToken={PVE_TOKEN_ID}={PVE_TOKEN_SECRET}" \
  -d "command=shutdown" \
  "https://${PVE_HOST}:8006/api2/json/nodes/pve/status" > /dev/null 2>&1; then
    echo "OKK"
fi
