//
//  TodoListViewModel.swift (Debug版本)
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/2.
//

// MARK: - TodoListViewModel UIKit 版本 (Stage 1-6)
// 🎯 純 UIKit 實作，不使用任何 Combine 框架
// 適用於 Stage 1-6，展示傳統 iOS 開發模式

import Foundation

class TodoListViewModel_UIKit: TodoListViewModelProtocol {
    
    // MARK: - 屬性
    private let dataService: TodoDataServiceProtocol
    
    // 🎯 傳統 Badge 管理 - 使用簡單屬性 + 回調
    private var _badgeCount: Int = 0 {
        didSet {
            print("🔍 UIKit ViewModel badgeCount 變更: \(oldValue) -> \(_badgeCount)")
            // 🎯 在主線程執行回調，確保 UI 更新安全
            DispatchQueue.main.async { [weak self] in
                self?.badgeUpdateHandler?(self?._badgeCount ?? 0)
            }
        }
    }
    
    // 🎯 Badge 更新回調 - 對外接口
    var badgeUpdateHandler: ((Int) -> Void)?
    
    // MARK: - 初始化
    init(dataService: TodoDataServiceProtocol) {
        print("🔍 TodoListViewModel_UIKit: 初始化開始")
        self.dataService = dataService
        
        print("🔍 DataService類型: \(type(of: self.dataService))")
        
        // 設置 DataService 綁定
        self.dataService.setupDataBinding(for: self)
        
        // 🎯 設置 Badge 訂閱（傳統回調方式）
        setupBadgeSubscription()
        
        print("🔍 TodoListViewModel_UIKit: 初始化完成，當前Badge: \(_badgeCount)")
    }
    
    deinit {
        // 清理資源
        dataService.cleanup()
        print("🧹 TodoListViewModel_UIKit: 清理完成")
    }
    
    // MARK: - TodoListViewModelProtocol 實作
    
    var todos: [Todo] {
        return dataService.getAllTodos()
    }
    
    func addTodo(title: String) {
        let newTodo = Todo(title: title)
        dataService.addTodo(newTodo)
        print("✅ UIKit ViewModel: 新增Todo - \(title)")
    }
    
    func deleteTodo(at index: Int) {
        let todoToDelete = todos[index]
        dataService.deleteTodo(by: todoToDelete.uuid)
        print("❌ UIKit ViewModel: 刪除Todo at index \(index)")
    }
    
    func deleteTodo(by uuid: String) {
        dataService.deleteTodo(by: uuid)
        print("❌ UIKit ViewModel: 刪除Todo by uuid \(uuid)")
    }
    
    func toggleTodoCompletion(at index: Int) {
        var todo = todos[index]
        todo.isCompleted.toggle()
        dataService.updateTodo(todo)
        print("🔄 UIKit ViewModel: 切換Todo完成狀態 - \(todo.title)")
    }
    
    func getTodo(at index: Int) -> Todo {
        print("📋 UIKit ViewModel: getTodo at index \(index)")
        return todos[index]
    }
    
    func getTodo(by uuid: String) -> Todo? {
        print("📋 UIKit ViewModel: getTodo by uuid \(uuid)")
        return todos.first { $0.uuid == uuid }
    }
    
    func markBadgeAsViewed() {
        print("🔍 UIKit ViewModel: markBadgeAsViewed 被調用，當前Badge: \(_badgeCount)")
        
        // 🎯 當用戶查看 Todo 清單時，清除 Badge
        if _badgeCount > 0 {
            print("🔍 UIKit ViewModel: 清除Badge: \(_badgeCount) -> 0")
            _badgeCount = 0
            dataService.clearBadge()
            print("👁️ UIKit ViewModel: Badge已清除: 用戶已查看清單")
        } else {
            print("🔍 UIKit ViewModel: Badge已經是0，無需清除")
        }
    }
    
    // MARK: - 私有方法
    
    private func setupBadgeSubscription() {
        print("🔍 UIKit ViewModel: 開始設置Badge訂閱")
        
        // 🎯 檢查當前Stage是否支援Badge
        let currentStage = StageConfigurationManager.shared.getCurrentStage()
        
        guard currentStage.badgeSupported else {
            print("🔍 UIKit ViewModel: \(currentStage.displayName) 不支援Badge，設置空回調")
            // Stage 1-3: 設置空回調，Badge始終為0
            _badgeCount = 0
            return
        }
        
        print("🔍 UIKit ViewModel: \(currentStage.displayName) 支援Badge，設置DataService回調")
        
        // 🎯 Stage 4-6: 設置DataService的Badge回調
        dataService.setBadgeUpdateCallback { [weak self] count in
            print("🔍 UIKit ViewModel: 收到DataService Badge回調更新: \(count)")
            
            // 確保在主線程更新
            DispatchQueue.main.async {
                self?._badgeCount = count
                print("🔴 UIKit ViewModel: Badge回調更新完成: \(count)")
            }
        }
        
        print("✅ UIKit ViewModel: Badge訂閱設置完成")
        
        // 🔍 立即檢查當前Badge值
        print("🔍 UIKit ViewModel: 設置完成後的Badge值: \(_badgeCount)")
    }
}

// MARK: - UIKit ViewModel 特性說明
/*
🎯 UIKit 版本特點：

1. **純 UIKit 實作**：
   - 不引入任何 Combine 框架
   - 使用傳統的屬性觀察器 (didSet)
   - 手動管理回調機制

2. **Stage 相容性**：
   - Stage 1-3: Badge 功能禁用，始終為 0
   - Stage 4-6: Badge 自動更新，支援即時同步
   - 透過 StageConfigurationManager 判斷功能可用性

3. **記憶體管理**：
   - 使用 weak self 避免循環引用
   - 在 deinit 中清理 DataService
   - 主線程安全的回調執行

4. **教學價值**：
   - 展示傳統 iOS 開發模式
   - 理解手動記憶體管理的重要性
   - 體驗命令式程式設計風格

5. **與 Combine 版本對比**：
   - 更多手動管理的程式碼
   - 明確的生命週期控制
   - 較為直觀的執行流程

⚠️ 注意事項：
- 所有 UI 更新回調都在主線程執行
- Badge 狀態變更會自動觸發回調
- 記得在適當時機調用 markBadgeAsViewed()
*/
