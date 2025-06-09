//
//  Stage1_PropertyDataService.swift
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/2.
//

// MARK: - Stage 1: Property直接傳遞 DataService (Badge增強版)
class Stage1_PropertyDataService: TodoDataServiceProtocol {
    // 簡單的記憶體存儲
    private var todos: [Todo] = []
    
    // Badge支援（但Stage1不會更新Badge - 展示限制）
    private var badgeUpdateCallback: BadgeUpdateCallback?
    
    init() {
        // 初始化一些測試資料
        todos = [
            Todo(title: "學習iOS資料傳遞"),
            Todo(title: "完成Todo App專案"),
            Todo(title: "準備面試作品集")
        ]
        print("Stage1: Property直接傳遞模式 - 已初始化")
    }
    
    func getAllTodos() -> [Todo] {
        return todos
    }
    
    func addTodo(_ todo: Todo) {
        todos.append(todo)
        print("Stage1: 新增Todo - \(todo.title)")
        
        // Stage1限制：不會自動更新Badge
        // 這展示了Stage1無法自動同步的特性
        print("Stage1限制: Badge不會自動更新（需手動刷新）")
    }
    
    func deleteTodo(by uuid: String) {
        todos.removeAll { $0.uuid == uuid }
        print("Stage1: 刪除Todo - UUID: \(uuid)")
    }
    
    func updateTodo(_ todo: Todo) {
        if let index = todos.firstIndex(where: { $0.uuid == todo.uuid }) {
            todos[index] = todo
            print("Stage1: 更新Todo - \(todo.title)")
        }
    }
    
    // Stage1 不需要特殊綁定
    func setupDataBinding(for viewModel: Any) {
        print("Stage1: 無需特殊資料綁定")
    }
    
    func cleanup() {
        print("Stage1: 清理資源")
        badgeUpdateCallback = nil
    }
    
    // MARK: - Badge Protocol Implementation (Stage1空實作)
    
    func setBadgeUpdateCallback(_ callback: @escaping (Int) -> Void) {
        self.badgeUpdateCallback = callback
        print("Stage1: Badge回調已設置（但不會主動更新）")
        
        // Stage1特性：不會主動更新Badge
        // 這讓用戶感受到Stage1的限制
        callback(0) // 始終保持0
    }
    
    func clearBadge() {
        print("Stage1: 清除Badge（無效果，因為本來就不更新）")
        // Stage1不處理Badge，所以清除也無效果
    }
}
