-- 创建 todos 表
CREATE TABLE todos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 启用行级安全（RLS）
ALTER TABLE todos ENABLE ROW LEVEL SECURITY;

-- 创建策略：允许所有人读取
CREATE POLICY "Allow public read" ON todos
  FOR SELECT USING (true);

-- 创建策略：允许所有人插入
CREATE POLICY "Allow public insert" ON todos
  FOR INSERT WITH CHECK (true);

-- 创建策略：允许所有人更新
CREATE POLICY "Allow public update" ON todos
  FOR UPDATE USING (true);

-- 创建策略：允许所有人删除
CREATE POLICY "Allow public delete" ON todos
  FOR DELETE USING (true);