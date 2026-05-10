#!/bin/bash
set -e

echo "🔧 强制删除 tsconfig.json 和 TypeScript 文件..."
cd "$(dirname "$0")"

# 删除本地 tsconfig.json（如果存在）
rm -f tsconfig.json

# 删除所有 .tsx 文件
find src -name "*.tsx" -type f -delete 2>/dev/null || true

# 从 git 仓库中强制删除
git rm -f tsconfig.json 2>/dev/null || true

git add .
git commit -m "fix: remove tsconfig.json and all TypeScript files" || true

git push

echo "✅ 已强制删除 tsconfig.json"
echo "📍 请回到 Vercel 点击 Redeploy（不勾选缓存）"
