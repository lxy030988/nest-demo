# AWS SAM CLI 安装和配置指南

本文档介绍如何在 Mac 上安装 AWS SAM CLI 和相关工具，以及如何配置 AWS 凭证。

---

## ✅ 已完成的安装

### 1. AWS SAM CLI ✅

**版本**: 1.149.0

### 2. AWS CLI ✅

**版本**: 2.32.16

---

## 📋 下一步：配置 AWS 凭证

### 步骤 1: 获取 AWS 访问密钥

1. **登录 [AWS Console](https://console.aws.amazon.com/)**
2. **点击右上角用户名 → Security credentials（安全凭证）**
3. **在 "Access keys" 部分，点击 "Create access key"**
4. **复制并保存：**
   - Access Key ID
   - Secret Access Key

⚠️ **重要**：Secret Access Key 只显示一次，请妥善保存！

### 步骤 2: 配置本地凭证

在本地终端执行：

```bash
# 配置 AWS 凭证
aws configure

# 按提示输入：
# AWS Access Key ID: 粘贴你的 Access Key ID
# AWS Secret Access Key: 粘贴你的 Secret Access Key
# Default region name: us-east-1  (或你的首选区域)
# Default output format: json
```

### 步骤 3: 验证配置

```bash
# 验证凭证是否正确
aws sts get-caller-identity

# 应该返回类似：
# {
#     "UserId": "AIDACKCEVSQ6C2EXAMPLE",
#     "Account": "123456789012",
#     "Arn": "arn:aws:iam::123456789012:user/username"
# }
```

---

## 🐳 安装 Docker（可选但推荐）

Docker 用于在本地测试 Lambda 函数，强烈推荐安装。

### 方式 1: 使用 Homebrew（推荐）

```bash
brew install --cask docker
```

安装后，从 Applications 文件夹启动 Docker Desktop。

### 方式 2: 下载安装包

访问 [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop)

---

## 🚀 SAM 常用命令

### 初始化新项目

```bash
sam init
```

### 构建项目

```bash
sam build
```

### 本地测试

```bash
# 启动本地 API
sam local start-api

# 调用单个函数
sam local invoke FunctionName -e events/event.json
```

### 部署到 AWS

```bash
# 首次部署（引导式）
sam deploy --guided

# 后续部署
sam deploy
```

### 查看日志

```bash
sam logs -n FunctionName --tail
```

### 删除栈

```bash
sam delete
```

---

## 📝 AWS 区域代码

常用区域：

- **us-east-1** - 美国东部（弗吉尼亚北部）
- **us-west-2** - 美国西部（俄勒冈）
- **ap-northeast-1** - 亚太地区（东京）
- **ap-southeast-1** - 亚太地区（新加坡）
- **eu-west-1** - 欧洲（爱尔兰）

选择离你和用户最近的区域以获得最佳性能。

---

## 🔒 安全建议

### 1. 使用 IAM 用户而非 Root 账户

创建专门的 IAM 用户用于开发，不要使用 AWS 根账户。

### 2. 设置 MFA（多因素认证）

为 IAM 用户启用 MFA 增加安全性。

### 3. 最小权限原则

只授予 IAM 用户必要的权限：

- AWSLambdaFullAccess
- AmazonDynamoDBFullAccess
- CloudFormationFullAccess
- IAMFullAccess (如果需要创建角色)
- AmazonS3FullAccess (用于部署包)

### 4. 轮换访问密钥

定期（建议每 90 天）轮换访问密钥。

### 5. 不要提交凭证到 Git

确保 `~/.aws/credentials` 不会被提交到代码仓库。

---

## 🐛 常见问题

### 问题 1: sam command not found

**解决**：重新打开终端，或执行 `source ~/.zshrc`

### 问题 2: AWS 凭证无效

**解决**：

```bash
# 重新配置
aws configure

# 检查配置文件
cat ~/.aws/credentials
cat ~/.aws/config
```

### 问题 3: Docker daemon not running

**解决**：启动 Docker Desktop 应用

### 问题 4: 权限不足

**解决**：检查 IAM 用户权限，确保有足够的权限创建资源

---

## 📚 参考资料

- [AWS SAM 官方文档](https://docs.aws.amazon.com/serverless-application-model/)
- [AWS CLI 配置](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)
- [Lambda 最佳实践](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)

---

## ✅ 安装检查清单

- [x] SAM CLI 已安装 (v1.149.0)
- [x] AWS CLI 已安装 (v2.32.16)
- [ ] AWS 凭证已配置
- [ ] Docker 已安装（可选）
- [ ] 测试 `sam init` 创建项目成功

完成配置后，你就可以开始使用 SAM 部署 Serverless 应用了！
