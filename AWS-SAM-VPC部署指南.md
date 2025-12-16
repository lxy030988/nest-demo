# AWS SAM VPC 部署指南

本指南介绍如何使用 AWS SAM 将 NestJS 应用部署到 Lambda，并配置 VPC 使 Lambda 能够访问 RDS 数据库。

## 架构概览

```
Internet
    ↓
Internet Gateway
    ↓
Public Subnet (10.0.1.0/24)
    ├── NAT Gateway
    └── Elastic IP
        ↓
Private Subnets (Lambda 部署)
    ├── 10.0.11.0/24 (us-east-1a)
    ├── 10.0.12.0/24 (us-east-1b)
    └── 10.0.13.0/24 (us-east-1c)
        ↓
    Lambda Functions → RDS Database
```

## 前置条件

### 1. AWS 凭证配置

确保已配置 AWS CLI 凭证：

```bash
aws configure
# 或检查现有配置
aws sts get-caller-identity
```

### 2. 安装依赖

```bash
cd /Users/lxy/Desktop/lxy030988/nest-demo
pnpm install
```

这将安装：

- `@vendia/serverless-express` - 在 Lambda 中运行 Express/NestJS
- `@types/aws-lambda` - Lambda TypeScript 类型定义

### 3. 构建项目

```bash
pnpm build
```

## 部署步骤

### 步骤 1: 验证 SAM 模板

```bash
sam validate --lint
```

预期输出：`template.yaml is a valid SAM Template`

### 步骤 2: 构建 SAM 应用

```bash
sam build
```

SAM 将使用 esbuild 打包 Lambda 函数，包括所有依赖项。

### 步骤 3: 部署到 AWS

**首次部署（引导模式）**：

```bash
sam deploy --guided
```

按提示输入（建议值）：

```
Stack Name [nest-demo-stack]: nest-demo-stack
AWS Region [us-east-1]: us-east-1
Parameter Environment [production]: production
Parameter DatabaseUrl []: postgresql://postgres:密码@database-nest-demo.ck3yiciost9r.us-east-1.rds.amazonaws.com:5432/postgres?schema=public
#Shows you resources changes to be deployed and require a 'Y' to initiate deploy
Confirm changes before deploy [Y/n]: Y
#SAM needs permission to be able to create roles to connect to the resources in your template
Allow SAM CLI IAM role creation [Y/n]: Y
#Preserves the state of previously provisioned resources when an operation fails
Disable rollback [y/N]: N
NestJSFunction has no authentication. Is this okay? [y/N]: y
Save arguments to configuration file [Y/n]: Y
SAM configuration file [samconfig.toml]: samconfig.toml
SAM configuration environment [default]: default
```

> [!IMPORTANT]
> 将 `DatabaseUrl` 参数中的密码替换为您的实际 RDS 密码！

**后续部署**：

```bash
sam deploy
```

### 步骤 4: 配置 RDS 安全组

部署完成后，需要更新 RDS 数据库的安全组，允许 Lambda 访问。

1. **获取 Lambda 安全组 ID**：

```bash
aws cloudformation describe-stacks \
  --stack-name nest-demo-stack \
  --query 'Stacks[0].Outputs[?OutputKey==`LambdaSecurityGroupId`].OutputValue' \
  --output text
```

记录输出的安全组 ID（例如：`sg-0123456789abcdef0`）

2. **更新 RDS 安全组**：

在 AWS Console 中：

- 进入 RDS → 数据库 → `database-nest-demo`
- 点击 VPC 安全组
- 添加入站规则：
  - 类型: PostgreSQL
  - 端口: 5432
  - 源: Lambda 安全组 ID（从上一步获取）
  - 描述: Allow access from Lambda

或使用 CLI：

```bash
# 首先获取 RDS 安全组 ID
RDS_SG_ID=$(aws rds describe-db-instances \
  --db-instance-identifier database-nest-demo \
  --query 'DBInstances[0].VpcSecurityGroups[0].VpcSecurityGroupId' \
  --output text)

# 获取 Lambda 安全组 ID
LAMBDA_SG_ID=$(aws cloudformation describe-stacks \
  --stack-name nest-demo-stack \
  --query 'Stacks[0].Outputs[?OutputKey==`LambdaSecurityGroupId`].OutputValue' \
  --output text)

# 添加入站规则
aws ec2 authorize-security-group-ingress \
  --group-id $RDS_SG_ID \
  --protocol tcp \
  --port 5432 \
  --source-group $LAMBDA_SG_ID \
  --group-owner-id $(aws sts get-caller-identity --query Account --output text)
```

## 测试部署

### 1. 获取 API 端点

```bash
aws cloudformation describe-stacks \
  --stack-name nest-demo-stack \
  --query 'Stacks[0].Outputs[?OutputKey==`ApiUrl`].OutputValue' \
  --output text
```

### 2. 测试 API 端点

