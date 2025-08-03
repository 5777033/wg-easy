# 🚀 wg-easy 一键部署脚本

该项目用于快速在 Linux 服务器上部署 [wg-easy](https://github.com/5777033/wg-easy) WireGuard 管理面板，支持自定义公网 IP、端口和 DNS，自动生成 `docker-compose.yml` 并启动服务。
## WG-Easy & WireGuard 加密方式与隧道层次
加密方式：

对称加密：WireGuard 使用现代加密算法（如 ChaCha20 和 Poly1305）进行加密，提供高速和安全的加密。

公钥/私钥加密：每个节点（客户端和服务端）都有自己的公钥和私钥，通信通过这些密钥对进行认证和加密。

身份验证：使用 Curve25519（椭圆曲线加密）和 Ed25519（签名算法）进行密钥交换和身份验证。

隧道层次：
---
WireGuard 是 第三层（网络层） 隧道协议。

它通过 IP 层（IPv4、IPv6）进行数据转发，可以直接传输 IP 数据包，属于 Layer 3 隧道。

这使得它可以轻松与现有的路由、NAT 机制兼容，而无需修改应用层协议。
---

## 📂 目录结构

.
├── deploy-wg-easy.sh # 一键部署脚本
├── docker-compose.yml # 部署后自动生成
└── wgeasy-data/ # WireGuard 配置数据持久化

## 执行一键部署脚本
```bash
bash deploy-wg-easy.sh
```
## 查看日志
```bash
docker-compose logs -f wg-easy
```
