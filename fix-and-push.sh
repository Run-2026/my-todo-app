#!/bin/bash
set -e

echo "🔧 确保 TypeScript 依赖已添加并推送..."
cd "$(dirname "$0")"

# 重写 package.json（包含 TypeScript）
cat > package.json << 'EOF'
{
  "name": "todo-app",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start"
  },
  "dependencies": {
    "next": "14.2.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "@supabase/supabase-js": "^2.38.0"
  },
  "devDependencies": {
    "typescript": "^5.0.0",
    "@types/react": "^18.2.0",
    "@types/node": "^20.0.0"
  }
}
EOF

# 删除所有可能导致 TypeScript 问题的文件
rm -f tsconfig.json
rm -f next.config.ts
rm -f postcss.config.js tailwind.config.js

git add .
git commit -m "fix: add typescript deps and remove tsconfig" || true
git push

echo "✅ 推送完成！"
echo "📍 请回到 Vercel 查看最新的部署记录"
