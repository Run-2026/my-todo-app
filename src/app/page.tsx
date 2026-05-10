import TodoList from "@/components/TodoList";

export default function Home() {
  return (
    <main className="container mx-auto px-4 py-8 max-w-2xl">
      <h1 className="text-3xl font-bold text-center mb-8 text-gray-800">
        📝 待办清单
      </h1>
      <TodoList />
    </main>
  );
}
