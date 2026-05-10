'use client'

import { useState, useEffect } from 'react'
import { supabase } from '@/lib/supabase'

export default function TodoList() {
  const [todos, setTodos] = useState([])
  const [newTask, setNewTask] = useState('')
  const [loading, setLoading] = useState(true)

  // 获取所有任务
  const fetchTodos = async () => {
    try {
      const { data, error } = await supabase
        .from('todos')
        .select('*')
        .order('created_at', { ascending: false })

      if (error) throw error
      setTodos(data || [])
    } catch (error) {
      console.error('获取任务失败:', error.message)
    } finally {
      setLoading(false)
    }
  }

  // 添加任务
  const addTodo = async (e) => {
    e.preventDefault()
    if (!newTask.trim()) return

    try {
      const { data, error } = await supabase
        .from('todos')
        .insert([{ title: newTask.trim(), completed: false }])
        .select()

      if (error) throw error
      setTodos([data[0], ...todos])
      setNewTask('')
    } catch (error) {
      console.error('添加任务失败:', error.message)
      alert('添加失败，请重试')
    }
  }

  // 切换完成状态
  const toggleTodo = async (id, completed) => {
    try {
      const { error } = await supabase
        .from('todos')
        .update({ completed: !completed, updated_at: new Date() })
        .eq('id', id)

      if (error) throw error
      setTodos(todos.map(todo =>
        todo.id === id ? { ...todo, completed: !completed } : todo
      ))
    } catch (error) {
      console.error('更新失败:', error.message)
    }
  }

  // 删除任务
  const deleteTodo = async (id) => {
    try {
      const { error } = await supabase
        .from('todos')
        .delete()
        .eq('id', id)

      if (error) throw error
      setTodos(todos.filter(todo => todo.id !== id))
    } catch (error) {
      console.error('删除失败:', error.message)
    }
  }

  // 初始化加载
  useEffect(() => {
    fetchTodos()

    // 订阅实时更新（可选）
    const subscription = supabase
      .channel('todos_channel')
      .on('postgres_changes', 
        { event: '*', schema: 'public', table: 'todos' },
        (payload) => {
          fetchTodos()
        }
      )
      .subscribe()

    return () => {
      subscription.unsubscribe()
    }
  }, [])

  // 统计
  const completedCount = todos.filter(t => t.completed).length
  const totalCount = todos.length

  return (
    <div className="bg-white rounded-xl shadow-lg p-6">
      {/* 输入框 */}
      <form onSubmit={addTodo} className="flex gap-2 mb-6">
        <input
          type="text"
          value={newTask}
          onChange={(e) => setNewTask(e.target.value)}
          placeholder="输入新任务..."
          className="flex-1 px-4 py-3 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all"
        />
        <button
          type="submit"
          disabled={!newTask.trim()}
          className="px-6 py-3 bg-blue-500 text-white rounded-lg hover:bg-blue-600 disabled:bg-gray-300 disabled:cursor-not-allowed transition-colors font-medium"
        >
          添加
        </button>
      </form>

      {/* 统计 */}
      <div className="flex justify-between items-center mb-4 text-sm text-gray-500">
        <span>
          共 {totalCount} 个任务，已完成 {completedCount} 个
        </span>
        {completedCount > 0 && (
          <span className="text-green-600">
            完成率 {Math.round((completedCount / totalCount) * 100)}%
          </span>
        )}
      </div>

      {/* 任务列表 */}
      {loading ? (
        <div className="text-center py-12 text-gray-400">
          加载中...
        </div>
      ) : todos.length === 0 ? (
        <div className="text-center py-12 text-gray-400">
          <p className="text-4xl mb-2">📭</p>
          <p>还没有任务，添加一个吧！</p>
        </div>
      ) : (
        <ul className="space-y-2">
          {todos.map((todo) => (
            <li
              key={todo.id}
              className={`flex items-center gap-3 p-4 rounded-lg border transition-all ${
                todo.completed
                  ? 'bg-gray-50 border-gray-100'
                  : 'bg-white border-gray-200 hover:border-blue-300'
              }`}
            >
              {/* 复选框 */}
              <button
                onClick={() => toggleTodo(todo.id, todo.completed)}
                className={`flex-shrink-0 w-6 h-6 rounded-full border-2 flex items-center justify-center transition-all ${
                  todo.completed
                    ? 'bg-green-500 border-green-500'
                    : 'border-gray-300 hover:border-blue-500'
                }`}
              >
                {todo.completed && (
                  <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                  </svg>
                )}
              </button>

              {/* 任务文本 */}
              <span
                className={`flex-1 ${
                  todo.completed
                    ? 'line-through text-gray-400'
                    : 'text-gray-700'
                }`}
              >
                {todo.title}
              </span>

              {/* 删除按钮 */}
              <button
                onClick={() => deleteTodo(todo.id)}
                className="flex-shrink-0 p-2 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded-lg transition-all"
                title="删除任务"
              >
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                </svg>
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}
