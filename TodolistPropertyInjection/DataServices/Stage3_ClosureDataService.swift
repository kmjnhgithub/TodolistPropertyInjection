//
//  Stage3_ClosureDataService.swift
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/3.
//

// MARK: - Stage 3: 純Closure Pattern DataService (Badge修復版)
// 完全不修改任何其他程式碼，包括不擴展TodoListViewModel

import Foundation

class Stage3_ClosureDataService: TodoDataServiceProtocol {
    // 簡單的記憶體存儲
    private var todos: [Todo] = []
    
    // Stage3核心：Closure回調機制 (但不依賴外部類別的擴展)
    private var onDataChanged: (() -> Void)?
    
    // Badge支援（但Stage3不會更新Badge - 展示限制）
    private var badgeUpdateCallback: BadgeUpdateCallback?
    
    init() {
        // 初始化測試資料
        todos = [
            Todo(title: "學習Closure Pattern"),
            Todo(title: "理解回調機制概念"),
            Todo(title: "不依賴外部類別擴展")
        ]
        print("Stage3: Closure/Callback Pattern - 已初始化")
    }
    
    // MARK: - TodoDataServiceProtocol Implementation
    func getAllTodos() -> [Todo] {
        return todos
    }
    
    func addTodo(_ todo: Todo) {
        todos.append(todo)
        print("Stage3: 新增Todo - \(todo.title)")
        
        // Stage3限制：不會自動更新Badge
        // 這展示了Stage3無法自動同步的特性
        print("Stage3限制: Badge不會自動更新（需手動刷新）")
        
        // Stage3核心：觸發Closure回調
        triggerDataChangeCallback(operation: "新增", todo: todo)
    }
    
    func deleteTodo(by uuid: String) {
        guard let todoToDelete = todos.first(where: { $0.uuid == uuid }) else {
            print("Stage3: 找不到要刪除的Todo - UUID: \(uuid)")
            return
        }
        
        todos.removeAll { $0.uuid == uuid }
        print("Stage3: 刪除Todo - \(todoToDelete.title)")
        
        // Stage3核心：觸發Closure回調
        triggerDataChangeCallback(operation: "刪除", todo: todoToDelete)
    }
    
    func updateTodo(_ todo: Todo) {
        if let index = todos.firstIndex(where: { $0.uuid == todo.uuid }) {
            todos[index] = todo
            print("Stage3: 更新Todo - \(todo.title)")
            
            // Stage3核心：觸發Closure回調
            triggerDataChangeCallback(operation: "更新", todo: todo)
        }
    }
    
    func setupDataBinding(for viewModel: Any) {
        if let todoListVM = viewModel as? TodoListViewModelProtocol {
            // Stage3: 設置Closure回調 (不依賴ViewModel的擴展方法)
            setupClosureCallback(for: todoListVM)
            print("Stage3: 為TodoListViewModel設置Closure回調")
        } else {
            print("Stage3: \(type(of: viewModel)) 不需要Closure綁定")
        }
    }
    
    func cleanup() {
        print("Stage3: 清理Closure資源")
        // Stage3重要：避免記憶體洩漏
        onDataChanged = nil
        badgeUpdateCallback = nil
    }
    
    // MARK: - Badge Protocol Implementation (Stage3空實作)
    
    func setBadgeUpdateCallback(_ callback: @escaping (Int) -> Void) {
        self.badgeUpdateCallback = callback
        print("Stage3: Badge回調已設置（但不會主動更新）")
        
        // Stage3特性：不會主動更新Badge
        // 這讓用戶感受到Stage3的限制
        callback(0) // 始終保持0
    }
    
    func clearBadge() {
        print("Stage3: 清除Badge（無效果，因為本來就不更新）")
        // Stage3不處理Badge，所以清除也無效果
    }
    
    // MARK: - 私有方法：Closure回調機制
    private func setupClosureCallback(for viewModel: TodoListViewModelProtocol) {
        // Stage3核心：設置回調Closure
        // 注意：這裡使用weak capture避免循環引用
        onDataChanged = { [weak viewModel] in
            // 這裡我們不呼叫ViewModel的任何新方法
            // 只是展示Closure概念，實際效果在Console中觀察
            print("📞 Stage3: Closure被執行，通知ViewModel")
            
            // 由於我們不能修改TodoListViewModel，所以這裡只能做示意性的操作
            // 在真實場景中，這個Closure會觸發UI更新或其他操作
            if let vm = viewModel {
                print("Stage3: ViewModel仍然存在，Closure執行成功")
                print("Stage3: 當前Todo數量 \(vm.todos.count)")
            } else {
                print("Stage3: ViewModel已被釋放，Closure不執行")
            }
        }
        
        print("Stage3: Closure回調已設置完成")
    }
    
