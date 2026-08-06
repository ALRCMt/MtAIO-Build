#!/bin/ash
echo "Content-Type: text/plain"
echo ""

for s in lucky aria2 passwall openlist2 cloudflared; do
    pgrep -f "$s" > /dev/null 2>&1 && echo "$s"
done

ping -c 2 -w 3 google.com > /dev/null 2>&1 && echo "proxyover"
