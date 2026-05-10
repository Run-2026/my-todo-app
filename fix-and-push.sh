#!/bin/bash
set -e

echo "🔧 终极清理：删除所有 Tailwind/PostCSS 残留..."
cd "$(dirname "$0")"

# 删除本地所有可能的 tailwind/postcss 配置文件（包括所有扩展名变体）
echo "🧹 删除所有 tailwind/postcss 配置文件..."
rm -f postcss.config.js postcss.config.mjs postcss.config.cjs postcss.config.ts
rm -f tailwind.config.js tailwind.config.mjs tailwind.config.cjs tailwind.config.ts
rm -f package-lock.json yarn.lock pnpm-lock.yaml

# 确保 package.json 绝对干净
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
  }
}
EOF

# 确保 globals.css 绝对干净（没有任何 @tailwind 指令）
cat > src/app/globals.css << 'EOF'
* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 20px;
}
EOF

# 确保 .gitignore 正确
cat > .gitignore << 'EOF'
node_modules/
.next/
dist/
.env
.env.local
.env.*.local
*.log
.DS_Store
Thumbs.db
EOF

echo "📤 提交更改..."
git add .

# 先尝试从 git 仓库中强制删除可能存在的旧文件
git rm -f postcss.config.js postcss.config.mjs postcss.config.cjs postcss.config.ts 2>/dev/null || true
git rm -f tailwind.config.js tailwind.config.mjs tailwind.config.cjs tailwind.config.ts 2>/dev/null || true
git rm -f package-lock.json yarn.lock pnpm-lock.yaml 2>/dev/null || true

git commit -m "fix: completely purge tailwind/postcss and lock files" || true

echo "☁️ 推送到 GitHub..."
git push

echo ""
echo "✅ 推送完成！"
echo "📍 请回到 Vercel 查看构建状态"
echo ""
echo "如果仍然失败，请截图 Vercel Build Logs 的完整错误信息"
