//
//  TodoListViewModel.swift (Debug版本)
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/2.
//

// MARK: - TodoListViewModel Combine 版本 (Stage 7+)
// 使用 Combine 框架的響應式實作
// 適用於 Stage 7+，展示現代 iOS 響應式開發模式

import Foundation
import Combine

class TodoListViewModel_Combine: ObservableObject, TodoListViewModelProtocol {
    
    // MARK: - 屬性
    private let dataService: TodoDataServiceProtocol
    
    // Combine Badge 管理 - 使用 @Published 響應式屬性
    @Published var badgeCount: Int = 0 {
        didSet {
            print("Combine ViewModel badgeCount 變更: \(oldValue) -> \(badgeCount)")
        }
    }
    
    // Badge 更新回調 - 橋接到傳統接口
    var badgeUpdateHandler: ((Int) -> Void)? {
        didSet {
            // 當設置回調時，建立 Combine 到傳統回調的橋接
            setupBadgeCallbackBridge()
        }
    }
    
    // Combine 訂閱管理
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 初始化
    init(dataService: TodoDataServiceProtocol) {
        print("TodoListViewModel_Combine: 初始化開始")
        self.dataService = dataService
        
        print("DataService類型: \(type(of: self.dataService))")
        
        // 設置 DataService 綁定
        self.dataService.setupDataBinding(for: self)
        
        // 設置 Badge 訂閱（Combine 響應式方式）
        setupBadgeSubscription()
        
        print("TodoListViewModel_Combine: 初始化完成，當前Badge: \(badgeCount)")
    }
    
    deinit {
        // Combine 自動記憶體管理
        cancellables.removeAll()
        dataService.cleanup()
        print("TodoListViewModel_Combine: 清理所有Combine訂閱")
    }
    
    // MARK: - TodoListViewModelProtocol 實作
    
    var todos: [Todo] {
        return dataService.getAllTodos()
    }
    
    func addTodo(title: String) {
        let newTodo = Todo(title: title)
        dataService.addTodo(newTodo)
        print("Combine ViewModel: 新增Todo - \(title)")
    }
    
    func deleteTodo(at index: Int) {
        let todoToDelete = todos[index]
        dataService.deleteTodo(by: todoToDelete.uuid)
        print("Combine ViewModel: 刪除Todo at index \(index)")
    }
    
    func deleteTodo(by uuid: String) {
        dataService.deleteTodo(by: uuid)
        print("Combine ViewModel: 刪除Todo by uuid \(uuid)")
    }
    
    func toggleTodoCompletion(at index: Int) {
        var todo = todos[index]
        todo.isCompleted.toggle()
        dataService.updateTodo(todo)
        print("Combine ViewModel: 切換Todo完成狀態 - \(todo.title)")
    }
    
    func getTodo(at index: Int) -> Todo {
        print("Combine ViewModel: getTodo at index \(index)")
        return todos[index]
    }
    
    func getTodo(by uuid: String) -> Todo? {
        print("Combine ViewModel: getTodo by uuid \(uuid)")
        return todos.first { $0.uuid == uuid }
    }
    
    func markBadgeAsViewed() {
        print("Combine ViewModel: markBadgeAsViewed 被調用，當前Badge: \(badgeCount)")
        
        // 當用戶查看 Todo 清單時，清除 Badge
        if badgeCount > 0 {
            print("Combine ViewModel: 清除Badge: \(badgeCount) -> 0")
            badgeCount = 0
            dataService.clearBadge()
            print("Combine ViewModel: Badge已清除: 用戶已查看清單")
        } else {
            print("Combine ViewModel: Badge已經是0，無需清除")
        }
    }
    
    // MARK: - 私有方法 - Combine 響應式處理
    
    private func setupBadgeSubscription() {
        print("Combine ViewModel: 開始設置Badge響應式訂閱")
        
        // 檢查是否為 Stage7 的 CombineDataService
        if let combineService = dataService as? Stage7_CombineDataService {
            print("Combine ViewModel: 檢測到Stage7_CombineDataService，使用響應式Badge")
            
            // Stage7: 使用 Combine 響應式 Badge Publisher
            combineService.badgePublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] count in
                    print("Combine ViewModel: 收到Stage7響應式Badge更新: \(count)")
                    self?.badgeCount = count
                    print("Combine ViewModel: Badge響應式更新完成: \(count)")
                }
                .store(in: &cancellables)
            
