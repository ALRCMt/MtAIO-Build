#!/bin/sh
PVE_HOST="x.x.x.x"

echo "正在向 PVE 发送关机指令..."

curl -k -s -X POST \
  -H "Authorization: PVEAPIToken={PVE_TOKEN_ID}={PVE_TOKEN_SECRET}" \
  -d "command=shutdown" \
  "https://${PVE_HOST}:8006/api2/json/nodes/pve/status"

echo "关机指令已发送"
