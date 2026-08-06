#!/bin/ash
echo "Content-type: text/plain"
echo ""

if [ "$REQUEST_METHOD" = "GET" ]; then
    # 读取所有 GET 参数
    if [ "$QUERY_STRING" = "toggle10" ]; then
        # "切换2.4G状态"
        if ifconfig ra0 | grep -q "RUNNING"; then
            ifconfig ra0 down
        else
            ifconfig ra0 up
        fi
        echo "OKK"
    elif [ "$QUERY_STRING" = "toggle20" ]; then
        # "切换5G状态"
        if ifconfig rax0 | grep -q "RUNNING"; then
            ifconfig rax0 down
        else
            ifconfig rax0 up
        fi
        echo "OKK"
    elif [ "$QUERY_STRING" = "toggle1" ]; then
        # "查询2.4G状态"
        if ifconfig ra0 | grep -q "RUNNING"; then
            echo "up"
        else
            echo "down"
        fi

    elif [ "$QUERY_STRING" = "toggle2" ]; then
        # "查询5G状态"
        if ifconfig rax0 | grep -q "RUNNING"; then
            echo "up"
        else
            echo "down"
        fi
    else
        echo "Error"
    fi
fi