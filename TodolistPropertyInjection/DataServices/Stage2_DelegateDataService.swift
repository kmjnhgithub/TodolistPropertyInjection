// MARK: - Stage 2: 修正版 - 純Delegate Pattern DataService (Badge修復版)
// 完全不修改任何其他程式碼，包括不擴展TodoListViewModel

import Foundation

class Stage2_DelegateDataService: TodoDataServiceProtocol {
    // 簡單的記憶體存儲
    private var todos: [Todo] = []
    
    // 🎯 Stage2重點：Delegate概念展示 (不依賴外部類別擴展)
    private weak var registeredViewModel: TodoListViewModelProtocol?
    
    // 🎯 Badge支援（但Stage2不會更新Badge - 展示限制）
    private var badgeUpdateCallback: BadgeUpdateCallback?
    
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
        
        // 🎯 Stage2限制：不會自動更新Badge
        // 這展示了Stage2無法自動同步的特性
        print("🔴 Stage2限制: Badge不會自動更新（需手動刷新）")
        
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
        if let todoListVM = viewModel as? TodoListViewModelProtocol {
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
        badgeUpdateCallback = nil
    }
    
    // MARK: - Badge Protocol Implementation (Stage2空實作)
    
    func setBadgeUpdateCallback(_ callback: @escaping (Int) -> Void) {
        self.badgeUpdateCallback = callback
        print("🔴 Stage2: Badge回調已設置（但不會主動更新）")
        
        // Stage2特性：不會主動更新Badge
        // 這讓用戶感受到Stage2的限制
        callback(0) // 始終保持0
    }
    
    func clearBadge() {
        print("🔴 Stage2: 清除Badge（無效果，因為本來就不更新）")
        // Stage2不處理Badge，所以清除也無效果
    }
    
    // MARK: - Delegate機制 (純DataService內部實作)
    private func registerDelegate(_ viewModel: TodoListViewModelProtocol) {
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
        5. Badge限制: 無法自動更新，展示Stage2局限性
        
        在真實場景中的完整實作：
        
        protocol TodoDataDelegate: AnyObject {
            func didAddTodo(_ todo: Todo)
            func didDeleteTodo(_ todo: Todo)
            func didUpdateTodo(_ todo: Todo)
            func didUpdateBadge(_ count: Int)
        }
        
        class TodoListViewModel: TodoDataDelegate {
            func didAddTodo(_ todo: Todo) {
                // 處理新增通知
            }
            func didUpdateBadge(_ count: Int) {
                // 處理Badge更新
            }
            // ... 其他方法
        }
        
        但為了保持「不修改其他程式碼」的原則，
        我們只在DataService內部展示Delegate概念。
        """)
    }
}

/*
🎯 Stage2 Badge修復說明：

✅ 新增Badge Protocol實作：
1. setBadgeUpdateCallback - 設置但不主動調用
2. clearBadge - 空實作，展示限制
3. Badge始終保持0，突出Stage2的限制

✅ 這個設計的學習價值：
1. 展示Delegate Pattern的基本概念
2. 示範weak reference的使用
3. 理解委託者和代理人的關係
4. 感受Stage2無法自動更新Badge的限制

❌ Stage2的實際限制：
1. UI依然不會自動更新
2. Badge不會響應新增操作
3. 只能在Console觀察Delegate概念
4. 展示了為什麼需要更完整的解決方案

🔍 Console測試重點：
- 觀察Delegate註冊和通知的日誌
- 理解weak reference的重要性
- 體驗委託關係的建立過程
- 感受Badge不更新的限制

💡 與Stage1對比：
- Stage1: 完全無Badge概念
- Stage2: 有Badge接口但不實作
- 為Stage4的Badge突破做鋪墊

修正重點：
- 完全符合TodoDataServiceProtocol
- 保持原有Delegate概念展示
- 新增Badge空實作突出限制
- 為後續階段對比做準備
*/
