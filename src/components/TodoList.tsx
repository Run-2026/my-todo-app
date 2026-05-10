'use client'

import { useState, useEffect, useCallback } from 'react'
import { createClient } from '@/lib/supabase'
import { Todo } from '@/lib/database.types'

export default function TodoList() {
  const [todos, setTodos] = useState<Todo[]>([])
  const [newTodo, setNewTodo] = useState('')
  const [loading, setLoading] = useState(true)
  const supabase = createClient()

  // 获取所有任务
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

  // 初始加载 + 实时订阅
  useEffect(() => {
    fetchTodos()

    // 订阅数据库变化
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

  // 添加任务
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

  // 切换完成状态
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

  // 删除任务
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
      {/* 添加任务表单 */}
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

      {/* 任务列表 */}
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
              {/* 复选框 */}
              <input
                type="checkbox"
                checked={todo.completed}
                onChange={() => toggleTodo(todo.id, todo.completed)}
                className="w-5 h-5 text-blue-500 rounded focus:ring-blue-500"
              />

              {/* 任务标题 */}
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
                className="px-3 py-1 text-red-500 hover:bg-red-50 rounded transition-colors text-sm"
              >
                删除
              </button>
            </div>
          ))
        )}
      </div>

      {/* 统计 */}
      {todos.length > 0 && (
        <div className="mt-4 text-sm text-gray-500 text-center">
          共 {todos.length} 个任务，
          {todos.filter((t) => t.completed).length} 个已完成
        </div>
      )}
    </div>
  )
}