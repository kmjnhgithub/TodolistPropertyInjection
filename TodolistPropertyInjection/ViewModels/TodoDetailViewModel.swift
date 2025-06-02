//
//  TodoDetailViewModel.swift
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/2.
//

// MARK: - TodoDetail ViewModel
class TodoDetailViewModel {
    private let dataService: TodoDataServiceProtocol
    private var todoUUID: String
    
    init(todoUUID: String, dataService: TodoDataServiceProtocol = ServiceContainer.shared.getDataService()) {
        self.todoUUID = todoUUID
        self.dataService = dataService
        self.dataService.setupDataBinding(for: self)
    }
    
    deinit {
        dataService.cleanup()
    }
    
    var todo: Todo? {
        return dataService.getAllTodos().first { $0.uuid == todoUUID }
    }
    
    func deleteTodo() {
        dataService.deleteTodo(by: todoUUID)
    }
    
    func updateTodo(title: String) {
        guard var currentTodo = todo else { return }
        currentTodo.title = title
        dataService.updateTodo(currentTodo)
    }
    
    func toggleCompletion() {
        guard var currentTodo = todo else { return }
        currentTodo.isCompleted.toggle()
        dataService.updateTodo(currentTodo)
    }
}
