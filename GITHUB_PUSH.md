# 推送到 GitHub 指南

## 第一步：在 GitHub 创建仓库

1. 登录 https://github.com
2. 点击右上角 **+** → **New repository**
3. 填写仓库名（如 `todo-app`）
4. **不要勾选** "Add a README file"（因为我们的代码里已有）
5. 点击 **Create repository**

## 第二步：复制推送命令

创建仓库后，GitHub 会显示类似这样的命令，直接复制：

```bash
git remote add origin https://github.com/你的用户名/todo-app.git
git branch -M main
git push -u origin main
```

## 第三步：在本地执行

打开终端，进入项目目录：

```bash
cd /root/.openclaw/workspace/todo-app

# 初始化 Git
git init

# 添加所有文件
git add .

# 提交
git commit -m "feat: todo list app with Next.js + Supabase"

# 粘贴刚才从 GitHub 复制的两行命令
git remote add origin https://github.com/你的用户名/todo-app.git
git branch -M main
git push -u origin main
```

## ⚠️ 如果遇到权限问题

如果提示需要用户名/密码，说明需要用 **Personal Access Token** 或 **SSH**。

### 使用 Token 方式（最简单）：

1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. 点击 **Generate new token**
3. 勾选 `repo` 权限
4. 生成后复制 token
5. 推送时用 token 代替密码：
   ```bash
   git push -u origin main
   # 用户名：你的 GitHub 用户名
   # 密码：粘贴刚才生成的 token
   ```

## ✅ 完成

推送成功后，GitHub 仓库里就有完整代码了。然后可以到 Vercel 上：
1. 点击 **Add New Project**
2. 选择刚才推送的 `todo-app` 仓库
3. 环境变量会自动从 `.env.local` 读取（如果没有自动读取，手动填入）
4. 点击 **Deploy**

---

## 🔧 脚本方式

也提供了 `push-to-github.sh` 脚本，执行前需要先配置好远程仓库：

```bash
chmod +x push-to-github.sh
./push-to-github.sh
```
