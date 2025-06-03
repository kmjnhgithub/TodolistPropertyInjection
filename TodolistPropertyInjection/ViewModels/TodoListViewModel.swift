//
//  TodoListViewModel.swift (Debug版本)
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/2.
//

// MARK: - TodoList ViewModel (Badge除錯版)
import Foundation
import Combine

class TodoListViewModel: ObservableObject {
    private let dataService: TodoDataServiceProtocol
    
    // 🎯 新增：Badge支援 - UI狀態管理
    @Published var badgeCount: Int = 0 {
        didSet {
            print("🔍 ViewModel badgeCount 變更: \(oldValue) -> \(badgeCount)")
        }
    }
    
    // 🎯 Combine支援：管理訂閱生命週期
    private var cancellables = Set<AnyCancellable>()
    
    // 🎯 依賴注入：外部傳入DataService
    init(dataService: TodoDataServiceProtocol = ServiceContainer.shared.getDataService()) {
        print("🔍 TodoListViewModel: 初始化開始")
        self.dataService = dataService
        
        print("🔍 DataService類型: \(type(of: self.dataService))")
        
        self.dataService.setupDataBinding(for: self)
        
        // 🎯 設置Badge訂閱（如果DataService支援）
        setupBadgeSubscription()
        
        print("🔍 TodoListViewModel: 初始化完成，當前Badge: \(badgeCount)")
    }
    
    deinit {
        dataService.cleanup()
        // 🎯 清理Combine訂閱
        cancellables.removeAll()
        print("🧹 TodoListViewModel: 清理所有訂閱")
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
    
    // MARK: - Badge相關方法 (Debug版)
    
    private func setupBadgeSubscription() {
        print("🔍 開始設置Badge訂閱")
        
        // 🎯 檢查DataService是否支援Badge
        if let combineService = dataService as? Stage7_CombineDataService {
            print("✅ 檢測到Stage7_CombineDataService，使用響應式Badge")
            
            // Stage7: 使用Combine響應式Badge
            combineService.badgePublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] count in
                    print("🔍 收到Stage7響應式Badge更新: \(count)")
                    self?.badgeCount = count
                    print("🔴 Badge更新完成: \(count)")
                }
                .store(in: &cancellables)
            
            print("✅ TodoListViewModel: 已訂閱Stage7響應式Badge")
        } else {
            print("🔍 非Stage7，使用Badge回調機制")
            
            // Stage1-6: 檢查是否有Badge回調支援
            dataService.setBadgeUpdateCallback { [weak self] count in
                print("🔍 收到Badge回調更新: \(count)")
                DispatchQueue.main.async {
                    self?.badgeCount = count
                    print("🔴 Badge回調更新完成: \(count)")
                }
            }
            print("✅ TodoListViewModel: 已設置Badge回調")
        }
        
        // 🔍 立即檢查當前Badge值
        print("🔍 設置完成後的Badge值: \(badgeCount)")
    }
    
    func markBadgeAsViewed() {
        print("🔍 markBadgeAsViewed 被調用，當前Badge: \(badgeCount)")
        
        // 🎯 當用戶查看Todo清單時，清除Badge
        if badgeCount > 0 {
            print("🔍 清除Badge: \(badgeCount) -> 0")
            badgeCount = 0
            dataService.clearBadge()
            print("👁️ Badge已清除: 用戶已查看清單")
        } else {
            print("🔍 Badge已經是0，無需清除")
        }
    }
}
