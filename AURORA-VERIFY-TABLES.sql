-- Aurora 数据库验证查询
-- 在 Query Editor 中运行这些命令

-- 1. 查看所有表
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';

-- 2. 查看 User 表结构
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'User'
ORDER BY ordinal_position;

-- 3. 查看 Post 表结构
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'Post'
ORDER BY ordinal_position;

-- 4. 查看 User 表数据（应该是空的）
SELECT * FROM "User";

-- 5. 查看 Post 表数据（应该是空的）
SELECT * FROM "Post";

-- 6. 统计表的记录数
SELECT 
    'User' as table_name, 
    COUNT(*) as row_count 
FROM "User"
UNION ALL
SELECT 
    'Post' as table_name, 
    COUNT(*) as row_count 
FROM "Post";
