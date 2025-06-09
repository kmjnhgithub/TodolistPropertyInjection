//
//  Untitled.swift
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/5.
//

// MARK: - TodoListViewModel 統一接口(業務邏輯層)
// 這個接口讓 Stage 1-6 (UIKit) 和 Stage 7+ (Combine) 可以無縫切換
// 同時保持 ViewController 程式碼的一致性

import Foundation

protocol TodoListViewModelProtocol: AnyObject {
    
    // MARK: - 資料存取
    /// 獲取所有 Todo 項目
    var todos: [Todo] { get }
    
    // MARK: - Badge 管理
    /// Badge 更新回調 - 統一的接口，不管底層是 UIKit 還是 Combine
    var badgeUpdateHandler: ((Int) -> Void)? { get set }
    
    // MARK: - CRUD 操作
    /// 新增 Todo
    /// - Parameter title: Todo 標題
    func addTodo(title: String)
    
    /// 刪除指定索引的 Todo
    /// - Parameter index: 要刪除的索引
    func deleteTodo(at index: Int)
    
    /// 刪除指定 UUID 的 Todo
    /// - Parameter uuid: 要刪除的 UUID
    func deleteTodo(by uuid: String)
    
    /// 切換指定索引 Todo 的完成狀態
    /// - Parameter index: 要切換的索引
    func toggleTodoCompletion(at index: Int)
    
    // MARK: - 資料查詢
    /// 根據索引獲取 Todo
    /// - Parameter index: 索引
    /// - Returns: Todo 物件
    func getTodo(at index: Int) -> Todo
    
    /// 根據 UUID 獲取 Todo
    /// - Parameter uuid: UUID
    /// - Returns: Todo 物件（可能為 nil）
    func getTodo(by uuid: String) -> Todo?
    
    // MARK: - Badge 操作
    /// 標記 Badge 為已查看（清除 Badge）
    /// 當用戶切換到 Todo 清單頁面時調用
    func markBadgeAsViewed()
}

// MARK: - Protocol 設計說明
/*
設計原則：

1. **統一接口**：
   - Stage 1-6 使用 UIKit 版本實作
   - Stage 7+ 使用 Combine 版本實作
   - ViewController 無需知道底層實作差異

2. **Badge 策略**：
   - 使用回調機制作為最小公約數
   - UIKit 版本：直接使用回調
   - Combine 版本：橋接 @Published 到回調

3. **學習價值**：
   - 展示接口設計的重要性
   - 體驗多型（Polymorphism）的實際應用
   - 理解抽象層如何隔離實作細節

4. **擴展性**：
   - 未來可以輕易新增其他實作版本
   - 不影響現有的 ViewController 程式碼
   - 保持向後兼容性

注意事項：
- 所有方法都必須在兩個實作版本中保持一致
- Badge 回調必須在主線程執行
- 記憶體管理要特別注意 weak reference
*/