    private func triggerDataChangeCallback(operation: String, todo: Todo) {
        print("📞 Stage3: 準備執行\(operation)操作的Closure回調")
        
        // Stage3核心：執行Closure
        onDataChanged?()
        
        print("Stage3: \(operation)操作的Closure回調執行完成 - \(todo.title)")
    }
    
    // MARK: - 展示Closure Pattern的不同用法
    
    // 方法1：簡單的無參數回調
    private func demonstrateSimpleClosure() {
        let simpleClosure: () -> Void = {
            print("Stage3 教學: 這是最簡單的Closure")
        }
        simpleClosure()
    }
    
    // 方法2：帶參數的回調
    private func demonstrateParameterClosure() {
        let parameterClosure: (String, Int) -> Void = { message, count in
            print("Stage3 教學: 帶參數的Closure - \(message), 數量: \(count)")
        }
        parameterClosure("Hello Closure", todos.count)
    }
    
    // 方法3：有返回值的回調
    private func demonstrateReturnClosure() {
        let returnClosure: (Int) -> String = { count in
            return "Stage3 教學: 有返回值的Closure，處理了 \(count) 個項目"
        }
        let result = returnClosure(todos.count)
        print(result)
    }
    
    // 方法4：展示記憶體洩漏風險
    private func demonstrateMemoryLeakRisk() {
        print("Stage3 教學: 記憶體洩漏風險展示")
        
        // 錯誤寫法 - 會造成strong reference cycle
        // onDataChanged = {
        //     print("這會強引用self: \(self.todos.count)")
        // }
        
        // 正確寫法 - 使用weak self
        onDataChanged = { [weak self] in
            guard let self = self else {
                print("self已被釋放，Closure安全退出")
                return
            }
            print("Stage3: 使用weak self避免記憶體洩漏，Todo總數: \(self.todos.count)")
        }
        
        print("Stage3: 記得在Closure中使用 [weak self] 來避免強引用循環")
    }
    
    // MARK: - 展示Badge限制的教學價值
    private func demonstrateBadgeLimitations() {
        print("""
        Stage3 教學: Badge功能限制分析
        
        Stage3的Badge限制:
        - 無法自動更新Badge計數
        - 新增Todo後Badge保持0
        - 用戶必須手動檢查是否有新內容
        - 展示了純Closure無法解決UI同步問題
        
        與其他階段對比:
        - Stage1: 無Badge概念
        - Stage2: 有Badge接口但不實作  
        - Stage3: 有Badge接口但不實作
        - Stage4: 第一個支援Badge自動更新的階段
        
        學習價值:
        這種限制深刻體會到：
        1. 純DataService層的通訊限制
        2. 為什麼需要跨層級的通訊機制
        3. Stage4的NotificationCenter突破的價值
        4. 響應式程式設計的必要性
        
        真實應用場景:
        雖然Stage3無法處理Badge，但Closure在真實開發中：
        - 網路請求完成回調
        - 動畫執行完成通知
        - 按鈕點擊事件處理
        - 異步操作結果回傳
        """)
    }
}

/*
Stage3 Badge修復說明：

新增Badge Protocol實作：
1. setBadgeUpdateCallback - 設置但不主動調用
2. clearBadge - 空實作，展示限制
3. Badge始終保持0，突出Stage3的限制

這個設計的學習價值：
1. 展示Closure的基本概念和語法
2. 示範記憶體管理的重要性 ([weak self])
3. 展示不同類型的Closure用法
4. 理解為什麼純Closure無法解決Badge更新問題

Stage3的實際限制：
1. UI依然不會自動更新
2. Badge不會響應新增操作
3. 只能在Console觀察Closure執行
4. 無法真正通知ViewController層

Console測試重點：
- 觀察Closure執行的日誌訊息
- 理解weak引用的安全性
- 體驗不同類型Closure的語法差異
- 感受純DataService層的通訊限制

真實世界的Closure應用：
- 網路請求完成回調
- 動畫執行完成通知
- 按鈕點擊事件處理
- 異步操作結果回傳

下一步展望：
Stage4 NotificationCenter將真正解決跨層級通訊和Badge更新問題！
*/
