"use client";

import { useState, useEffect, useCallback } from "react";
import { supabase } from "../../lib/supabase";
import styles from "./TodoList.module.css";

export default function TodoList() {
  const [todos, setTodos] = useState([]);
  const [input, setInput] = useState("");
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
          },
        ])
        .select()
        .single();

      if (error) throw error;
      setTodos((prev) => [data, ...prev]);
      setInput("");
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

  const completedCount = todos.filter((t) => t.completed).length;

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

      {loading ? (
        <div className={styles.loading}>加载中...</div>
      ) : todos.length === 0 ? (
        <div className={styles.empty}>暂无任务，添加一个吧！</div>
      ) : (
        <ul className={styles.list}>
          {todos.map((todo) => (
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
                <span className={styles.text}>{todo.title}</span>
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
