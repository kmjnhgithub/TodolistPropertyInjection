//
//  Stage1_PropertyDataService.swift
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/2.
//

// MARK: - Stage 1: Property直接傳遞 DataService
class Stage1_PropertyDataService: TodoDataServiceProtocol {
    // 簡單的記憶體存儲
    private var todos: [Todo] = []
    
    init() {
        // 初始化一些測試資料
        todos = [
            Todo(title: "學習iOS資料傳遞"),
            Todo(title: "完成Todo App專案"),
            Todo(title: "準備面試作品集")
        ]
        print("🎯 Stage1: Property直接傳遞模式 - 已初始化")
    }
    
    func getAllTodos() -> [Todo] {
        return todos
    }
    
    func addTodo(_ todo: Todo) {
        todos.append(todo)
        print("✅ Stage1: 新增Todo - \(todo.title)")
    }
    
    func deleteTodo(by uuid: String) {
        todos.removeAll { $0.uuid == uuid }
        print("❌ Stage1: 刪除Todo - UUID: \(uuid)")
    }
    
    func updateTodo(_ todo: Todo) {
        if let index = todos.firstIndex(where: { $0.uuid == todo.uuid }) {
            todos[index] = todo
            print("🔄 Stage1: 更新Todo - \(todo.title)")
        }
    }
    
    // Stage1 不需要特殊綁定
    func setupDataBinding(for viewModel: Any) {
        print("🎯 Stage1: 無需特殊資料綁定")
    }
    
    func cleanup() {
        print("🧹 Stage1: 清理資源")
    }
}
