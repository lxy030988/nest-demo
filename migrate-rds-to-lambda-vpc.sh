#!/bin/bash
# RDS迁移到Lambda VPC的脚本
set -e

echo "🔄 RDS数据库迁移到Lambda VPC"
echo "================================"

# 配置
OLD_DB="database-nest-demo"
SNAPSHOT_ID="nest-demo-migration-$(date +%Y%m%d-%H%M%S)"
NEW_DB="database-nest-demo-new"

# Lambda VPC信息
VPC_ID="vpc-018e25430281bdb1b"
SUBNET_IDS="subnet-0bf0b91dc38d3361c,subnet-00b27915613684c03,subnet-0c12cbecf0c33565a"
LAMBDA_SG="sg-06f50247d4bf43ccb"

echo "📸 步骤1: 创建当前数据库快照..."
aws rds create-db-snapshot \
  --db-instance-identifier $OLD_DB \
  --db-snapshot-identifier $SNAPSHOT_ID

echo "⏳ 等待快照完成..."
aws rds wait db-snapshot-completed --db-snapshot-identifier $SNAPSHOT_ID
echo "✅ 快照创建完成: $SNAPSHOT_ID"

echo ""
echo "📋 步骤2: 创建DB子网组..."
aws rds create-db-subnet-group \
  --db-subnet-group-name nest-demo-lambda-vpc-subnet-group \
  --db-subnet-group-description "Subnet group for Lambda VPC" \
  --subnet-ids $SUBNET_IDS \
  --tags Key=Name,Value=nest-demo-lambda-vpc 2>/dev/null || echo "子网组可能已存在"

echo ""
echo "🔒 步骤3: 创建RDS安全组..."
RDS_SG=$(aws ec2 create-security-group \
  --group-name nest-demo-rds-sg \
  --description "RDS security group in Lambda VPC" \
  --vpc-id $VPC_ID \
  --query 'GroupId' \
  --output text) || echo "安全组可能已存在"

# 允许Lambda访问RDS
aws ec2 authorize-security-group-ingress \
  --group-id $RDS_SG \
  --protocol tcp \
  --port 5432 \
  --source-group $LAMBDA_SG || echo "规则可能已存在"

echo "✅ RDS安全组: $RDS_SG"

echo ""
echo "🚀 步骤4: 从快照恢复到新VPC..."
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier $NEW_DB \
  --db-snapshot-identifier $SNAPSHOT_ID \
  --db-subnet-group-name nest-demo-lambda-vpc-subnet-group \
  --vpc-security-group-ids $RDS_SG \
  --publicly-accessible

echo "⏳ 等待新数据库可用（约5-10分钟）..."
aws rds wait db-instance-available --db-instance-identifier $NEW_DB

echo ""
echo "📝 步骤5: 获取新数据库端点..."
NEW_ENDPOINT=$(aws rds describe-db-instances \
  --db-instance-identifier $NEW_DB \
  --query 'DBInstances[0].Endpoint.Address' \
  --output text)

echo ""
echo "✅ 迁移完成！"
echo "================================"
echo ""
echo "新数据库端点: $NEW_ENDPOINT"
echo ""
echo "📋 下一步操作："
echo "1. 更新 .env 中的 DATABASE_URL:"
echo "   DATABASE_URL=\"postgresql://postgres:NestDemo123!@$NEW_ENDPOINT:5432/postgres?schema=public\""
echo ""
echo "2. 重新部署Lambda:"
echo "   ./deploy-lambda.sh"
echo ""
echo "3. 测试新数据库连接"
echo ""
echo "4. 确认无误后，删除旧数据库:"
echo "   aws rds delete-db-instance --db-instance-identifier $OLD_DB --skip-final-snapshot"
echo ""
echo "⚠️  注意：VPC内的RDS将无法从公网直接访问"