```bash
# 设置 API URL
API_URL=$(aws cloudformation describe-stacks \
  --stack-name nest-demo-stack \
  --query 'Stacks[0].Outputs[?OutputKey==`ApiUrl`].OutputValue' \
  --output text)

# 测试根路径
curl $API_URL

# 测试用户列表
curl ${API_URL}users

# 创建用户
curl -X POST ${API_URL}users \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","name":"Test User"}'

# 获取用户详情
curl ${API_URL}users/1
```

### 3. 查看日志

```bash
sam logs -n NestJSFunction --stack-name nest-demo-stack --tail
```

或在 AWS Console 中查看 CloudWatch Logs。

## VPC 配置详情

### 子网配置

| 子网类型  | CIDR         | 可用区     | 用途        |
| --------- | ------------ | ---------- | ----------- |
| Public    | 10.0.1.0/24  | us-east-1a | NAT Gateway |
| Private 1 | 10.0.11.0/24 | us-east-1a | Lambda 函数 |
| Private 2 | 10.0.12.0/24 | us-east-1b | Lambda 函数 |
| Private 3 | 10.0.13.0/24 | us-east-1c | Lambda 函数 |

### 路由配置

**公共子网路由表**:

- `0.0.0.0/0` → Internet Gateway

**私有子网路由表**:

- `0.0.0.0/0` → NAT Gateway

### 安全组规则

**Lambda 安全组出站规则**:

- PostgreSQL (5432) → 0.0.0.0/0
- HTTPS (443) → 0.0.0.0/0

## 成本估算

| 资源                 | 估算成本                       |
| -------------------- | ------------------------------ |
| NAT Gateway          | ~$0.045/小时 (~$32.4/月)       |
| NAT Gateway 数据传输 | $0.045/GB                      |
| Lambda 请求          | 前 100 万免费，之后 $0.20/百万 |
| Lambda 计算时间      | 前 40 万 GB-秒免费             |
| API Gateway          | 前 100 万免费，之后 $1.00/百万 |

## 故障排查

### 问题: Lambda 无法连接到 RDS

**解决方法**:

1. 检查 RDS 安全组是否允许 Lambda 安全组访问端口 5432
2. 确认 RDS 和 Lambda 在同一区域
3. 检查 DATABASE_URL 环境变量是否正确

```bash
# 检查 Lambda 环境变量
aws lambda get-function-configuration \
  --function-name nest-demo-stack-nestjs-api \
  --query 'Environment.Variables'
```

### 问题: Lambda 超时

**解决方法**:

1. 增加 Lambda 超时时间（在 template.yaml 中修改 `Timeout`）
2. 检查 Prisma 连接是否正确建立
3. 查看 CloudWatch Logs 了解详细错误

### 问题: 冷启动时间过长

**解决方法**:

1. 考虑使用 Lambda 预留并发
2. 优化依赖包大小
3. 使用 Lambda SnapStart（需要 Java 运行时）

### 问题: NAT Gateway 成本过高

**替代方案**:
使用 VPC 端点替代 NAT Gateway（如果 Lambda 只需要访问 AWS 服务）：

```yaml
# 在 template.yaml 中添加
S3VPCEndpoint:
  Type: AWS::EC2::VPCEndpoint
  Properties:
    VpcId: !Ref VPC
    ServiceName: !Sub com.amazonaws.${AWS::Region}.s3
    RouteTableIds:
      - !Ref PrivateRouteTable
```

## 清理资源

删除整个堆栈：

```bash
sam delete --stack-name nest-demo-stack
```

> [!WARNING]
> 这将删除所有资源，包括 VPC、NAT Gateway 和 Lambda 函数，但不会删除 RDS 数据库。

## 监控和日志

### CloudWatch 指标

在 AWS Console 中查看：

- Lambda → Functions → nest-demo-stack-nestjs-api → Monitoring

关键指标：

- Invocations（调用次数）
- Duration（执行时间）
- Error count（错误数）
- Throttles（限流次数）

### CloudWatch Logs

```bash
# 实时查看日志
sam logs -n NestJSFunction --stack-name nest-demo-stack --tail

# 查看最近的日志
sam logs -n NestJSFunction --stack-name nest-demo-stack --start-time '5min ago'
```

## 性能优化

### 1. 启用 Lambda 响应流

对于大响应，可以启用响应流减少延迟。

### 2. 使用预留并发

```yaml
ReservedConcurrentExecutions: 5
```

### 3. 优化 Prisma 连接

在 Lambda 环境中，使用连接池：

```typescript
// 在 prisma.service.ts 中
const prisma = new PrismaClient({
  log: ['error'],
  datasources: {
    db: {
      url: process.env.DATABASE_URL,
    },
  },
});
```

## 下一步

- [ ] 配置自定义域名
- [ ] 添加 CloudWatch 告警
- [ ] 实现 CI/CD 管道
- [ ] 配置 WAF 保护
- [ ] 启用 X-Ray 追踪
