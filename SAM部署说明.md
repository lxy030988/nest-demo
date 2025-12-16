# AWS SAM 快速部署

## 🚀 一键部署

```bash
./sam-deploy.sh
```

这个脚本会自动完成：

- ✅ 检查必要工具（SAM CLI, AWS CLI, pnpm）
- ✅ 验证 AWS 凭证
- ✅ 安装项目依赖
- ✅ 构建 NestJS 项目
- ✅ 验证 SAM 模板
- ✅ 构建并部署到 AWS
- ✅ 显示 API 端点和后续配置步骤

## 📋 部署后配置

部署完成后，需要配置 RDS 安全组以允许 Lambda 访问数据库。脚本会显示具体命令。

## 📚 详细文档

查看 [AWS-SAM-VPC部署指南.md](./AWS-SAM-VPC部署指南.md) 了解详细的部署步骤、架构说明和故障排查。

## 🔄 更新部署

修改代码后重新部署：

```bash
./sam-deploy.sh
```

## 🗑️ 删除部署

```bash
sam delete --stack-name nest-demo-stack
```

## ❓ 常见问题

### 部署会创建数据库吗？

**不会**。当前配置连接到您现有的 RDS 数据库。DATABASE_URL 从 .env 文件读取。

如果需要在部署时创建 RDS 数据库，请告知我可以修改模板。

### 需要什么权限？

需要 IAM 用户具有以下权限：

- Lambda 创建和管理
- VPC 和网络资源创建
- CloudFormation 堆栈管理
- S3 上传（用于部署包）
- API Gateway 创建

### 费用是多少？

主要成本：

- NAT Gateway: ~$32.4/月 + 数据传输费
- Lambda: 按使用量计费（有免费额度）
- API Gateway: 按请求数计费（有免费额度）

详见部署指南中的成本估算部分。
