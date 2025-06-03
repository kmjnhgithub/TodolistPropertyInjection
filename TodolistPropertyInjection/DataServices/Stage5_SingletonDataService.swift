//
//  Stage5_SingletonDataService.swift
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/3.
//

// MARK: - Stage 5: Singleton Pattern DataService
// 完全不修改任何其他程式碼，所有邏輯都在DataService內部
// 🎯 展示全域狀態管理和Singleton模式的特點

import Foundation

class Stage5_SingletonDataService: TodoDataServiceProtocol {
    
    // Stage5核心：Singleton實例
    static let shared = Stage5_SingletonDataService()
    
    // 修正：改為internal存取級別，讓ServiceContainer可以存取
    // 但仍然阻止外部直接創建實例（透過文檔和規範）
    internal init() {
        // 初始化測試資料
        todos = [
            Todo(title: "學習Singleton Pattern"),
            Todo(title: "理解全域狀態管理"),
            Todo(title: "體驗記憶體常駐特性")
        ]
        print("🎯 Stage5: Singleton Pattern - 已初始化 (全域唯一實例)")
        
        // 設置NotificationCenter通知機制
        setupNotificationSystem()
        
        // 展示Singleton特性
        demonstrateSingletonCharacteristics()
    }
    
    // 🎯 Stage5核心：全域狀態存儲
    private var todos: [Todo] = []
    private var creationTimestamp: Date = Date()
    private var accessCount: Int = 0
    private var dataChangeCount: Int = 0
    
    // NotificationCenter通知名稱
    private let todoDataChangedNotification = Notification.Name("Stage5_SingletonDataChanged")
    
    // MARK: - TodoDataServiceProtocol Implementation
    func getAllTodos() -> [Todo] {
        accessCount += 1
        print("📊 Stage5: 全域狀態存取 - 第 \(accessCount) 次存取")
        return todos
    }
    
    func addTodo(_ todo: Todo) {
        todos.append(todo)
        dataChangeCount += 1
        print("✅ Stage5: 全域狀態新增Todo - \(todo.title)")
        print("📊 Stage5: 累計資料變更次數: \(dataChangeCount)")
        
        // 發送通知
        postGlobalNotification(operation: "add", todo: todo)
    }
    
    func deleteTodo(by uuid: String) {
        guard let todoToDelete = todos.first(where: { $0.uuid == uuid }) else {
            print("⚠️ Stage5: 找不到要刪除的Todo - UUID: \(uuid)")
            return
        }
        
        todos.removeAll { $0.uuid == uuid }
        dataChangeCount += 1
        print("❌ Stage5: 全域狀態刪除Todo - \(todoToDelete.title)")
        print("📊 Stage5: 累計資料變更次數: \(dataChangeCount)")
        
        // 發送通知
        postGlobalNotification(operation: "delete", todo: todoToDelete)
    }
    
    func updateTodo(_ todo: Todo) {
        if let index = todos.firstIndex(where: { $0.uuid == todo.uuid }) {
            todos[index] = todo
            dataChangeCount += 1
            print("🔄 Stage5: 全域狀態更新Todo - \(todo.title)")
            print("📊 Stage5: 累計資料變更次數: \(dataChangeCount)")
            
            // 發送通知
            postGlobalNotification(operation: "update", todo: todo)
        }
    }
    
    func setupDataBinding(for viewModel: Any) {
        if let todoListVM = viewModel as? TodoListViewModel {
            print("🎯 Stage5: TodoListViewModel連接到全域Singleton狀態")
            print("📊 Stage5: Singleton創建時間: \(creationTimestamp)")
            print("📊 Stage5: 目前存取次數: \(accessCount)")
        } else {
            print("🎯 Stage5: \(type(of: viewModel)) 連接到全域狀態")
        }
    }
    
    func cleanup() {
        print("🧹 Stage5: Singleton清理 (但實例仍然常駐記憶體)")
        // 注意：Singleton的實例不會被釋放
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Singleton特性展示
    private func demonstrateSingletonCharacteristics() {
        print("""
        💡 Stage5 教學: Singleton Pattern特性
        
        ✅ 全域唯一實例: 整個App只有一個DataService實例
        ✅ 延遲初始化: 第一次存取時才創建
        ✅ 記憶體常駐: 實例會一直存在直到App結束
        ✅ 全域存取: 任何地方都可以存取 .shared
        ✅ 狀態持久: 資料在App生命週期內持續存在
        
        ⚠️ Singleton的風險:
        - 全域狀態難以測試
        - 緊耦合，違反依賴注入原則
        - 記憶體無法釋放
        - 多執行緒安全問題
        - 隱藏的依賴關係
        """)
    }
    
    private func setupNotificationSystem() {
        // 設置NotificationCenter監聽
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleGlobalStateChange(_:)),
            name: todoDataChangedNotification,
            object: nil
        )
        
