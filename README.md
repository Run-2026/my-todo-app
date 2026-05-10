# Todo List - Next.js + Supabase + Vercel

一个简单的待办清单 Web 应用，数据持久化到 Supabase 数据库。

---

## 🚀 部署步骤

### 第 1 步：创建数据库表

登录 [Supabase Dashboard](https://app.supabase.com)，进入你的项目，打开 **SQL Editor**，执行：

```sql
-- 创建 todos 表
CREATE TABLE todos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 启用 Row Level Security（可选，但推荐）
ALTER TABLE todos ENABLE ROW LEVEL SECURITY;

-- 允许匿名用户读写（不需要登录）
CREATE POLICY "Allow all" ON todos
  FOR ALL USING (true) WITH CHECK (true);
```

### 第 2 步：本地运行

```bash
cd todo-app
npm install
npm run dev
```

浏览器打开 `http://localhost:3000`

### 第 3 步：部署到 Vercel

**方式 A：命令行**
```bash
npx vercel --prod
```

**方式 B：Git 集成**
1. 把代码推送到 GitHub
2. 登录 [Vercel](https://vercel.com) → Add New Project
3. 选择仓库 → 在 Environment Variables 中填入：
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
4. 点击 Deploy

---

## 📁 项目结构

```
todo-app/
├── src/
│   ├── lib/
│   │   └── supabase.js           # Supabase 客户端配置
│   └── app/
│       ├── components/
│       │   ├── TodoList.js         # 核心组件
│       │   └── TodoList.module.css # 组件样式
│       ├── page.js                 # 首页
│       ├── layout.js               # 根布局
│       └── globals.css             # 全局样式
├── .env.local                      # 环境变量（已配置）
├── next.config.js                  # 静态导出配置
└── package.json                    # 依赖
```

## ⚠️ 注意事项

本项目使用 **静态导出**（`output: 'export'`），部署为纯静态站点。前端通过 Supabase JS Client 直连数据库，无需后端 API 路由。

如果需要在 Vercel 上使用服务端功能（如 API 路由、SSR），请删除 `next.config.js` 中的 `output: 'export'`。
