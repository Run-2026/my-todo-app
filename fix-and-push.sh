#!/bin/bash
set -e

echo "🔧 开始全面修复..."
cd "$(dirname "$0")"

# 1. 删除所有可能冲突的文件
echo "🧹 清理冲突文件..."
rm -f tailwind.config.js postcss.config.js tailwind.config.ts postcss.config.ts
rm -f src/app/layout.tsx src/app/page.tsx
rm -f src/app/components/TodoList.tsx

# 2. 确保 .gitignore 正确
cat > .gitignore << 'EOF'
node_modules/
.next/
dist/
.env
.env.local
*.log
.DS_Store
EOF

# 3. 重写 package.json（无 Tailwind）
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

# 4. 重写 next.config.js
cat > next.config.js << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {}
module.exports = nextConfig
EOF

# 5. 重写 layout.js
cat > src/app/layout.js << 'EOF'
import './globals.css'

export const metadata = {
  title: 'Todo List',
  description: '待办清单',
}

export default function RootLayout({ children }) {
  return (
    <html lang="zh-CN">
      <body>{children}</body>
    </html>
  )
}
EOF

# 6. 重写 page.js
cat > src/app/page.js << 'EOF'
import TodoList from './components/TodoList'

export default function Home() {
  return (
    <main>
      <TodoList />
    </main>
  )
}
EOF

# 7. 重写 globals.css
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

# 8. 确保 supabase.js 存在
mkdir -p src/lib
cat > src/lib/supabase.js << 'EOF'
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseKey)
EOF

# 9. 提交并推送
echo "📤 提交并推送..."
git add .
git commit -m "fix: complete rebuild - remove tailwind and tsx conflicts" || true
git push

echo "✅ 修复完成！"
echo "📍 请回到 Vercel 查看构建状态"
echo ""
echo "如果仍然失败，请截图 Build Logs 的完整错误信息"