        print("✅ Stage5: 全域通知系統已設置")
    }
    
    @objc private func handleGlobalStateChange(_ notification: Notification) {
        DispatchQueue.main.async {
            if let userInfo = notification.userInfo,
               let operation = userInfo["operation"] as? String {
                
                print("🌐 Stage5: 處理全域狀態變更 - \(operation)")
                
                // 發送UI更新通知
                self.notifyUIUpdate(operation: operation)
            }
        }
    }
    
    private func postGlobalNotification(operation: String, todo: Todo) {
        NotificationCenter.default.post(
            name: todoDataChangedNotification,
            object: self,
            userInfo: [
                "operation": operation,
                "todo": todo,
                "timestamp": Date(),
                "singleton_id": ObjectIdentifier(self),
                "access_count": accessCount,
                "change_count": dataChangeCount
            ]
        )
        print("📤 Stage5: 發送全域狀態變更通知 - \(operation)")
    }
    
    private func notifyUIUpdate(operation: String) {
        let uiUpdateNotification = Notification.Name("Stage5_UIUpdateRequired")
        
        NotificationCenter.default.post(
            name: uiUpdateNotification,
            object: nil,
            userInfo: [
                "operation": operation,
                "count": todos.count,
                "stage": "Stage5_Singleton",
                "singleton_info": getSingletonInfo()
            ]
        )
        
        print("🎨 Stage5: 發送UI更新通知 - \(operation)")
    }
    
    // MARK: - Singleton資訊和統計
    private func getSingletonInfo() -> [String: Any] {
        return [
            "creation_time": creationTimestamp,
            "access_count": accessCount,
            "change_count": dataChangeCount,
            "memory_address": String(describing: Unmanaged.passUnretained(self).toOpaque()),
            "todo_count": todos.count
        ]
    }
    
    func printSingletonStatistics() {
        print("""
        📊 Stage5 Singleton統計資訊:
        ================================
        創建時間: \(creationTimestamp)
        存取次數: \(accessCount)
        變更次數: \(dataChangeCount)
        Todo總數: \(todos.count)
        記憶體位址: \(String(describing: Unmanaged.passUnretained(self).toOpaque()))
        實例ID: \(ObjectIdentifier(self))
        ================================
        """)
    }
    
    // MARK: - 展示Singleton的記憶體特性
    func demonstrateMemoryPersistence() {
        print("💾 Stage5: 展示Singleton記憶體持久性")
        
        // 即使沒有強引用，Singleton也會持續存在
        weak var weakRef = Stage5_SingletonDataService.shared
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let strongRef = weakRef {
                print("✅ Stage5: Singleton實例仍然存在於記憶體中")
                print("📍 記憶體位址: \(String(describing: Unmanaged.passUnretained(strongRef).toOpaque()))")
            } else {
                print("❌ Stage5: Singleton實例已被釋放 (這不應該發生)")
            }
        }
    }
    
    // MARK: - 展示多執行緒安全考量
    func demonstrateThreadSafety() {
        print("🔒 Stage5: 展示多執行緒存取")
        
        // 模擬多執行緒同時存取
        DispatchQueue.global().async {
            let todos1 = self.getAllTodos()
            print("🧵 執行緒1: 獲得 \(todos1.count) 個Todos")
        }
        
        DispatchQueue.global().async {
            let todos2 = self.getAllTodos()
            print("🧵 執行緒2: 獲得 \(todos2.count) 個Todos")
        }
        
        print("⚠️ Stage5: 注意多執行緒安全問題，可能需要加鎖保護")
    }
    
    // MARK: - 展示Singleton的正確和錯誤用法
    func demonstrateSingletonUsage() {
        print("""
        💡 Stage5 教學: Singleton的正確使用場景
        
        ✅ 適合的場景:
        - 配置管理 (Configuration)
        - 日誌系統 (Logger)
        - 快取管理 (Cache Manager)
        - 網路管理 (Network Manager)
        - 資料庫連接池
        
        ❌ 不適合的場景:
        - 業務資料模型 (容易造成全域污染)
        - 需要多個實例的服務
        - 需要單元測試的類別
        - 有複雜生命週期的物件
        
        🎯 Stage5的教學目的:
        展示Singleton在資料管理中的特點，
        理解全域狀態的優缺點，
        為後續更好的架構設計做準備。
        """)
    }
}

/*
🎯 Stage5 設計說明：

✅ Singleton Pattern的特點：
1. 全域唯一實例
2. 延遲初始化
3. 記憶體常駐
4. 全域存取點
5. 狀態持久性

✅ 這個階段展示什麼：
1. 全域狀態管理的概念
2. Singleton的實作方式
3. 記憶體持久性特性
4. 多執行緒安全考量
5. 適用場景分析

❌ Singleton的問題：
1. 全域狀態難以測試
2. 違反依賴注入原則
3. 緊耦合設計
4. 記憶體無法釋放
5. 隱藏依賴關係

🧪 測試重點：
1. 體驗全域狀態的持久性
2. 觀察統計資訊的累積
3. 理解記憶體常駐特性
4. 感受全域存取的便利性

💡 學習價值：
雖然Singleton有很多問題，但理解它的特性
有助於：
- 理解全域狀態管理
- 認識設計模式的權衡
- 為更好的架構設計做準備
- 理解框架中的Singleton使用

下一階段預告：
Stage6將展示UserDefaults的持久化能力！
*/
