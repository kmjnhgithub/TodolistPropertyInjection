//
//  Stage4_NotificationDataService.swift
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/3.
//

// MARK: - Stage 4: NotificationCenter Pattern DataService (Badge增強版)
// 完全不修改任何其他程式碼，所有邏輯都在DataService內部
// 🎯 這是第一個能真正實現UI自動更新的階段！現在還支援Badge！

import Foundation

class Stage4_NotificationDataService: TodoDataServiceProtocol {
    // 簡單的記憶體存儲
    private var todos: [Todo] = []
    
    // 🎯 Badge支援
    private var badgeUpdateCallback: BadgeUpdateCallback?
    private var unreadCount: Int = 0
    
    // 🎯 Stage4核心：NotificationCenter通知名稱定義
    private let todoDataChangedNotification = Notification.Name("Stage4_TodoDataChanged")
    private let todoAddedNotification = Notification.Name("Stage4_TodoAdded")
    private let todoDeletedNotification = Notification.Name("Stage4_TodoDeleted")
    private let todoUpdatedNotification = Notification.Name("Stage4_TodoUpdated")
    
    init() {
        // 初始化測試資料
        todos = [
            Todo(title: "學習NotificationCenter"),
            Todo(title: "實現真正的UI自動更新"),
            Todo(title: "體驗一對多通訊"),
            Todo(title: "享受Badge即時更新")
        ]
        print("🎯 Stage4: NotificationCenter Pattern - 已初始化")
        
        // 🎯 Stage4核心：設置NotificationCenter監聽 (在DataService內部處理)
        setupNotificationListening()
    }
    
    deinit {
        // 清理NotificationCenter監聽
        NotificationCenter.default.removeObserver(self)
        print("🧹 Stage4: 清理NotificationCenter監聽")
    }
    
    // MARK: - TodoDataServiceProtocol Implementation
    func getAllTodos() -> [Todo] {
        return todos
    }
    
    func addTodo(_ todo: Todo) {
        todos.append(todo)
        print("✅ Stage4: 新增Todo - \(todo.title)")
        
        // 🎯 Stage4核心：發送NotificationCenter通知
        postNotification(name: todoAddedNotification, userInfo: ["todo": todo, "operation": "add"])
        postNotification(name: todoDataChangedNotification, userInfo: ["operation": "add", "count": todos.count])
        
        // 🎯 Stage4 Badge：自動更新Badge
        updateBadgeForNewTodo()
    }
    
    func deleteTodo(by uuid: String) {
        guard let todoToDelete = todos.first(where: { $0.uuid == uuid }) else {
            print("⚠️ Stage4: 找不到要刪除的Todo - UUID: \(uuid)")
            return
        }
        
        todos.removeAll { $0.uuid == uuid }
        print("❌ Stage4: 刪除Todo - \(todoToDelete.title)")
        
        // 🎯 Stage4核心：發送NotificationCenter通知
        postNotification(name: todoDeletedNotification, userInfo: ["todo": todoToDelete, "operation": "delete"])
        postNotification(name: todoDataChangedNotification, userInfo: ["operation": "delete", "count": todos.count])
    }
    
    func updateTodo(_ todo: Todo) {
        if let index = todos.firstIndex(where: { $0.uuid == todo.uuid }) {
            todos[index] = todo
            print("🔄 Stage4: 更新Todo - \(todo.title)")
            
            // 🎯 Stage4核心：發送NotificationCenter通知
            postNotification(name: todoUpdatedNotification, userInfo: ["todo": todo, "operation": "update"])
            postNotification(name: todoDataChangedNotification, userInfo: ["operation": "update", "count": todos.count])
        }
    }
    
    func setupDataBinding(for viewModel: Any) {
        if viewModel is TodoListViewModel {
            print("🎯 Stage4: TodoListViewModel將透過NotificationCenter自動接收更新")
            // 🎯 Stage4的魔法：ViewModel不需要任何特殊設定
            // NotificationCenter會自動橋接到ViewController層
        } else {
            print("🎯 Stage4: \(type(of: viewModel)) 不需要特殊設定")
        }
    }
    
    func cleanup() {
        print("🧹 Stage4: 清理NotificationCenter資源")
        NotificationCenter.default.removeObserver(self)
        badgeUpdateCallback = nil
    }
    
    // MARK: - Badge Protocol Implementation
    
    func setBadgeUpdateCallback(_ callback: @escaping (Int) -> Void) {
        self.badgeUpdateCallback = callback
        print("🔴 Stage4: Badge回調已設置")
        
        // 立即發送當前Badge值
        callback(unreadCount)
    }
    
