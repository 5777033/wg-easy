#!/bin/bash
set -e

echo "=== 🛠 WG-EASY 一键部署脚本 (修复版) ==="

# 当前目录
DEPLOY_DIR=$(pwd)
COMPOSE_FILE="$DEPLOY_DIR/docker-compose.yml"
DATA_DIR="$DEPLOY_DIR/wgeasy-data"

# 1️⃣ 输入参数
read -rp "请输入服务器公网IP: " WG_HOST
read -rp "请输入DNS服务器 (默认 154.66.220.14,8.8.8.8): " WG_DNS
WG_DNS=${WG_DNS:-154.66.220.14,8.8.8.8}
read -rp "请输入Web UI端口 (默认7000): " UI_PORT
UI_PORT=${UI_PORT:-7000}
read -rp "请输入WireGuard端口 (默认7001): " WG_PORT
WG_PORT=${WG_PORT:-7001}
read -rsp "请输入Web UI登录密码: " PASSWORD
echo

# 2️⃣ 生成密码哈希并处理 $ 转义
echo "==> 生成密码哈希..."
PASSWORD_HASH=$(docker run --rm ghcr.io/wg-easy/wg-easy sh -c \
  "node -e \"console.log(require('bcryptjs').hashSync('$PASSWORD', 12))\"")
PASSWORD_HASH_ESCAPED=$(echo "$PASSWORD_HASH" | sed 's/\$/\$\$/g')

echo "部署目录: $DEPLOY_DIR"
echo "数据目录: $DATA_DIR"
echo "公网IP: $WG_HOST"
echo "DNS: $WG_DNS"
echo "Web UI端口: $UI_PORT"
echo "WireGuard端口: $WG_PORT"

# 3️⃣ 创建数据目录
mkdir -p "$DATA_DIR"

# 4️⃣ 写入 docker-compose.yml
cat > "$COMPOSE_FILE" <<EOF
version: '3.8'
services:
  wg-easy:
    container_name: wg-easy
    image: ghcr.io/wg-easy/wg-easy
    network_mode: bridge
    environment:
      - LANG=chs
      - WG_HOST=$WG_HOST
      - WG_DEFAULT_DNS=$WG_DNS
      - PORT=$UI_PORT
      - WG_DEFAULT_ADDRESS=10.8.0.x
      - WG_PORT=$WG_PORT
      - WG_PRE_UP=iptables -t nat -F; iptables -F;
      - WG_POST_UP=iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth+ -j MASQUERADE
      - WG_POST_DOWN=iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth+ -j MASQUERADE
      - WG_ALLOWED_IPS=0.0.0.0/0
      - PASSWORD_HASH=$PASSWORD_HASH_ESCAPED
      - UI_TRAFFIC_STATS=true
      - UI_CHART_TYPE=3
      - UI_ENABLE_SORT_CLIENTS=true
    volumes:
      - ./wgeasy-data:/etc/wireguard
    ports:
      - $UI_PORT:7000/tcp
      - $WG_PORT:7001/udp
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
      - net.ipv4.ip_forward=1
    restart: unless-stopped
EOF

# 5️⃣ 启动服务
echo "==> 启动服务中..."
docker compose up -d

echo
echo "✅ WG-EASY 部署完成"
echo "🔗 访问地址: http://$WG_HOST:$UI_PORT"
echo "🔑 登录密码: $PASSWORD"
echo
echo "📌 提示："
echo "1. 如果报错 sysctl 权限，请尝试在宿主机执行:"
echo "   sudo sysctl -w net.ipv4.conf.all.src_valid_mark=1"
echo "   sudo sysctl -w net.ipv4.ip_forward=1"
echo
echo "2. 客户端配置文件将在首次创建客户端后出现在 $DATA_DIR"

echo
echo "=========================================="
echo "✅ wg-easy 已部署成功！"
echo "部署目录: $DEPLOY_DIR"
echo "Web 管理面板: http://$WG_HOST:$UI_PORT"
echo "WireGuard 监听端口: $WG_PORT/UDP"
echo "配置文件目录: $DATA_DIR"
echo "=========================================="
