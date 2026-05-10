#!/bin/bash
set -e

echo "🚀 开始推送到 GitHub..."

# 1. 进入项目目录
cd "$(dirname "$0")"

# 2. 初始化 Git（如果还没初始化）
if [ ! -d ".git" ]; then
    echo "📦 初始化 Git 仓库..."
    git init
fi

# 3. 检查是否有远程仓库
REMOTE_COUNT=$(git remote | wc -l)
if [ "$REMOTE_COUNT" -eq 0 ]; then
    echo ""
    echo "⚠️ 还没有配置远程仓库"
    echo "请先登录 GitHub 创建一个新仓库（不要勾选 README）"
    echo "然后运行：git remote add origin https://github.com/你的用户名/仓库名.git"
    echo ""
    exit 1
fi

# 4. 添加所有文件
echo "📁 添加文件..."
git add .

# 5. 提交
echo "💾 提交更改..."
git commit -m "feat: todo list app with Next.js + Supabase" || echo "没有什么可提交的"

# 6. 推送到 GitHub
echo "☁️ 推送到 GitHub..."
git push -u origin main || git push -u origin master

echo "✅ 完成！"
