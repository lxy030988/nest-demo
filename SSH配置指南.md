# EC2 SSH 密钥配置指南

本文档介绍如何配置 SSH 密钥对，实现从本地 Mac 免密码连接到 AWS EC2 服务器。

## 🎯 目标

- 生成 SSH 密钥对
- 配置 EC2 服务器接受密钥认证
- 实现本地 Mac 快捷连接

---

## 📝 完整步骤

### 步骤 1: 在本地 Mac 生成 SSH 密钥对

在本地终端执行：

```bash
# 生成 RSA 密钥对（4096 位）
ssh-keygen -t rsa -b 4096 -f ~/.ssh/aws-ec2-nest-demo

# 执行过程中会提示：
# Enter passphrase (empty for no passphrase):
# 可以直接回车跳过，或输入密码增加安全性
```

**生成的文件：**

- `~/.ssh/aws-ec2-nest-demo` - 私钥（保密，不要分享）
- `~/.ssh/aws-ec2-nest-demo.pub` - 公钥（可以公开）

### 步骤 2: 查看并复制公钥内容

```bash
# 查看公钥内容
cat ~/.ssh/aws-ec2-nest-demo.pub

# 输出示例：
# ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC... ec2-nest-demo
```

**复制全部输出内容**（从 `ssh-rsa` 开始到结尾）

### 步骤 3: 在 EC2 服务器上添加公钥

通过 EC2 Instance Connect 浏览器终端连接服务器，以 **root** 用户执行：

```bash
# 1. 创建 .ssh 目录（如果不存在）
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# 2. 编辑 authorized_keys 文件
nano ~/.ssh/authorized_keys

# 3. 粘贴刚才复制的公钥内容（新增一行）
# 按 Ctrl+X，然后 Y，然后 Enter 保存

# 4. 设置正确的权限
chmod 600 ~/.ssh/authorized_keys

# 5. 验证内容
cat ~/.ssh/authorized_keys
```

### 步骤 4: 配置 SSH 快捷连接（可选但推荐）

在本地 Mac 执行：

```bash
# 编辑 SSH 配置文件
nano ~/.ssh/config

# 添加以下内容：
Host nest-demo
  HostName 98.92.253.133
  User root
  Port 22
  IdentityFile ~/.ssh/aws-ec2-nest-demo
  ServerAliveInterval 60
  ServerAliveCountMax 3

# 保存退出 (Ctrl+X, Y, Enter)
```

**配置说明：**

- `Host nest-demo` - 连接别名
- `HostName` - EC2 公网 IP
- `User` - 登录用户（root 或 ubuntu）
- `IdentityFile` - 私钥文件路径
- `ServerAliveInterval` - 保持连接活跃

### 步骤 5: 测试连接

```bash
# 方式 1: 使用配置的别名（推荐）
ssh nest-demo

# 方式 2: 使用完整命令
ssh -i ~/.ssh/aws-ec2-nest-demo root@98.92.253.133
```

首次连接会提示：

```
The authenticity of host '98.92.253.133' can't be established.
Are you sure you want to continue connecting (yes/no)?
```

输入 `yes` 并回车。

---

## ✅ 验证成功

连接成功后会看到：

```
Welcome to Ubuntu 24.04 LTS
...
root@ip-172-31-67-239:~#
```

---

## 🔧 常用命令

### 连接服务器

```bash
ssh nest-demo
```

### 上传文件到服务器

```bash
# 上传单个文件
scp local-file.txt nest-demo:~/

# 上传整个目录
scp -r local-directory nest-demo:~/
```

### 从服务器下载文件

```bash
# 下载单个文件
scp nest-demo:~/remote-file.txt ./

# 下载整个目录
scp -r nest-demo:~/remote-directory ./
```

### 在服务器上执行命令（不登录）

```bash
ssh nest-demo "pm2 list"
ssh nest-demo "cd nest-demo && git pull"
```

---

## 🔒 安全建议

### 1. 保护私钥文件

```bash
# 私钥权限必须是 600（仅所有者可读写）
chmod 600 ~/.ssh/aws-ec2-nest-demo

# 永远不要分享或提交私钥到 Git
```

### 2. 使用密码保护私钥

生成密钥时设置 passphrase，增加一层安全保护。

### 3. 定期更换密钥

建议每 6-12 个月更换一次 SSH 密钥。

### 4. 禁用密码登录（可选）

在服务器上编辑 SSH 配置：

```bash
sudo nano /etc/ssh/sshd_config

# 修改以下配置：
# PasswordAuthentication no
# PubkeyAuthentication yes

# 重启 SSH 服务
sudo systemctl restart sshd
```

---

## 🐛 常见问题

### 问题 1: Permission denied (publickey)

**原因：** 公钥未正确添加或权限错误

**解决：**

```bash
# 在服务器上检查权限
ls -la ~/.ssh/
# 应该显示：
# drwx------ .ssh
# -rw------- authorized_keys

# 如果不对，执行：
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

### 问题 2: Connection timeout

**原因：** AWS 安全组未开放 22 端口

**解决：** 在 AWS Console 检查安全组入站规则，确保开放了 SSH (22端口)

### 问题 3: Host key verification failed

**原因：** 服务器重建或 IP 变更

**解决：**

```bash
# 删除旧的 host key
ssh-keygen -R 98.92.253.133

# 或编辑 known_hosts
nano ~/.ssh/known_hosts
# 删除对应 IP 的行
```

---

## 📚 参考资料

- [SSH 官方文档](https://www.openssh.com/manual.html)
- [AWS EC2 密钥对文档](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)

---

## 📝 服务器信息

- **SSH 连接**: `ssh -i ~/.ssh/aws-ec2-nest-demo root@98.92.253.133`
- **应用访问**: http://98.92.253.133:3002/
- **域名访问**: http://ec2-98-92-253-133.compute-1.amazonaws.com:3002/
