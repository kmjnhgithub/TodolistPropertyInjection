// MARK: - Stage 2: 修正版 - 純Delegate Pattern DataService
// 完全不修改任何其他程式碼，包括不擴展TodoListViewModel

import Foundation

class Stage2_DelegateDataService: TodoDataServiceProtocol {
    // 簡單的記憶體存儲
    private var todos: [Todo] = []
    
    // 🎯 Stage2重點：Delegate概念展示 (不依賴外部類別擴展)
    private weak var registeredViewModel: TodoListViewModel?
    
    init() {
        // 初始化測試資料
        todos = [
            Todo(title: "學習Delegate Pattern"),
            Todo(title: "理解委託概念"),
            Todo(title: "不依賴外部類別擴展")
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
        
        // 🎯 Stage2核心：展示Delegate概念 (但不依賴ViewModel的新方法)
        notifyDelegateDataChanged(operation: "新增", todo: todo)
    }
    
    func deleteTodo(by uuid: String) {
        guard let todoToDelete = todos.first(where: { $0.uuid == uuid }) else {
            print("⚠️ Stage2: 找不到要刪除的Todo - UUID: \(uuid)")
            return
        }
        
        todos.removeAll { $0.uuid == uuid }
        print("❌ Stage2: 刪除Todo - \(todoToDelete.title)")
        
        // 🎯 Stage2核心：展示Delegate概念
        notifyDelegateDataChanged(operation: "刪除", todo: todoToDelete)
    }
    
    func updateTodo(_ todo: Todo) {
        if let index = todos.firstIndex(where: { $0.uuid == todo.uuid }) {
            todos[index] = todo
            print("🔄 Stage2: 更新Todo - \(todo.title)")
            
            // 🎯 Stage2核心：展示Delegate概念
            notifyDelegateDataChanged(operation: "更新", todo: todo)
        }
    }
    
    func setupDataBinding(for viewModel: Any) {
        if let todoListVM = viewModel as? TodoListViewModel {
            // 🎯 Stage2: 註冊ViewModel為Delegate (不呼叫ViewModel的新方法)
            registerDelegate(todoListVM)
            print("🎯 Stage2: 註冊TodoListViewModel為Delegate")
        } else {
            print("🎯 Stage2: \(type(of: viewModel)) 不需要Delegate綁定")
        }
    }
    
    func cleanup() {
        print("🧹 Stage2: 清理Delegate資源")
        registeredViewModel = nil
    }
    
    // MARK: - Delegate機制 (純DataService內部實作)
    private func registerDelegate(_ viewModel: TodoListViewModel) {
        // 使用weak reference避免循環引用
        registeredViewModel = viewModel
        print("📝 Stage2: ViewModel已註冊為Delegate")
    }
    
    private func notifyDelegateDataChanged(operation: String, todo: Todo) {
        print("📢 Stage2: 準備通知Delegate - \(operation)操作")
        
        // 檢查Delegate是否還存在
        if let delegate = registeredViewModel {
            print("✅ Stage2: Delegate存在，執行通知")
            
            // 🎯 這裡我們不呼叫ViewModel的任何新方法
            // 只是展示Delegate Pattern的概念
            print("📊 Stage2: Delegate通知成功 - \(operation): \(todo.title)")
            print("📊 Stage2: 當前Todo總數: \(delegate.todos.count)")
            
            // 在真實的Delegate Pattern中，這裡會呼叫delegate的方法
            // 但為了不修改TodoListViewModel，我們只做概念展示
            print("💡 Stage2: 在真實場景中，這裡會呼叫delegate.didUpdateData()")
            
        } else {
            print("⚠️ Stage2: Delegate已被釋放，無法通知")
        }
        
        print("✅ Stage2: Delegate通知流程完成")
    }
    
    // MARK: - Delegate Pattern 概念展示
    private func demonstrateDelegatePattern() {
        print("""
        💡 Stage2 教學: Delegate Pattern 概念
        
        1. 委託者 (Delegator): Stage2_DelegateDataService
        2. 代理人 (Delegate): TodoListViewModel
        3. 協議 (Protocol): 在真實場景中會定義專門的Protocol
        4. 通知機制: 資料變更時通知代理人
        
        在真實場景中的完整實作：
        
        protocol TodoDataDelegate: AnyObject {
            func didAddTodo(_ todo: Todo)
            func didDeleteTodo(_ todo: Todo)
            func didUpdateTodo(_ todo: Todo)
        }
        
        class TodoListViewModel: TodoDataDelegate {
            func didAddTodo(_ todo: Todo) {
                // 處理新增通知
            }
            // ... 其他方法
        }
        
        但為了保持「不修改其他程式碼」的原則，
        我們只在DataService內部展示Delegate概念。
        """)
    }
}

/*
🎯 Stage2 修正版設計說明：

✅ 為什麼不使用Extension：
1. 保持「只新增DataService」的原則
2. 避免修改TodoListViewModel的行為
3. 展示純粹的Delegate概念
4. 符合我們的學習目標

✅ 這個設計的學習價值：
1. 展示Delegate Pattern的基本概念
2. 示範weak reference的使用
3. 理解委託者和代理人的關係
4. 展示為什麼純DataService層無法直接更新UI

❌ Stage2的實際限制：
1. UI依然不會自動更新
2. 只能在Console觀察Delegate概念
3. 無法真正實現雙向通訊
4. 展示了為什麼需要更完整的解決方案

🔍 Console測試重點：
- 觀察Delegate註冊和通知的日誌
- 理解weak reference的重要性
- 體驗委託關係的建立過程
- 感受純DataService層通訊的限制

💡 真實世界的Delegate應用：
- UITableViewDelegate
- UITextFieldDelegate
- Custom Protocol定義
- 一對一的強型別通訊

修正重點：
- 移除了extension TodoListViewModel
- 所有邏輯都在DataService內部
- 純粹展示Delegate概念，不修改其他類別
- 符合「只新增DataService」的原則
*/
