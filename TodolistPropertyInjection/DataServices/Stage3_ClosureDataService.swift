//
//  Stage3_ClosureDataService.swift
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/3.
//

// MARK: - Stage 3: 純Closure Pattern DataService
// 完全不修改任何其他程式碼，包括不擴展TodoListViewModel

import Foundation

class Stage3_ClosureDataService: TodoDataServiceProtocol {
    // 簡單的記憶體存儲
    private var todos: [Todo] = []
    
    // 🎯 Stage3核心：Closure回調機制 (但不依賴外部類別的擴展)
    private var onDataChanged: (() -> Void)?
    
    init() {
        // 初始化測試資料
        todos = [
            Todo(title: "學習Closure Pattern"),
            Todo(title: "理解回調機制概念"),
            Todo(title: "不依賴外部類別擴展")
        ]
        print("🎯 Stage3: Closure/Callback Pattern - 已初始化")
    }
    
    // MARK: - TodoDataServiceProtocol Implementation
    func getAllTodos() -> [Todo] {
        return todos
    }
    
    func addTodo(_ todo: Todo) {
        todos.append(todo)
        print("✅ Stage3: 新增Todo - \(todo.title)")
        
        // 🎯 Stage3核心：觸發Closure回調
        triggerDataChangeCallback(operation: "新增", todo: todo)
    }
    
    func deleteTodo(by uuid: String) {
        guard let todoToDelete = todos.first(where: { $0.uuid == uuid }) else {
            print("⚠️ Stage3: 找不到要刪除的Todo - UUID: \(uuid)")
            return
        }
        
        todos.removeAll { $0.uuid == uuid }
        print("❌ Stage3: 刪除Todo - \(todoToDelete.title)")
        
        // 🎯 Stage3核心：觸發Closure回調
        triggerDataChangeCallback(operation: "刪除", todo: todoToDelete)
    }
    
    func updateTodo(_ todo: Todo) {
        if let index = todos.firstIndex(where: { $0.uuid == todo.uuid }) {
            todos[index] = todo
            print("🔄 Stage3: 更新Todo - \(todo.title)")
            
            // 🎯 Stage3核心：觸發Closure回調
            triggerDataChangeCallback(operation: "更新", todo: todo)
        }
    }
    
    func setupDataBinding(for viewModel: Any) {
        if let todoListVM = viewModel as? TodoListViewModel {
            // 🎯 Stage3: 設置Closure回調 (不依賴ViewModel的擴展方法)
            setupClosureCallback(for: todoListVM)
            print("🎯 Stage3: 為TodoListViewModel設置Closure回調")
        } else {
            print("🎯 Stage3: \(type(of: viewModel)) 不需要Closure綁定")
        }
    }
    
    func cleanup() {
        print("🧹 Stage3: 清理Closure資源")
        // 🎯 Stage3重要：避免記憶體洩漏
        onDataChanged = nil
    }
    
    // MARK: - 私有方法：Closure回調機制
    private func setupClosureCallback(for viewModel: TodoListViewModel) {
        // 🎯 Stage3核心：設置回調Closure
        // 注意：這裡使用weak capture避免循環引用
        onDataChanged = { [weak viewModel] in
            // 這裡我們不呼叫ViewModel的任何新方法
            // 只是展示Closure概念，實際效果在Console中觀察
            print("📞 Stage3: Closure被執行，通知ViewModel")
            
            // 由於我們不能修改TodoListViewModel，所以這裡只能做示意性的操作
            // 在真實場景中，這個Closure會觸發UI更新或其他操作
            if let vm = viewModel {
                print("✅ Stage3: ViewModel仍然存在，Closure執行成功")
                print("📊 Stage3: 當前Todo數量 \(vm.todos.count)")
            } else {
                print("⚠️ Stage3: ViewModel已被釋放，Closure不執行")
            }
        }
        
        print("✅ Stage3: Closure回調已設置完成")
    }
    
    private func triggerDataChangeCallback(operation: String, todo: Todo) {
        print("📞 Stage3: 準備執行\(operation)操作的Closure回調")
        
        // 🎯 Stage3核心：執行Closure
        onDataChanged?()
        
        print("✅ Stage3: \(operation)操作的Closure回調執行完成 - \(todo.title)")
    }
    
    // MARK: - 展示Closure Pattern的不同用法
    
    // 🎯 方法1：簡單的無參數回調
    private func demonstrateSimpleClosure() {
        let simpleClosure: () -> Void = {
            print("💡 Stage3 教學: 這是最簡單的Closure")
        }
        simpleClosure()
    }
    
    // 🎯 方法2：帶參數的回調
    private func demonstrateParameterClosure() {
        let parameterClosure: (String, Int) -> Void = { message, count in
            print("💡 Stage3 教學: 帶參數的Closure - \(message), 數量: \(count)")
        }
        parameterClosure("Hello Closure", todos.count)
    }
    
    // 🎯 方法3：有返回值的回調
    private func demonstrateReturnClosure() {
        let returnClosure: (Int) -> String = { count in
            return "💡 Stage3 教學: 有返回值的Closure，處理了 \(count) 個項目"
        }
        let result = returnClosure(todos.count)
        print(result)
    }
    
    // 🎯 方法4：展示記憶體洩漏風險
    private func demonstrateMemoryLeakRisk() {
        print("⚠️ Stage3 教學: 記憶體洩漏風險展示")
        
        // 錯誤寫法 - 會造成strong reference cycle
        // onDataChanged = {
        //     print("❌ 這會強引用self: \(self.todos.count)")
        // }
        
        // 正確寫法 - 使用weak self
        onDataChanged = { [weak self] in
            guard let self = self else {
                print("⚠️ self已被釋放，Closure安全退出")
                return
            }
            print("✅ Stage3: 使用weak self避免記憶體洩漏，Todo總數: \(self.todos.count)")
        }
        
        print("💡 Stage3: 記得在Closure中使用 [weak self] 來避免強引用循環")
    }
}

/*
🎯 Stage3 設計說明：

✅ 為什麼不使用Extension：
1. 保持「只新增DataService」的原則
2. 避免修改其他類別的行為
3. 展示純粹的Closure概念
4. 符合單一職責原則

✅ 這個設計的學習價值：
1. 展示Closure的基本概念和語法
2. 示範記憶體管理的重要性 ([weak self])
3. 展示不同類型的Closure用法
4. 理解為什麼純Closure無法解決UI更新問題

❌ Stage3的實際限制：
1. UI依然不會自動更新
2. 只能在Console觀察Closure執行
3. 無法真正通知ViewController層
4. 展示了為什麼需要更高級的解決方案

🔍 Console測試重點：
- 觀察Closure執行的日誌訊息
- 理解weak引用的安全性
- 體驗不同類型Closure的語法差異
- 感受純DataService層的通訊限制

💡 真實世界的Closure應用：
- 網路請求完成回調
- 動畫執行完成通知
- 按鈕點擊事件處理
- 異步操作結果回傳

下一步展望：
Stage4 NotificationCenter將真正解決跨層級通訊問題！
*/
