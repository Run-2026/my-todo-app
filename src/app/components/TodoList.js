"use client";

import { useState, useEffect, useCallback } from "react";
import { supabase } from "../../lib/supabase";
import styles from "./TodoList.module.css";

const CATEGORIES = [
  { id: "工作", label: "💼 工作", color: "#ef4444" },
  { id: "学习", label: "📚 学习", color: "#3b82f6" },
  { id: "生活", label: "🏠 生活", color: "#10b981" },
  { id: "健康", label: "💪 健康", color: "#f59e0b" },
  { id: "其他", label: "📌 其他", color: "#6b7280" },
];

const DEFAULT_CATEGORY = "其他";

export default function TodoList() {
  const [todos, setTodos] = useState([]);
  const [input, setInput] = useState("");
  const [selectedCategory, setSelectedCategory] = useState("全部");
  const [newCategory, setNewCategory] = useState(DEFAULT_CATEGORY);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // 获取任务列表
  const fetchTodos = useCallback(async () => {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from("todos")
        .select("*")
        .order("created_at", { ascending: false });

      if (error) throw error;
      setTodos(data || []);
      setError(null);
    } catch (err) {
      console.error("获取任务失败:", err);
      setError("获取任务失败，请检查数据库表是否存在");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchTodos();
  }, [fetchTodos]);

  // 添加任务
  const addTodo = async (e) => {
    e.preventDefault();
    if (!input.trim()) return;

    try {
      const { data, error } = await supabase
        .from("todos")
        .insert([
          {
            title: input.trim(),
            completed: false,
            category: newCategory,
          },
        ])
        .select()
        .single();

      if (error) throw error;
      setTodos((prev) => [data, ...prev]);
      setInput("");
      setNewCategory(DEFAULT_CATEGORY);
    } catch (err) {
      console.error("添加任务失败:", err);
      setError("添加任务失败");
    }
  };

  // 切换完成状态
  const toggleTodo = async (id, completed) => {
    try {
      const { error } = await supabase
        .from("todos")
        .update({ completed: !completed })
        .eq("id", id);

      if (error) throw error;
      setTodos((prev) =>
        prev.map((todo) =>
          todo.id === id ? { ...todo, completed: !completed } : todo
        )
      );
    } catch (err) {
      console.error("更新任务失败:", err);
      setError("更新任务失败");
    }
  };

  // 删除任务
  const deleteTodo = async (id) => {
    try {
      const { error } = await supabase.from("todos").delete().eq("id", id);

      if (error) throw error;
      setTodos((prev) => prev.filter((todo) => todo.id !== id));
    } catch (err) {
      console.error("删除任务失败:", err);
      setError("删除任务失败");
    }
  };

  // 筛选任务
  const filteredTodos =
    selectedCategory === "全部"
      ? todos
      : todos.filter((t) => t.category === selectedCategory);

  // 统计
  const completedCount = todos.filter((t) => t.completed).length;
  const categoryStats = CATEGORIES.map((cat) => ({
    ...cat,
    total: todos.filter((t) => t.category === cat.id).length,
    done: todos.filter((t) => t.category === cat.id && t.completed).length,
  }));

  const getCategoryBadge = (categoryId) => {
    const cat = CATEGORIES.find((c) => c.id === categoryId) || CATEGORIES[4];
    return (
      <span
        className={styles.categoryBadge}
        style={{ backgroundColor: cat.color + "20", color: cat.color, borderColor: cat.color + "40" }}
      >
        {cat.label}
      </span>
    );
  };

  return (
    <div className={styles.container}>
      <h1 className={styles.title}>📝 待办清单</h1>

      <form onSubmit={addTodo} className={styles.form}>
        <input
          type="text"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          placeholder="输入新任务..."
          className={styles.input}
        />
        <select
          value={newCategory}
          onChange={(e) => setNewCategory(e.target.value)}
          className={styles.categorySelect}
          title="选择分类"
        >
          {CATEGORIES.map((cat) => (
            <option key={cat.id} value={cat.id}>
              {cat.label}
            </option>
          ))}
        </select>
        <button
          type="submit"
          className={styles.addButton}
          disabled={!input.trim()}
        >
          ➕ 添加
        </button>
      </form>

      {error && (
        <div className={styles.error} onClick={() => setError(null)}>
          ⚠️ {error}
        </div>
      )}

      <div className={styles.stats}>
        总计: {todos.length} | 完成: {completedCount} | 待办:{" "}
        {todos.length - completedCount}
      </div>

      <div className={styles.categoryStats}>
        {categoryStats.map((cat) => (
          <div
            key={cat.id}
            className={styles.statItem}
            style={{ color: cat.color }}
          >
            <span className={styles.statLabel}>{cat.label}</span>
            <span className={styles.statCount}>
              {cat.done}/{cat.total}
            </span>
          </div>
        ))}
      </div>

      {/* 筛选栏 */}
      <div className={styles.filterBar}>
        <button
          className={`${styles.filterButton} ${
            selectedCategory === "全部" ? styles.filterActive : ""
          }`}
          onClick={() => setSelectedCategory("全部")}
        >
          全部
        </button>
        {CATEGORIES.map((cat) => (
          <button
            key={cat.id}
            className={`${styles.filterButton} ${
              selectedCategory === cat.id ? styles.filterActive : ""
            }`}
            onClick={() => setSelectedCategory(cat.id)}
            style={
              selectedCategory === cat.id
                ? { backgroundColor: cat.color, color: "#fff" }
                : {}
            }
          >
            {cat.label}
          </button>
        ))}
      </div>

      {loading ? (
        <div className={styles.loading}>加载中...</div>
      ) : filteredTodos.length === 0 ? (
        <div className={styles.empty}>
          {selectedCategory === "全部"
            ? "暂无任务，添加一个吧！"
            : `「${selectedCategory}」分类暂无任务`}
        </div>
      ) : (
        <ul className={styles.list}>
          {filteredTodos.map((todo) => (
            <li
              key={todo.id}
              className={`${styles.item} ${
                todo.completed ? styles.completed : ""
              }`}
            >
              <label className={styles.checkboxLabel}>
                <input
                  type="checkbox"
                  checked={todo.completed}
                  onChange={() => toggleTodo(todo.id, todo.completed)}
                  className={styles.checkbox}
                />
                <div className={styles.todoContent}>
                  <span className={styles.text}>{todo.title}</span>
                  {getCategoryBadge(todo.category)}
                </div>
              </label>
              <button
                onClick={() => deleteTodo(todo.id)}
                className={styles.deleteButton}
                title="删除"
              >
                🗑️
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
