//
//  TodoListViewModel.swift
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/2.
//

// MARK: - TodoList ViewModel
class TodoListViewModel {
    private let dataService: TodoDataServiceProtocol
    
    // 🎯 依賴注入：外部傳入DataService
    init(dataService: TodoDataServiceProtocol = ServiceContainer.shared.getDataService()) {
        self.dataService = dataService
        self.dataService.setupDataBinding(for: self)
    }
    
    deinit {
        dataService.cleanup()
    }
    
    // MARK: - Data Operations
    var todos: [Todo] {
        return dataService.getAllTodos()
    }
    
    func addTodo(title: String) {
        let newTodo = Todo(title: title)
        dataService.addTodo(newTodo)
    }
    
    func deleteTodo(at index: Int) {
        let todoToDelete = todos[index]
        dataService.deleteTodo(by: todoToDelete.uuid)
    }
    
    func deleteTodo(by uuid: String) {
        dataService.deleteTodo(by: uuid)
    }
    
    func toggleTodoCompletion(at index: Int) {
        var todo = todos[index]
        todo.isCompleted.toggle()
        dataService.updateTodo(todo)
    }
    
    func getTodo(at index: Int) -> Todo {
        print("at index: Int")
        return todos[index]
    }
    
    func getTodo(by uuid: String) -> Todo? {
        print("by uuid: String")
        return todos.first { $0.uuid == uuid }
    }
}
