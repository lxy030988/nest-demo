#!/bin/bash

# EC2 服务器一键部署脚本 for Ubuntu
# 使用方法：在 EC2 Instance Connect 浏览器终端中执行

set -e  # 遇到错误立即退出

echo "🚀 开始配置 EC2 服务器..."

# 1. 更新系统
echo "📦 更新系统包..."
sudo apt update && sudo apt upgrade -y

# 2. 安装必要工具
echo "🔧 安装必要工具..."
sudo apt install -y curl git build-essential

# 3. 安装 nvm (Node Version Manager)
echo "📥 安装 nvm..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# 加载 nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 4. 安装 Node.js LTS
echo "📥 安装 Node.js LTS..."
nvm install --lts
nvm use --lts
nvm alias default node

# 5. 验证安装
echo "✅ 验证 Node.js 安装..."
node --version
npm --version

# 6. 安装 pnpm
echo "📥 安装 pnpm..."
npm install -g pnpm

# 7. 安装 PM2
echo "📥 安装 PM2..."
npm install -g pm2

# 8. 配置 PM2 开机自启
echo "🔧 配置 PM2 开机自启..."
pm2 startup systemd -u ubuntu --hp /home/ubuntu | grep "sudo" | bash

# 9. 克隆项目
echo "📥 克隆项目..."
cd ~
if [ -d "nest-demo" ]; then
  echo "⚠️  项目目录已存在，跳过克隆..."
  cd nest-demo
  git pull origin main
else
  git clone https://github.com/lxy030988/nest-demo.git
  cd nest-demo
fi

# 10. 安装项目依赖
echo "📦 安装项目依赖..."
pnpm install

# 11. 构建项目
echo "🔨 构建项目..."
pnpm build

# 12. 启动服务
echo "🚀 启动服务..."
pm2 start ecosystem.config.js --env production

# 13. 保存 PM2 配置
echo "💾 保存 PM2 配置..."
pm2 save

# 14. 查看状态
echo "✅ 查看服务状态..."
pm2 list
pm2 logs nest-demo --lines 10 --nostream

echo ""
echo "🎉 部署完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 服务信息："
echo "   应用名称: nest-demo"
echo "   端口: 3002"
echo "   访问地址: http://$(curl -s http://checkip.amazonaws.com):3002"
echo ""
echo "🔧 常用命令："
echo "   查看状态: pm2 status"
echo "   查看日志: pm2 logs nest-demo"
echo "   重启服务: pm2 restart nest-demo"
echo "   停止服务: pm2 stop nest-demo"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
