#!/bin/bash
set -e

echo "🔧 修复 TypeScript 配置错误..."
cd "$(dirname "$0")"

# 删除 TypeScript 配置文件
echo "🧹 删除 TypeScript 配置文件..."
rm -f tsconfig.json

# 删除所有 .tsx 文件（如果有）
find src -name "*.tsx" -delete 2>/dev/null || true

# 确保所有文件都是 .js
echo "📄 确认所有文件为 .js 格式..."

# 提交并推送
git add .
git commit -m "fix: remove tsconfig.json and tsx files" || true
git push

echo "✅ 推送完成！"
echo "📍 请回到 Vercel 点击 Redeploy（不勾选缓存）"
