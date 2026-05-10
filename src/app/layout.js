import './globals.css'

export const metadata = {
  title: 'Todo List',
  description: '待办清单',
}

export default function RootLayout({ children }) {
  return (
    <html lang="zh-CN">
      <body>{children}</body>
    </html>
  )
}