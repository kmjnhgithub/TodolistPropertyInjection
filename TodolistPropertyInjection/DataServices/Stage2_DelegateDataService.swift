//
//  Stage2_DelegateDataService.swift
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/2.
//

// MARK: - Stage 2: 純Delegate Pattern DataService
// ViewController完全不需要修改

import Foundation

class Stage2_DelegateDataService: TodoDataServiceProtocol {
    // 簡單的記憶體存儲
    private var todos: [Todo] = []
    
    // 🎯 Stage2重點：記錄哪些ViewModel需要被通知
    private var viewModelsToNotify: [WeakRef<TodoListViewModel>] = []
    
    init() {
        // 初始化測試資料
        todos = [
            Todo(title: "學習Delegate Pattern"),
            Todo(title: "實作ViewModel間通訊"),
            Todo(title: "測試資料自動同步")
        ]
        print("🎯 Stage2: Delegate Pattern - 已初始化")
    }
    
    // MARK: - TodoDataServiceProtocol Implementation
    func getAllTodos() -> [Todo] {
        return todos
    }
    
    func addTodo(_ todo: Todo) {
        todos.append(todo)
        print("✅ Stage2: 新增Todo - \(todo.title)")
        // 🎯 Stage2: 資料變更後通知相關ViewModel
        notifyViewModels()
    }
    
    func deleteTodo(by uuid: String) {
        guard let todoToDelete = todos.first(where: { $0.uuid == uuid }) else {
            print("⚠️ Stage2: 找不到要刪除的Todo - UUID: \(uuid)")
            return
        }
        
        todos.removeAll { $0.uuid == uuid }
        print("❌ Stage2: 刪除Todo - \(todoToDelete.title)")
        
        // 🎯 Stage2: 資料變更後通知相關ViewModel
        notifyViewModels()
    }
    
    func updateTodo(_ todo: Todo) {
        if let index = todos.firstIndex(where: { $0.uuid == todo.uuid }) {
            todos[index] = todo
            print("🔄 Stage2: 更新Todo - \(todo.title)")
            
            // 🎯 Stage2: 資料變更後通知相關ViewModel
            notifyViewModels()
        }
    }
    
    func setupDataBinding(for viewModel: Any) {
        if let todoListVM = viewModel as? TodoListViewModel {
            // 🎯 Stage2: 註冊需要被通知的ViewModel
            registerViewModel(todoListVM)
            print("🎯 Stage2: 註冊TodoListViewModel到通知列表")
        } else {
            print("🎯 Stage2: \(type(of: viewModel)) 不需要資料綁定")
        }
    }
    
    func cleanup() {
        print("🧹 Stage2: 清理資源")
        // 清理弱引用
        cleanupWeakReferences()
    }
    
    // MARK: - ViewModel通知機制
    private func registerViewModel(_ viewModel: TodoListViewModel) {
        // 避免重複註冊
        cleanupWeakReferences()
        
        // 新增到通知列表
        viewModelsToNotify.append(WeakRef(value: viewModel))
        print("📝 Stage2: ViewModel已註冊到通知列表，目前共 \(viewModelsToNotify.count) 個")
    }
    
    private func notifyViewModels() {
        // 清理已經被釋放的ViewModel
        cleanupWeakReferences()
        
        // 通知所有還活著的ViewModel
        for weakRef in viewModelsToNotify {
            if let viewModel = weakRef.value {
                viewModel.handle DataChanged()
                print("📢 Stage2: 已通知ViewModel資料變更")
            }
        }
    }
    
    private func cleanupWeakReferences() {
        viewModelsToNotify = viewModelsToNotify.filter { $0.value != nil }
    }
}

// MARK: - 弱引用包裝器
class WeakRef<T: AnyObject> {
    weak var value: T?
    
    init(value: T) {
        self.value = value
    }
}

// MARK: - TodoListViewModel擴展 (處理資料變更通知)
extension TodoListViewModel {
    // 🎯 Stage2: 處理資料變更的方法
    func handleDataChanged() {
        // 這裡可以觸發UI更新，但不直接操作ViewController
        print("🔄 Stage2: TodoListViewModel收到資料變更通知")
        
        // 🎯 在這個階段，我們實際上無法直接更新UI
        // 這展現了Stage2的限制：ViewModel無法直接通知ViewController
        // 這個問題會在Stage4 (NotificationCenter) 中解決
        
        // 僅在console顯示同步狀態
        let todoCount = todos.count
        print("📊 Stage2: 目前Todo總數: \(todoCount)")
        print("⚠️ Stage2限制: ViewModel層收到通知，但無法直接更新UI")
        print("💡 解決方案: Stage4將使用NotificationCenter來橋接ViewModel和ViewController")
    }
}

// MARK: - ServiceContainer 切換
/*
只需要在ServiceContainer中修改這一行：

class ServiceContainer {
    static let shared = ServiceContainer()
    private init() {}
    
    // 🎯 編譯時切換：只需要改這一行！
    private let currentDataService: TodoDataServiceProtocol = Stage2_DelegateDataService()
    
    func getDataService() -> TodoDataServiceProtocol {
        return currentDataService
    }
}
*/

// MARK: - Stage2 實際效果說明
/*
🎯 Stage2的實際狀況：

✅ 改進的地方：
- DataService內部實作了Delegate Pattern
- ViewModel之間可以相互通知
- 展示了物件間通訊的基礎概念

❌ 仍然存在的限制：
- ViewController層完全不變，所以UI不會自動更新
- viewWillAppear時依然需要手動reloadData
- Tab間同步依然無法實現

💡 學習重點：
這個階段重點是展示Delegate Pattern的**概念**，
而不是實際的UI自動更新效果。
真正的自動UI更新會在Stage4 (NotificationCenter) 實現。

🎯 測試方式：
1. 觀察Console日誌中的Delegate通知訊息
2. 體驗ViewModel層的通訊機制
3. 理解為什麼單純的Delegate Pattern無法橋接到UI層
4. 為Stage4的NotificationCenter解決方案做準備

這樣的設計展現了真實開發中的漸進式改進過程：
Stage1 → Stage2 → Stage3 → Stage4 (完整的自動更新)
*/
