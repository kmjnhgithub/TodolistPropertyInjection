//
//  TodoDataServiceProtocol.swift
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/2.
//

// MARK: - TodoDataService Protocol
protocol TodoDataServiceProtocol {
    func getAllTodos() -> [Todo]
    func addTodo(_ todo: Todo)
    func deleteTodo(by uuid: String)
    func updateTodo(_ todo: Todo)
    
    // 用於不同階段的特殊處理
    func setupDataBinding(for viewModel: Any)
    func cleanup()
}
