# NestJS Demo Project

一个使用 NestJS + Prisma + PostgreSQL (AWS RDS) 构建的现代化 RESTful API 项目。

## 🚀 技术栈

- **框架**: NestJS 11.1.9
- **ORM**: Prisma 7.1.0
- **数据库**: PostgreSQL (AWS RDS)
- **语言**: TypeScript
- **包管理器**: pnpm
- **验证**: class-validator, class-transformer

## 📁 项目结构

```
nest-demo/
├── src/
│   ├── common/              # 公共模块
│   │   ├── filters/         # 异常过滤器
│   │   ├── interceptors/    # 拦截器（响应转换、日志等）
│   │   └── middlewares/     # 中间件
│   ├── modules/             # 业务模块
│   │   ├── users/           # 用户模块
│   │   │   ├── dto/         # 数据传输对象
│   │   │   ├── entities/    # 实体类
│   │   │   ├── users.controller.ts
│   │   │   ├── users.service.ts
│   │   │   └── users.module.ts
│   │   └── posts/           # 文章模块
│   │       ├── dto/
│   │       ├── entities/
│   │       ├── posts.controller.ts
│   │       ├── posts.service.ts
│   │       └── posts.module.ts
│   ├── prisma/              # Prisma 数据库模块
│   │   ├── prisma.service.ts
│   │   └── prisma.module.ts
│   ├── app.module.ts        # 根模块
│   ├── app.controller.ts    # 根控制器
│   ├── app.service.ts       # 根服务
│   └── main.ts              # 应用入口
├── prisma/
│   ├── schema.prisma        # 数据库 Schema 定义
│   └── migrations/          # 数据库迁移文件
├── public/                  # 静态资源（HTML页面）
├── .env                     # 环境变量
└── package.json
```

## 🏗️ 架构说明

### 1. **分层架构**

```
Client Request
    ↓
Middleware (日志、认证等)
    ↓
Controller (路由处理)
    ↓
Service (业务逻辑)
    ↓
Prisma Service (数据访问)
    ↓
PostgreSQL Database
```

### 2. **核心组件**

#### **Controller (控制器)**

- 位置: `src/modules/*/\*.controller.ts`
- 职责: 处理 HTTP 请求，定义路由，调用 Service
- 示例:

```typescript
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  findAll() {
    return this.usersService.findAll();
  }
}
```

#### **Service (服务)**

- 位置: `src/modules/*/\*.service.ts`
- 职责: 业务逻辑处理，数据库操作
- 示例:

```typescript
@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.user.findMany({ include: { posts: true } });
  }
}
```

#### **Module (模块)**

- 位置: `src/modules/*/\*.module.ts`
- 职责: 组织相关的 Controllers 和 Services
- 示例:

```typescript
@Module({
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService], // 如果需要被其他模块使用
})
export class UsersModule {}
```

#### **DTO (数据传输对象)**

- 位置: `src/modules/*/dto/`
- 职责: 定义API接口的输入输出数据结构，数据验证
- 示例:

```typescript
export class CreateUserDto {
  @IsEmail()
  readonly email: string;

  @IsString()
  @IsOptional()
  readonly name?: string;
}
```

### 3. **Prisma 数据库层**

#### **Prisma Schema**

- 文件: `prisma/schema.prisma`
- 定义数据库表结构和关系

```prisma
model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  name      String?
  posts     Post[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model Post {
  id        Int      @id @default(autoincrement())
  title     String
  content   String?
  published Boolean  @default(false)
  authorId  Int
  author    User     @relation(fields: [authorId], references: [id], onDelete: Cascade)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

#### **Prisma Service**

- 文件: `src/prisma/prisma.service.ts`
- 全局单例，管理数据库连接

## 🛣️ API 路由

### 用户相关 (`/users`)

| 方法   | 路径         | 描述                   |
| ------ | ------------ | ---------------------- |
| POST   | `/users`     | 创建用户               |
| GET    | `/users`     | 获取所有用户（含文章） |
| GET    | `/users/:id` | 获取单个用户           |
| PATCH  | `/users/:id` | 更新用户               |
| DELETE | `/users/:id` | 删除用户               |

### 文章相关 (`/posts`)

| 方法   | 路径                      | 描述                   |
| ------ | ------------------------- | ---------------------- |
| POST   | `/posts`                  | 创建文章               |
| GET    | `/posts`                  | 获取所有文章（含作者） |
| GET    | `/posts/:id`              | 获取单个文章           |
| GET    | `/posts/author/:authorId` | 获取指定作者的文章     |
| PATCH  | `/posts/:id`              | 更新文章               |
| DELETE | `/posts/:id`              | 删除文章               |

### 示例请求

**创建用户:**

```bash
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","name":"John Doe"}'
```

**创建文章:**

```bash
curl -X POST http://localhost:3000/posts \
  -H "Content-Type: application/json" \
  -d '{"title":"Hello","content":"My post","authorId":1,"published":true}'
```

## 📦 数据库配置

### 环境变量 (`.env`)

```bash
DATABASE_URL="postgresql://postgres:password@host:5432/database?schema=public&sslmode=require"
```

### Prisma 迁移

```bash
# 创建新迁移
npx prisma migrate dev --name migration_name

