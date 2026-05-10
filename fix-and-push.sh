#!/bin/bash
set -e

echo "🔧 彻底清理 Tailwind 并推送..."
cd "$(dirname "$0")"

# 删除所有 tailwind 相关文件
rm -f postcss.config.js postcss.config.ts
rm -f tailwind.config.js tailwind.config.ts

# 确保 package.json 没有 tailwind
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

# 确保 globals.css 没有 @tailwind
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

# 提交并推送
git add .
git commit -m "fix: completely remove tailwind and postcss config" || true

# 如果 GitHub 上还有旧文件，强制删除
git rm -f postcss.config.js tailwind.config.js 2>/dev/null || true
git commit -m "fix: remove tailwind files from git" || true

git push

echo "✅ 清理完成！请回到 Vercel 查看构建状态"