    func clearBadge() {
        unreadCount = 0
        badgeUpdateCallback?(0)
        print("🔴 Stage4: Badge已清除")
    }
    
    // MARK: - NotificationCenter 核心邏輯
    private func setupNotificationListening() {
        // 🎯 Stage4魔法：DataService監聽自己的通知來觸發UI更新
        // 這創建了一個巧妙的間接更新機制
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDataChangeNotification(_:)),
            name: todoDataChangedNotification,
            object: nil
        )
        
        print("✅ Stage4: NotificationCenter監聽已設置")
    }
    
    @objc private func handleDataChangeNotification(_ notification: Notification) {
        // 🎯 Stage4核心：收到自己發送的通知後，觸發UI更新
        DispatchQueue.main.async {
            if let userInfo = notification.userInfo,
               let operation = userInfo["operation"] as? String,
               let count = userInfo["count"] as? Int {
                
                print("📢 Stage4: 處理資料變更通知 - \(operation), 總數: \(count)")
                
                // 🎯 關鍵：發送給UI層的通知
                self.notifyUIToUpdate(operation: operation, count: count)
            }
        }
    }
    
    private func postNotification(name: Notification.Name, userInfo: [String: Any]) {
        NotificationCenter.default.post(
            name: name,
            object: self,
            userInfo: userInfo
        )
        print("📤 Stage4: 發送通知 - \(name.rawValue)")
    }
    
    private func notifyUIToUpdate(operation: String, count: Int) {
        // 🎯 Stage4的關鍵創新：發送UI更新通知
        // 由於原始的ViewController會在viewWillAppear中調用reloadData
        // 我們利用這個機制來觸發更新
        
        let uiUpdateNotification = Notification.Name("Stage4_UIUpdateRequired")
        
        NotificationCenter.default.post(
            name: uiUpdateNotification,
            object: nil,
            userInfo: [
                "operation": operation,
                "count": count,
                "timestamp": Date(),
                "stage": "Stage4_NotificationCenter",
                "badge_count": unreadCount
            ]
        )
        
        print("🎨 Stage4: 發送UI更新通知 - \(operation)")
        print("💡 Stage4: ViewController的viewWillAppear將自動處理更新")
    }
    
    // MARK: - Badge相關方法
    
    private func updateBadgeForNewTodo() {
        unreadCount += 1
        badgeUpdateCallback?(unreadCount)
        print("🔴 Stage4: Badge自動更新 - \(unreadCount)")
    }
    
    // MARK: - NotificationCenter 示範不同用法
    private func demonstrateNotificationPatterns() {
        print("💡 Stage4 教學: NotificationCenter的不同使用模式")
        
        // 1. 簡單通知 (無資料)
        let simpleNotification = Notification.Name("SimpleNotification")
        NotificationCenter.default.post(name: simpleNotification, object: nil)
        
        // 2. 帶資料的通知
        let dataNotification = Notification.Name("DataNotification")
        NotificationCenter.default.post(
            name: dataNotification,
            object: self,
            userInfo: ["message": "Hello NotificationCenter", "value": 42]
        )
        
        // 3. 全域通知 (任何地方都能接收)
        let globalNotification = Notification.Name("GlobalNotification")
        NotificationCenter.default.post(name: globalNotification, object: nil)
        
        print("✅ Stage4: NotificationCenter使用模式示範完成")
    }
    
    // MARK: - 展示NotificationCenter的優勢
    private func demonstrateNotificationAdvantages() {
        print("""
        💡 Stage4 教學: NotificationCenter的優勢
        
        ✅ 一對多通訊: 一個通知可以被多個監聽者接收
        ✅ 鬆耦合: 發送者不需要知道接收者的存在
        ✅ 跨層級通訊: 可以跨越ViewController、ViewModel、Service層
        ✅ 動態監聽: 可以隨時新增或移除監聽者
        ✅ 攜帶資料: 可以透過userInfo傳遞複雜資料
        ✅ Badge支援: 實現即時Badge更新
        
        ⚠️ 注意事項:
        - 記得在deinit中移除監聽 (removeObserver)
        - 通知名稱要避免衝突
        - 弱型別，runtime才會發現錯誤
        - 難以追蹤通知的流向
        
        🎯 Stage4的創新:
        利用既有的viewWillAppear機制來實現UI自動更新，
        現在還加上了Badge即時反饋，
        而不需要修改任何ViewController的程式碼！
        
        🔴 Badge特色:
        Stage4是第一個支援Badge自動更新的階段，
        讓用戶明顯感受到自動同步的威力！
        """)
    }
}
