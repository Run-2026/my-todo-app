#!/bin/bash
set -e

echo "🚀 创建 Next.js Todo List 项目..."

# 1. 创建 Next.js 项目
echo "📦 正在初始化 Next.js 项目（需要几分钟）..."
npx create-next-app@latest todo-app --typescript --tailwind --eslint --app --src-dir --turbopack --use-npm

cd todo-app

# 2. 安装 Supabase 依赖
echo "📦 安装 Supabase 依赖..."
npm install @supabase/supabase-js @supabase/ssr

# 3. 创建目录结构
mkdir -p src/lib src/components supabase/migrations

# 4. 写入所有文件

cat > src/lib/database.types.ts << 'EOF'
export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  public: {
    Tables: {
      todos: {
        Row: {
          completed: boolean
          created_at: string
          id: string
          title: string
        }
        Insert: {
          completed?: boolean
          created_at?: string
          id?: string
          title: string
        }
        Update: {
          completed?: boolean
          created_at?: string
          id?: string
          title?: string
        }
        Relationships: []
      }
    }
    Views: { [_ in never]: never }
    Functions: { [_ in never]: never }
    Enums: { [_ in never]: never }
    CompositeTypes: { [_ in never]: never }
  }
}
EOF

cat > src/lib/supabase.ts << 'EOF'
import { createBrowserClient } from '@supabase/ssr'
import { Database } from './database.types'

export function createClient() {
  return createBrowserClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}
EOF

cat > src/components/TodoList.tsx << 'EOF'
'use client'

import { useState, useEffect, useCallback } from 'react'
import { createClient } from '@/lib/supabase'
import { Todo } from '@/lib/database.types'

export default function TodoList() {
  const [todos, setTodos] = useState<Todo[]>([])
  const [newTodo, setNewTodo] = useState('')
  const [loading, setLoading] = useState(true)
  const supabase = createClient()

  const fetchTodos = useCallback(async () => {
    const { data, error } = await supabase
      .from('todos')
      .select('*')
      .order('created_at', { ascending: false })

    if (error) {
      console.error('获取任务失败:', error)
      return
    }

    setTodos(data || [])
    setLoading(false)
  }, [supabase])

  useEffect(() => {
    fetchTodos()

    const channel = supabase
      .channel('todos_changes')
      .on(
        'postgres_changes',
        { event: '*', schema: 'public', table: 'todos' },
        () => {
          fetchTodos()
        }
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [fetchTodos, supabase])

  const addTodo = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!newTodo.trim()) return

    const { error } = await supabase
      .from('todos')
      .insert([{ title: newTodo.trim(), completed: false }])

    if (error) {
      console.error('添加任务失败:', error)
      return
    }

    setNewTodo('')
    fetchTodos()
  }

  const toggleTodo = async (id: string, completed: boolean) => {
    const { error } = await supabase
      .from('todos')
      .update({ completed: !completed })
      .eq('id', id)

    if (error) {
      console.error('更新任务失败:', error)
      return
    }

    fetchTodos()
  }

  const deleteTodo = async (id: string) => {
    const { error } = await supabase
      .from('todos')
      .delete()
      .eq('id', id)

    if (error) {
      console.error('删除任务失败:', error)
      return
    }

    fetchTodos()
  }

  if (loading) {
    return <div className="text-center py-8">加载中...</div>
  }

  return (
    <div className="max-w-md mx-auto">
      <form onSubmit={addTodo} className="mb-6 flex gap-2">
        <input
          type="text"
          value={newTodo}
          onChange={(e) => setNewTodo(e.target.value)}
          placeholder="输入新任务..."
          className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
        <button
          type="submit"
          className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
        >
          添加
        </button>
      </form>

      <div className="space-y-2">
        {todos.length === 0 ? (
          <div className="text-center text-gray-500 py-8">
            暂无任务，添加一个吧！
          </div>
        ) : (
          todos.map((todo) => (
            <div
              key={todo.id}
              className="flex items-center gap-3 p-3 bg-white border border-gray-200 rounded-lg shadow-sm hover:shadow-md transition-shadow"
            >
              <input
                type="checkbox"
                checked={todo.completed}
                onChange={() => toggleTodo(todo.id, todo.completed)}
                className="w-5 h-5 text-blue-500 rounded focus:ring-blue-500"
              />
              <span
                className={`flex-1 ${
                  todo.completed
                    ? 'line-through text-gray-400'
                    : 'text-gray-700'
                }`}
              >
                {todo.title}
              </span>
              <button
                onClick={() => deleteTodo(todo.id)}
                className="px-3 py-1 text-red-500 hover:bg-red-50 rounded transition-colors text-sm"
              >
                删除
              </button>
            </div>
          ))
        )}
      </div>

      {todos.length > 0 && (
        <div className="mt-4 text-sm text-gray-500 text-center">
          共 {todos.length} 个任务，
          {todos.filter((t) => t.completed).length} 个已完成
        </div>
      )}
    </div>
  )
}
EOF

cat > src/app/layout.tsx << 'EOF'
import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Todo List - 待办清单",
  description: "使用 Next.js + Supabase 构建的待办清单应用",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="zh-CN">
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased bg-gray-50 min-h-screen`}
      >
        {children}
      </body>
    </html>
  );
}
EOF

cat > src/app/page.tsx << 'EOF'
import TodoList from "@/components/TodoList";

export default function Home() {
  return (
    <main className="container mx-auto px-4 py-8 max-w-2xl">
      <h1 className="text-3xl font-bold text-center mb-8 text-gray-800">
        待办清单
      </h1>
      <TodoList />
    </main>
  );
}
EOF

cat > src/app/globals.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
  --foreground-rgb: 0, 0, 0;
}

body {
  color: rgb(var(--foreground-rgb));
}
EOF

cat > supabase/migrations/001_create_todos.sql << 'EOF'
CREATE TABLE todos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE todos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read" ON todos FOR SELECT USING (true);
CREATE POLICY "Allow public insert" ON todos FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update" ON todos FOR UPDATE USING (true);
CREATE POLICY "Allow public delete" ON todos FOR DELETE USING (true);
EOF

cat > .env.local.example << 'EOF'
NEXT_PUBLIC_SUPABASE_URL=https://你的项目.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=你的anon密钥
EOF

cat > next.config.ts << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
}

module.exports = nextConfig
EOF

cat > tailwind.config.ts << 'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
};
EOF

cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
EOF

cat > next-env.d.ts << 'EOF'
/// <reference types="next" />
/// <reference types="next/image-types/global" />
EOF

cat > README.md << 'EOF'
# Todo List - 待办清单

Next.js 15 + Supabase + Tailwind CSS 全栈应用。

## 快速开始

1. 配置环境变量：复制 `.env.local.example` 为 `.env.local`，填入 Supabase 信息
2. 运行数据库迁移：在 Supabase SQL Editor 执行 `supabase/migrations/001_create_todos.sql`
3. 启动开发服务器：`npm run dev`
4. 打开 http://localhost:3000

## 部署

推送到 GitHub，导入 [Vercel](https://vercel.com)，添加环境变量即可。
EOF

echo ""
echo "✅ 项目创建完成！"
echo ""
echo "📋 接下来请执行："
echo ""
echo "1. cd todo-app"
echo "2. 复制 .env.local.example 为 .env.local，填入你的 Supabase URL 和 Anon Key"
echo "3. 在 Supabase SQL Editor 执行 supabase/migrations/001_create_todos.sql"
echo "4. npm run dev"
echo ""
echo "🎉 然后打开 http://localhost:3000"
