#!/bin/ash
echo "Content-Type: text/plain"
echo ""

FIREWALL_CONFIG="/etc/config/firewall"
BACKUP_DIR="/tmp/firewall_backups"

mkdir -p "$BACKUP_DIR" 2>/dev/null

usage() {
    echo "Usage: GET /cgi-bin/modify_firewall.sh?0001|0002|0003"
    echo "  0001 - wan DROP + V6Allow enabled (安全模式)"
    echo "  0002 - wan ACCEPT + V6Allow enabled (开放模式)"
    echo "  0003 - wan DROP + V6Allow disabled (严格模式)"
    echo ""
    echo "  No parameter: show current mode"
    exit 1
}

# 检测当前模式 - 严格匹配
check_mode() {
    # 获取wan区域的input和forward
    local wan_input=$(grep -A 10 "config zone" "$FIREWALL_CONFIG" | grep -A 10 "option name 'wan'" | grep "option input" | head -1 | awk -F"'" '{print $2}')
    local wan_forward=$(grep -A 10 "config zone" "$FIREWALL_CONFIG" | grep -A 10 "option name 'wan'" | grep "option forward" | head -1 | awk -F"'" '{print $2}')
    
    # 检查V6Allow规则是否存在enabled选项
    local v6allow_has_enabled=$(grep -A 10 "option name 'V6Allow'" "$FIREWALL_CONFIG" | grep "option enabled" | head -1)
    local v6allow_enabled_value=""
    if [[ -n "$v6allow_has_enabled" ]]; then
        v6allow_enabled_value=$(echo "$v6allow_has_enabled" | awk -F"'" '{print $2}')
    fi
    
    # 严格判断模式
    # 模式0001: wan input=DROP, wan forward=DROP, V6Allow无enabled 0
    if [[ "$wan_input" == "DROP" ]] && [[ "$wan_forward" == "DROP" ]] && [[ -z "$v6allow_has_enabled" ]]; then
        echo "0001"
        return
    fi
    
    # 模式0002: wan input=ACCEPT, wan forward=ACCEPT, V6Allow无enabled 0
    if [[ "$wan_input" == "ACCEPT" ]] && [[ "$wan_forward" == "ACCEPT" ]] && [[ -z "$v6allow_has_enabled" ]]; then
        echo "0002"
        return
    fi
    
    # 模式0003: wan input=DROP, wan forward=DROP, V6Allow enabled='0'
    if [[ "$wan_input" == "DROP" ]] && [[ "$wan_forward" == "DROP" ]] && [[ "$v6allow_enabled_value" == "0" ]]; then
        echo "0003"
        return
    fi
    
    # 都不匹配，输出错误信息
    echo "Error: Unknown mode"
    echo "  wan input='$wan_input'"
    echo "  wan forward='$wan_forward'"
    echo "  V6Allow enabled='$v6allow_enabled_value'"
}

backup_config() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    cp "$FIREWALL_CONFIG" "$BACKUP_DIR/firewall.backup.$timestamp" 2>/dev/null
}

set_wan_value() {
    local target="$1"
    # 匹配任何 option input 'xxx' 并替换为 target，无论原来的值是什么
    sed -i "/config zone/,/^$/ {
        /option name 'wan'/,/^$/ {
            s/option input '[^']*'/option input '$target'/
            s/option forward '[^']*'/option forward '$target'/
        }
    }" "$FIREWALL_CONFIG" 2>/dev/null
}

main() {
    # CGI: 参数通过 QUERY_STRING 传入（不传则查询当前模式）
    local param="$QUERY_STRING"

    # 如果没有参数，显示当前模式
    if [ -z "$param" ]; then
        [ ! -f "$FIREWALL_CONFIG" ] && echo "Error: Config file not found" && exit 1
        check_mode
        exit 0
    fi

    PARAM="$param"
    [[ "$PARAM" != "0001" && "$PARAM" != "0002" && "$PARAM" != "0003" ]] && usage
    
    [ ! -f "$FIREWALL_CONFIG" ] && echo "Error" && exit 1
    
    backup_config
    
    case "$PARAM" in
        "0001")
            # 修改wan为DROP（安全模式）
            set_wan_value "DROP"
            [ $? -ne 0 ] && echo "Error" && exit 1
            
            # 删除V6Allow的enabled（确保启用）
            if grep -A 10 "option name 'V6Allow'" "$FIREWALL_CONFIG" | grep -q "option enabled"; then
                sed -i '/option name '\''V6Allow'\''/,/^$/ {
                    /option enabled/d
                }' "$FIREWALL_CONFIG" 2>/dev/null
                [ $? -ne 0 ] && echo "Error" && exit 1
            fi
            ;;
        "0002")
            # 修改wan为ACCEPT（开放模式）
            set_wan_value "ACCEPT"
            [ $? -ne 0 ] && echo "Error" && exit 1
            
            # 删除V6Allow的enabled（确保启用）
            if grep -A 10 "option name 'V6Allow'" "$FIREWALL_CONFIG" | grep -q "option enabled"; then
                sed -i '/option name '\''V6Allow'\''/,/^$/ {
                    /option enabled/d
                }' "$FIREWALL_CONFIG" 2>/dev/null
                [ $? -ne 0 ] && echo "Error" && exit 1
            fi
            ;;
        "0003")
            # 修改wan为DROP（严格模式）
            set_wan_value "DROP"
            [ $? -ne 0 ] && echo "Error" && exit 1
            
            # 添加V6Allow的enabled '0'（确保禁用）
            if grep -A 10 "option name 'V6Allow'" "$FIREWALL_CONFIG" | grep -q "option enabled"; then
                if ! grep -A 10 "option name 'V6Allow'" "$FIREWALL_CONFIG" | grep -q "option enabled '0'"; then
                    sed -i '/option name '\''V6Allow'\''/,/^$/ {
                        s/option enabled '\''[^'\'']*'\''/option enabled '\''0'\''/
                    }' "$FIREWALL_CONFIG" 2>/dev/null
                    [ $? -ne 0 ] && echo "Error" && exit 1
                fi
            else
                sed -i '/option name '\''V6Allow'\''/,/^$/ {
                    /^$/ i\
        option enabled '\''0'\''
                }' "$FIREWALL_CONFIG" 2>/dev/null
                [ $? -ne 0 ] && echo "Error" && exit 1
            fi
            ;;
    esac
    
    # 重启防火墙
    /etc/init.d/firewall restart >/dev/null 2>&1
    [ $? -ne 0 ] && echo "Error" && exit 1
    
    echo "OKK"
}

main