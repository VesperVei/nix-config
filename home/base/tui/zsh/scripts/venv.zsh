#!/usr/bin/env zsh
# 虚拟环境助手模块 - Zsh 版本

# 配置变量
VENV_DIR="$HOME/Documents/code/python/.venvs"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# 主函数：交互式虚拟环境管理器
function va() {
    # 获取所有虚拟环境
    local envs=()
    local env_path
    for env_path in "$VENV_DIR"/*(/N); do
        envs+=("${env_path:t}")
    done
    local env_count=${#envs[@]}
    
    if [ $env_count -eq 0 ]; then
        echo -e "${RED}❌ 没有找到虚拟环境${NC}"
        echo -e "请先创建虚拟环境到: ${CYAN}$VENV_DIR${NC}"
        return 1
    fi
    
    # 检查当前是否已激活虚拟环境
    if [ -n "$VIRTUAL_ENV" ]; then
        current_env=$(basename "$VIRTUAL_ENV")
        echo -e "${YELLOW}📌 当前已激活环境: ${BOLD}$current_env${NC}"
        
        echo -n "是否退出当前环境? (y/N): "
        read -r response
        
        if [[ "$response" =~ ^[Yy]([Ee][Ss])?$ ]]; then
            deactivate
            echo -e "${GREEN}✅ 已退出 $current_env 环境${NC}"
            
            echo -n "是否立即激活新环境? (y/N): "
            read -r activate_new
            
            if [[ "$activate_new" =~ ^[Yy]([Ee][Ss])?$ ]]; then
                echo ""
            else
                return 0
            fi
        else
            return 0
        fi
    fi
    
    # 列出可用的虚拟环境
    echo ""
    echo -e "${CYAN}📂 可用的虚拟环境:${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    for i in {1..$env_count}; do
        local env_name="${envs[$i]}"
        
        if [ -n "$VIRTUAL_ENV" ] && [ "$(basename "$VIRTUAL_ENV")" = "$env_name" ]; then
            # 注意：显示序号从 0 开始，但索引从 1 开始
            printf "${GREEN}➤ %2d) ${BOLD}%s${NC} ${YELLOW}(当前激活)${NC}\n" "$((i-1))" "$env_name"
        else
            printf "${CYAN}   %2d) %s${NC}\n" "$((i-1))" "$env_name"
        fi
    done
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "输入 ${GREEN}序号${NC} 选择环境，或输入 ${RED}q${NC} 退出"
    echo ""
    
    # 获取用户选择
    while true; do
        echo -n "选择环境序号 [0-$(( $env_count - 1 ))]: "
        read -r choice
        
        if [[ "$choice" =~ ^[Qq]$ ]]; then
            echo -e "${YELLOW}操作已取消${NC}"
            return 0
        fi
        
        if [[ "$choice" =~ ^[0-9]+$ ]]; then
            # 将用户输入的序号转换为 Zsh 数组索引（从1开始）
            local selected_index=$((choice + 1))
            
            if [ $selected_index -ge 1 ] && [ $selected_index -le $env_count ]; then
                local selected_env="${envs[$selected_index]}"
                if ! source "$VENV_DIR/$selected_env/bin/activate"; then
                    echo -e "${RED}❌ 激活失败: $selected_env${NC}"
                    return 1
                fi
                echo -e "${GREEN}✅ 成功激活: $selected_env${NC}"
                echo -e "   ${YELLOW}Python:${NC} $(which python)"
                return 0
            else
                echo -e "${RED}❌ 序号无效，请输入 0 到 $(( $env_count - 1 )) 之间的数字${NC}"
            fi
        else
            echo -e "${RED}❌ 请输入有效的数字或 'q' 退出${NC}"
        fi
    done
}

# 辅助函数
function vl() {
    echo -e "${CYAN}📁 虚拟环境目录: $VENV_DIR${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    command ls -la "$VENV_DIR" | tail -n +2
}

function vc() {
    if [ -n "$VIRTUAL_ENV" ]; then
        echo -e "${GREEN}✅ 当前环境: $(basename $VIRTUAL_ENV)${NC}"
        echo "   路径: $VIRTUAL_ENV"
        echo "   Python: $(which python)"
    else
        echo -e "${YELLOW}⚠️  未激活任何虚拟环境${NC}"
    fi
}

function vd() {
    if [ -n "$VIRTUAL_ENV" ]; then
        local env_name=$(basename "$VIRTUAL_ENV")
        deactivate
        echo -e "${GREEN}✅ 已退出 $env_name 环境${NC}"
    else
        echo -e "${YELLOW}⚠️  当前未在虚拟环境中${NC}"
    fi
}

# 快速激活特定环境
function pwn() {
    echo -e "${CYAN}🚀 正在激活 PWN 环境...${NC}"
    source "$VENV_DIR/pwn/bin/activate"
    echo -e "${GREEN}✅ PWN环境已激活${NC}"
    python --version
}

function crypto() {
    echo -e "${CYAN}🔐 正在激活 Crypto 环境...${NC}"
    source "$VENV_DIR/crypto/bin/activate"
    echo -e "${GREEN}✅ Crypto环境已激活${NC}"
    python --version
}
