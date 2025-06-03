//
//  AddTodoViewModel.swift
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/2.
//

// MARK: - AddTodo ViewModel
class AddTodoViewModel {
    private let dataService: TodoDataServiceProtocol
    
    init(dataService: TodoDataServiceProtocol = ServiceContainer.shared.getDataService()) {
        self.dataService = dataService
        self.dataService.setupDataBinding(for: self)
    }
    
    deinit {
        dataService.cleanup()
    }
    
    func addTodo(title: String) {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print(" 不能新增空白的Todo")
            return
        }
        
        let newTodo = Todo(title: title)
        dataService.addTodo(newTodo)
        print("  新增Todo成功: \(title)")
    }
}
