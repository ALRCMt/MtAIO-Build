#!/bin/ash
echo "Content-Type: text/plain"
echo ""

WIN_HOST="x.x.x.x"
WIN_PASSWORD=" your_password_here"

if sshpass -p "$WIN_PASSWORD" ssh -o StrictHostKeyChecking=no {your_username}@"$WIN_HOST" "shutdown /s /t 0" > /dev/null 2>&1; then
    echo "OKK"
fi