# 应用迁移到生产环境
npx prisma migrate deploy

# 重新生成 Prisma Client
npx prisma generate
```

## 🔨 开发新功能指南

### 方法 1: 使用 NestJS CLI (推荐)

#### 1. 生成新模块

```bash
nest g module modules/feature-name
```

#### 2. 生成 Controller

```bash
nest g controller modules/feature-name
```

#### 3. 生成 Service

```bash
nest g service modules/feature-name
```

#### 4. 生成 DTO

```bash
# 手动创建或使用
nest g class modules/feature-name/dto/create-feature.dto --no-spec
```

### 方法 2: 手动创建

#### 步骤 1: 定义数据库模型

编辑 `prisma/schema.prisma`:

```prisma
model Feature {
  id        Int      @id @default(autoincrement())
  name      String
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

运行迁移:

```bash
npx prisma migrate dev --name add_feature
```

#### 步骤 2: 创建 DTO

创建 `src/modules/features/dto/create-feature.dto.ts`:

```typescript
import { IsString, IsNotEmpty } from 'class-validator';

export class CreateFeatureDto {
  @IsString()
  @IsNotEmpty()
  readonly name: string;
}
```

创建 `update-feature.dto.ts`:

```typescript
import { PartialType } from '@nestjs/mapped-types';
import { CreateFeatureDto } from './create-feature.dto';

export class UpdateFeatureDto extends PartialType(CreateFeatureDto) {}
```

#### 步骤 3: 创建 Service

创建 `src/modules/features/features.service.ts`:

```typescript
import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateFeatureDto } from './dto/create-feature.dto';
import { UpdateFeatureDto } from './dto/update-feature.dto';

@Injectable()
export class FeaturesService {
  constructor(private readonly prisma: PrismaService) {}

  async create(createFeatureDto: CreateFeatureDto) {
    return this.prisma.feature.create({
      data: createFeatureDto,
    });
  }

  async findAll() {
    return this.prisma.feature.findMany();
  }

  async findOne(id: number) {
    return this.prisma.feature.findUnique({ where: { id } });
  }

  async update(id: number, updateFeatureDto: UpdateFeatureDto) {
    return this.prisma.feature.update({
      where: { id },
      data: updateFeatureDto,
    });
  }

  async remove(id: number) {
    return this.prisma.feature.delete({ where: { id } });
  }
}
```

#### 步骤 4: 创建 Controller

创建 `src/modules/features/features.controller.ts`:

```typescript
import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  ParseIntPipe,
} from '@nestjs/common';
import { FeaturesService } from './features.service';
import { CreateFeatureDto } from './dto/create-feature.dto';
import { UpdateFeatureDto } from './dto/update-feature.dto';

@Controller('features')
export class FeaturesController {
  constructor(private readonly featuresService: FeaturesService) {}

  @Post()
  create(@Body() createFeatureDto: CreateFeatureDto) {
    return this.featuresService.create(createFeatureDto);
  }

  @Get()
  findAll() {
    return this.featuresService.findAll();
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.featuresService.findOne(id);
  }

  @Patch(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateFeatureDto: UpdateFeatureDto,
  ) {
    return this.featuresService.update(id, updateFeatureDto);
  }

  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.featuresService.remove(id);
  }
}
```

#### 步骤 5: 创建 Module

创建 `src/modules/features/features.module.ts`:

```typescript
import { Module } from '@nestjs/common';
import { FeaturesController } from './features.controller';
import { FeaturesService } from './features.service';

@Module({
  controllers: [FeaturesController],
  providers: [FeaturesService],
  exports: [FeaturesService], // 如果其他模块需要使用
})
export class FeaturesModule {}
```

#### 步骤 6: 注册到 AppModule

编辑 `src/app.module.ts`:

```typescript
import { FeaturesModule } from './modules/features/features.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    UsersModule,
    PostsModule,
    FeaturesModule, // 添加新模块
  ],
  // ...
})
export class AppModule {}
```

## 🎯 最佳实践

### 1. **错误处理**

- 使用 NestJS 内置的异常类（`NotFoundException`, `BadRequestException` 等）
- 全局异常过滤器已配置，自动处理错误响应

### 2. **数据验证**

- 使用 DTO + class-validator 自动验证请求数据
- 全局 ValidationPipe 已启用

### 3. **数据库操作**

- 始终使用 Prisma Service 进行数据库操作
- 利用 Prisma 的类型安全特性
- 使用 `include` 获取关联数据

### 4. **代码组织**

- 按功能模块组织代码
- 每个模块包含自己的 controller, service, dto
- 共享代码放在 `common/` 目录

## 🚀 快速开始

### 安装依赖

```bash
pnpm install
```

### 配置环境变量

创建 `.env` 文件:

```bash
DATABASE_URL="your_database_connection_string"
```

### 运行数据库迁移

```bash
npx prisma migrate dev
```

### 启动开发服务器

```bash
pnpm run start:dev
```

应用将运行在 `http://localhost:3000`

## 📚 更多资源

- [NestJS 官方文档](https://docs.nestjs.com)
- [Prisma 官方文档](https://www.prisma.io/docs)
- [TypeScript 官方文档](https://www.typescriptlang.org/docs)

## 📝 License

MIT
