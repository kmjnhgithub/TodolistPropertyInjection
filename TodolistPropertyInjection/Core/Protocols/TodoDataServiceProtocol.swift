//
//  TodoDataServiceProtocol.swift
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/2.
//

// MARK: - TodoDataService Protocol (資料層,接收完整的Todo物件)
protocol TodoDataServiceProtocol {
    func getAllTodos() -> [Todo]
    func addTodo(_ todo: Todo)
    func deleteTodo(by uuid: String)
    func updateTodo(_ todo: Todo)
    
    // 用於不同階段的特殊處理
    func setupDataBinding(for viewModel: Any)
    func cleanup()
    
    // 新增：Badge支援接口
    func setBadgeUpdateCallback(_ callback: @escaping (Int) -> Void)
    func clearBadge()
}

// MARK: - Badge回調類型定義
typealias BadgeUpdateCallback = (Int) -> Void
