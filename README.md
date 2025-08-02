# 🚀 wg-easy 一键部署脚本

该项目用于快速在 Linux 服务器上部署 [wg-easy](https://github.com/5777033/wg-easy) WireGuard 管理面板，支持自定义公网 IP、端口和 DNS，自动生成 `docker-compose.yml` 并启动服务。

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
