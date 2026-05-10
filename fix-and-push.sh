#!/bin/bash
set -e

echo "🔧 开始自动修复构建错误..."

cd "$(dirname "$0")"

# 修复 layout.tsx - 删除 Geist 字体
cat > src/app/layout.tsx << 'EOF'
import './globals.css'

export const metadata = {
  title: 'Todo List',
  description: '待办清单',
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="zh-CN">
      <body>{children}</body>
    </html>
  )
}
EOF

# 修复 page.tsx - 改用相对路径
cat > src/app/page.tsx << 'EOF'
import TodoList from './components/TodoList'

export default function Home() {
  return (
    <main>
      <TodoList />
    </main>
  )
}
EOF

# 确保 globals.css 无问题
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

# 清理旧的 .js 文件（如果有冲突）
rm -f src/app/layout.js src/app/page.js

# 提交并推送
git add .
git commit -m "fix: remove Geist fonts and @/ aliases for Vercel build" || echo "Nothing to commit"
git push

echo "✅ 修复完成并推送！"
echo "📍 请回到 Vercel 查看构建状态"
