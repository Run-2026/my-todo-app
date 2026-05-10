#!/bin/bash
set -e

echo "🔧 修复 React/SWC 兼容性问题..."
cd "$(dirname "$0")"

# 更新 next.config.js
cat > next.config.js << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  swcMinify: false,
  experimental: {
    forceSwcTransforms: true
  }
}

module.exports = nextConfig
EOF

git add .
git commit -m "fix: disable swcMinify to resolve React compatibility" || true
git push

echo "✅ 推送完成！"
echo "📍 请回到 Vercel 查看构建状态"