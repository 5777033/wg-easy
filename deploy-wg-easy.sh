#!/bin/bash
set -e

echo "=== wg-easy 一键部署脚本 ==="

# 当前目录
DEPLOY_DIR=$(pwd)
DATA_DIR="$DEPLOY_DIR/wgeasy-data"

# 1️⃣ 获取用户输入
read -rp "请输入服务器公网IP (WG_HOST): " WG_HOST
read -rp "请输入 Web UI 管理端口 (默认7000): " UI_PORT
UI_PORT=${UI_PORT:-7000}
read -rp "请输入 WireGuard 端口 (默认7001): " WG_PORT
WG_PORT=${WG_PORT:-7001}
read -rp "请输入DNS服务器 (默认 1.1.1.1,8.8.8.8): " WG_DNS
WG_DNS=${WG_DNS:-1.1.1.1,8.8.8.8}

# 创建数据目录
mkdir -p "$DATA_DIR"

echo "==> 生成 docker-compose.yml 文件 ..."

cat > "$DEPLOY_DIR/docker-compose.yml" <<EOF
version: '3.8'
services:
  wg-easy:
    container_name: wg-easy
    image: ghcr.io/wg-easy/wg-easy
    network_mode: host
    environment:
      - LANG=chs
      - WG_HOST=$WG_HOST
      - WG_DEFAULT_DNS=$WG_DNS
      - PORT=$UI_PORT
      - WG_DEFAULT_ADDRESS=10.8.0.x
      - WG_PORT=$WG_PORT
      - WG_ALLOWED_IPS=0.0.0.0/0
      - UI_TRAFFIC_STATS=true
      - UI_CHART_TYPE=3
      - UI_ENABLE_SORT_CLIENTS=true
    volumes:
      - ./wgeasy-data:/etc/wireguard
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
      - net.ipv4.ip_forward=1
    restart: unless-stopped
EOF

echo "==> 启动容器 ..."
docker compose up -d

echo
echo "=========================================="
echo "✅ wg-easy 已部署成功！"
echo "部署目录: $DEPLOY_DIR"
echo "Web 管理面板: http://$WG_HOST:$UI_PORT"
echo "WireGuard 监听端口: $WG_PORT/UDP"
echo "配置文件目录: $DATA_DIR"
echo "=========================================="