            print("Combine ViewModel: 已訂閱Stage7響應式Badge Publisher")
            
        } else {
            print("Combine ViewModel: 非Stage7，使用Badge回調機制")
            
            // 其他Stage: 使用傳統回調（理論上不會發生，但保持向後兼容）
            dataService.setBadgeUpdateCallback { [weak self] count in
                print("Combine ViewModel: 收到Badge回調更新: \(count)")
                DispatchQueue.main.async {
                    self?.badgeCount = count
                    print("Combine ViewModel: Badge回調更新完成: \(count)")
                }
            }
            print("Combine ViewModel: 已設置Badge回調")
        }
        
        // 立即檢查當前Badge值
        print("Combine ViewModel: 設置完成後的Badge值: \(badgeCount)")
    }
    
    private func setupBadgeCallbackBridge() {
        // 橋接 Combine @Published 到傳統回調接口
        // 這讓 ViewController 可以使用統一的回調接口，不管底層是 UIKit 還是 Combine
        
        guard badgeUpdateHandler != nil else { return }
        
        print("Combine ViewModel: 設置Badge回調橋接")
        
        $badgeCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                print("Combine ViewModel: Badge橋接回調觸發: \(count)")
                self?.badgeUpdateHandler?(count)
            }
            .store(in: &cancellables)
        
        print("Combine ViewModel: Badge回調橋接已建立")
    }
    
    // MARK: - Combine 特有功能展示
    
    /// 展示 Combine 的進階功能（可選）
    func demonstrateAdvancedCombineFeatures() {
        print("Combine ViewModel: 展示進階Combine功能")
        
        // 示範1: 複雜的資料流轉換
        $badgeCount
            .map { count in
                return count > 0 ? "有 \(count) 個未讀" : "沒有未讀"
            }
            .sink { message in
                print("Combine ViewModel: Badge狀態描述: \(message)")
            }
            .store(in: &cancellables)
        
        // 示範2: 防抖動處理
        $badgeCount
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { count in
                print("Combine ViewModel: 防抖動Badge更新: \(count)")
            }
            .store(in: &cancellables)
        
        // 示範3: 條件過濾
        $badgeCount
            .filter { $0 > 5 }
            .sink { count in
                print("Combine ViewModel: Badge數量過多警告: \(count)")
            }
            .store(in: &cancellables)
    }
    
    /// 獲取 Badge 的 Publisher（給需要直接訂閱的組件使用）
    var badgePublisher: AnyPublisher<Int, Never> {
        return $badgeCount.eraseToAnyPublisher()
    }
    
    /// 除錯用：印出所有活躍的訂閱
    func debugActiveSubscriptions() {
        print("""
        Combine ViewModel 除錯資訊:
        ===============================
        活躍訂閱數: \(cancellables.count)
        當前Badge值: \(badgeCount)
        DataService類型: \(type(of: dataService))
        回調橋接: \(badgeUpdateHandler != nil ? "已設置" : "未設置")
        ===============================
        """)
    }
}

// MARK: - Combine ViewModel 特性說明
/*
Combine 版本特點：

1. **響應式架構**：
   - 使用 @Published 屬性自動觸發更新
   - AnyCancellable 自動管理訂閱生命週期
   - 聲明式的資料流處理

2. **Stage7 特化**：
   - 專門為 Stage7_CombineDataService 設計
   - 使用 Publisher/Subscriber 模式
   - 展示現代 iOS 響應式開發

3. **向後兼容**：
   - 實作統一的 TodoListViewModelProtocol 接口
   - 提供傳統回調橋接機制
   - 保持與 UIKit 版本的行為一致性

4. **進階功能**：
   - 提供額外的 Combine 操作子示範
   - 支援複雜的資料流轉換
   - 內建防抖動和過濾功能

5. **記憶體管理**：
   - Combine 自動處理訂閱生命週期
   - 使用 weak self 避免循環引用
   - Set<AnyCancellable> 統一管理所有訂閱

6. **除錯支援**：
   - 豐富的日誌輸出
   - 訂閱狀態監控
   - 便於追蹤響應式資料流

⚡ 與 UIKit 版本對比：
- 更少的手動記憶體管理
- 更優雅的資料流處理
- 更強大的組合和轉換能力
- 更符合現代 iOS 開發趨勢

🎓 學習價值：
- 體驗響應式程式設計的威力
- 理解 Publisher/Subscriber 模式
- 掌握 Combine 框架的實際應用
- 感受聲明式 vs 命令式的差異
*/
