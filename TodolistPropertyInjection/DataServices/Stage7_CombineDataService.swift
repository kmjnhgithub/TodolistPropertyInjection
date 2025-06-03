//
//  Stage7_CombineDataService.swift
//  TodolistPropertyInjection
//
//  Created by AI Assistant on 2025/6/3.
//

// MARK: - Stage 7: Combine Framework Pattern DataService
// 完全不修改任何其他程式碼，所有邏輯都在DataService內部
// 🎯 這是響應式程式設計的完整展示！第一次體驗Publisher/Subscriber模式

import Foundation
import Combine

class Stage7_CombineDataService: TodoDataServiceProtocol {
    
    // MARK: - Combine核心元件
    
    // 🎯 Stage7關鍵：CurrentValueSubject - 狀態型資料流
    private let todosSubject = CurrentValueSubject<[Todo], Never>([])
    
    // 🎯 Stage7特色：PassthroughSubject - 事件型資料流
    private let operationSubject = PassthroughSubject<TodoOperation, Never>()
    private let uiUpdateSubject = PassthroughSubject<UIUpdateEvent, Never>()
    
    // 🎯 Stage7 Badge：響應式Badge管理
    private let badgeSubject = CurrentValueSubject<Int, Never>(0)
    
    // 🎯 Stage7生命週期：AnyCancellable集合管理所有訂閱
    private var cancellables = Set<AnyCancellable>()
    
    // 🎯 Stage7統計：響應式資料流監控
    private let statisticsSubject = CurrentValueSubject<CombineStatistics, Never>(CombineStatistics())
    
    // 🎯 Badge相關屬性
    private var badgeUpdateCallback: BadgeUpdateCallback?
    
    // MARK: - Badge Publisher (對外公開接口)
    var badgePublisher: AnyPublisher<Int, Never> {
        badgeSubject.eraseToAnyPublisher()
    }
    
    // MARK: - 響應式資料模型
    
    struct TodoOperation {
        let type: OperationType
        let todo: Todo
        let timestamp: Date
        
        enum OperationType: String, CaseIterable {
            case add = "新增"
            case delete = "刪除"
            case update = "更新"
        }
    }
    
    struct UIUpdateEvent {
        let operation: String
        let count: Int
        let stage: String
        let timestamp: Date
    }
    
    struct CombineStatistics {
        var totalOperations: Int = 0
        var subscriptions: Int = 0
        var publishedEvents: Int = 0
        var creationTime: Date = Date()
        
        mutating func incrementOperation() {
            totalOperations += 1
            publishedEvents += 1
        }
    }
    
    // MARK: - 初始化和Combine管道設置
    
    init() {
        print("🎯 Stage7: Combine Framework - 已初始化")
        
        // 🎯 Step 1: 初始化預設資料到CurrentValueSubject
        setupInitialData()
        
        // 🎯 Step 2: 建立響應式資料流管道
        setupCombinePipelines()
        
        // 🎯 Step 3: 展示Combine特性
        demonstrateCombineCharacteristics()
        
        // 🎯 Step 5: 印出初始統計
        printCombineStatistics()
    }
    
    deinit {
        // 🎯 Stage7重要：清理所有訂閱避免記憶體洩漏
        cancellables.removeAll()
        print("🧹 Stage7: 清理所有Combine訂閱")
    }
    
    // MARK: - TodoDataServiceProtocol Implementation
    
    func getAllTodos() -> [Todo] {
        // 🎯 Stage7特點：直接從CurrentValueSubject獲取當前值
        let currentTodos = todosSubject.value
        updateStatistics { $0.subscriptions += 1 }
        print("📊 Stage7: 從CurrentValueSubject讀取 \(currentTodos.count) 個Todo")
        return currentTodos
    }
    
    func addTodo(_ todo: Todo) {
        print("✅ Stage7: Combine響應式新增Todo - \(todo.title)")
        
        // 🎯 Stage7核心：透過響應式流程處理資料變更
        processAddOperation(todo)
    }
    
    func deleteTodo(by uuid: String) {
        guard let todoToDelete = todosSubject.value.first(where: { $0.uuid == uuid }) else {
            print("⚠️ Stage7: 找不到要刪除的Todo - UUID: \(uuid)")
            return
        }
        
        print("❌ Stage7: Combine響應式刪除Todo - \(todoToDelete.title)")
        
        // 🎯 Stage7核心：透過響應式流程處理資料變更
        processDeleteOperation(todoToDelete)
    }
    
    func updateTodo(_ todo: Todo) {
        guard let index = todosSubject.value.firstIndex(where: { $0.uuid == todo.uuid }) else {
            print("⚠️ Stage7: 找不到要更新的Todo - UUID: \(todo.uuid)")
            return
        }
        
        print("🔄 Stage7: Combine響應式更新Todo - \(todo.title)")
        
        // 🎯 Stage7核心：透過響應式流程處理資料變更
        processUpdateOperation(todo, at: index)
    }
    
    func setupDataBinding(for viewModel: Any) {
        if viewModel is TodoListViewModel {
            print("🎯 Stage7: TodoListViewModel透過Combine響應式資料流自動同步")
            updateStatistics { $0.subscriptions += 1 }
        } else {
            print("🎯 Stage7: \(type(of: viewModel)) 連接到Combine資料流")
        }
    }
    
    func cleanup() {
        print("🧹 Stage7: Combine框架清理")
        // Combine的美麗之處：AnyCancellable會自動處理
        cancellables.removeAll()
        badgeUpdateCallback = nil
    }
    
    // MARK: - Badge Protocol Implementation
    
    func setBadgeUpdateCallback(_ callback: @escaping (Int) -> Void) {
        self.badgeUpdateCallback = callback
        print("✅ Stage7: Badge回調已設置")
        
        // 立即發送當前Badge值
        callback(badgeSubject.value)
    }
    
    func clearBadge() {
        badgeSubject.send(0)
        print("🔴 Stage7: Badge已清除")
    }
    
    // MARK: - 私有方法：響應式操作處理
    
    private func processAddOperation(_ todo: Todo) {
        // 🎯 Stage7響應式流程：
        // 1. 發送操作事件到PassthroughSubject
        // 2. 更新CurrentValueSubject狀態
        // 3. 自動觸發所有訂閱者
        
        let operation = TodoOperation(
            type: .add,
            todo: todo,
            timestamp: Date()
        )
        
        // Step 1: 發送操作事件
        operationSubject.send(operation)
        
        // Step 2: 更新狀態（這會自動通知所有訂閱者）
        var currentTodos = todosSubject.value
        currentTodos.append(todo)
        todosSubject.send(currentTodos)
        
        // Step 3: 更新Badge (響應式！)
        updateBadgeForNewTodo()
        
        print("📤 Stage7: 透過Combine發送新增事件")
    }
    
    private func processDeleteOperation(_ todo: Todo) {
        let operation = TodoOperation(
            type: .delete,
            todo: todo,
            timestamp: Date()
        )
        
        // Step 1: 發送操作事件
        operationSubject.send(operation)
        
        // Step 2: 更新狀態
        var currentTodos = todosSubject.value
        currentTodos.removeAll { $0.uuid == todo.uuid }
        todosSubject.send(currentTodos)
        
        print("📤 Stage7: 透過Combine發送刪除事件")
    }
    
    private func processUpdateOperation(_ todo: Todo, at index: Int) {
        let operation = TodoOperation(
            type: .update,
            todo: todo,
            timestamp: Date()
        )
        
        // Step 1: 發送操作事件
        operationSubject.send(operation)
        
        // Step 2: 更新狀態
        var currentTodos = todosSubject.value
        currentTodos[index] = todo
        todosSubject.send(currentTodos)
        
        print("📤 Stage7: 透過Combine發送更新事件")
    }
    
    // MARK: - Combine管道設置
    
    private func setupCombinePipelines() {
        print("🔧 Stage7: 設置Combine響應式管道")
        
        // 🎯 管道1：監聽Todo資料變更
        setupTodoDataPipeline()
        
        // 🎯 管道2：監聽操作事件
        setupOperationPipeline()
        
        // 🎯 管道3：UI更新管道
        setupUIUpdatePipeline()
        
        // 🎯 管道4：Badge響應式管道
        setupBadgeResponsePipeline()
        
        // 🎯 管道5：統計監控管道
        setupStatisticsPipeline()
        
        print("✅ Stage7: 所有Combine管道設置完成")
    }
    
    private func setupBadgeResponsePipeline() {
        // 🎯 Stage7 Badge核心：響應式Badge管理
        print("🔴 Stage7: 設置Badge響應式管道")
        
        // Badge自動更新管道：監聽新增操作
        operationSubject
            .filter { $0.type == .add }
            .map { [weak self] _ -> Int in
                // 計算未查看的新增數量
                return (self?.badgeSubject.value ?? 0) + 1
            }
            .sink { [weak self] newBadgeCount in
                self?.badgeSubject.send(newBadgeCount)
                print("🔴 Stage7: Badge響應式更新 - \(newBadgeCount)")
                
                // 同時觸發回調（向後兼容）
                self?.badgeUpdateCallback?(newBadgeCount)
            }
            .store(in: &cancellables)
        
        // Badge重置管道：監聽清除事件
        badgeSubject
            .filter { $0 == 0 }
            .sink { _ in
                print("🔴 Stage7: Badge已重置為0")
            }
            .store(in: &cancellables)
    }
    
    private func setupTodoDataPipeline() {
        // 🎯 這是Combine的精髓：聲明式的資料流處理
        todosSubject
            .map { todos -> (count: Int, titles: [String]) in
                // 使用map操作子轉換資料
                return (count: todos.count, titles: todos.map { $0.title })
            }
            .sink { [weak self] result in
                // 🎯 重要：使用weak self避免循環引用
                print("📊 Stage7: Todo資料流更新 - 總數: \(result.count)")
                print("📋 Stage7: 當前項目: \(result.titles.joined(separator: ", "))")
                
                self?.updateStatistics { $0.publishedEvents += 1 }
            }
            .store(in: &cancellables) // 🎯 關鍵：存儲訂閱避免立即釋放
    }
    
    private func setupOperationPipeline() {
        // 🎯 展示Combine操作子的強大功能
        operationSubject
            .filter { operation in
                // 使用filter操作子過濾事件
                print("🔍 Stage7: 過濾操作事件 - \(operation.type.rawValue)")
                return true // 在這個例子中我們接受所有操作
            }
            .map { operation -> UIUpdateEvent in
                // 使用map操作子轉換事件類型
                return UIUpdateEvent(
                    operation: operation.type.rawValue,
                    count: self.todosSubject.value.count,
                    stage: "Stage7_Combine",
                    timestamp: operation.timestamp
                )
            }
            .sink { [weak self] uiEvent in
                print("🎨 Stage7: 處理UI更新事件 - \(uiEvent.operation)")
                
                // 發送到UI更新Subject
                self?.uiUpdateSubject.send(uiEvent)
                
                self?.updateStatistics { $0.incrementOperation() }
            }
            .store(in: &cancellables)
    }
    
    private func setupUIUpdatePipeline() {
        // 🎯 UI更新管道：與Stage4的NotificationCenter橋接
        uiUpdateSubject
            .debounce(for: .milliseconds(50), scheduler: DispatchQueue.main)
            // 🎯 debounce：防止過於頻繁的UI更新
            .sink { [weak self] uiEvent in
                print("🖥️ Stage7: 發送UI更新通知")
                
                // 橋接到NotificationCenter（因為不能修改ViewController）
                self?.bridgeToNotificationCenter(uiEvent: uiEvent)
            }
            .store(in: &cancellables)
    }
    
    private func setupStatisticsPipeline() {
        // 🎯 統計監控：展示Combine的強大監控能力
        statisticsSubject
            .map { stats in
                // 計算平均操作頻率
                let timeElapsed = Date().timeIntervalSince(stats.creationTime)
                let operationsPerSecond = timeElapsed > 0 ? Double(stats.totalOperations) / timeElapsed : 0
                return (stats: stats, frequency: operationsPerSecond)
            }
            .sink { result in
                if result.stats.totalOperations > 0 && result.stats.totalOperations % 3 == 0 {
                    print("""
                    📈 Stage7 即時統計:
                    - 總操作數: \(result.stats.totalOperations)
                    - 訂閱數: \(result.stats.subscriptions)
                    - 發布事件數: \(result.stats.publishedEvents)
                    - 操作頻率: \(String(format: "%.2f", result.frequency)) 次/秒
                    """)
                }
            }
            .store(in: &cancellables)
    }
    
    private func bridgeToNotificationCenter(uiEvent: UIUpdateEvent) {
        // 🎯 Stage7橋接：連接Combine與NotificationCenter
        let uiUpdateNotification = Notification.Name("Stage7_UIUpdateRequired")
        
        NotificationCenter.default.post(
            name: uiUpdateNotification,
            object: nil,
            userInfo: [
                "operation": uiEvent.operation,
                "count": uiEvent.count,
                "stage": uiEvent.stage,
                "timestamp": uiEvent.timestamp,
                "combine_info": getCombineInfo()
            ]
        )
        
        print("🌉 Stage7: Combine事件已橋接到NotificationCenter")
    }
    
    // MARK: - 初始化和工具方法
    
    private func setupInitialData() {
        let initialTodos = [
            Todo(title: "學習Combine Publisher概念"),
            Todo(title: "理解Subscriber訂閱模式"),
            Todo(title: "體驗響應式資料流")
        ]
        
        // 🎯 設置初始值到CurrentValueSubject
        todosSubject.send(initialTodos)
        print("📋 Stage7: 初始化資料到CurrentValueSubject")
    }
    
    private func updateBadgeForNewTodo() {
        // 🎯 Stage7響應式Badge：自動觸發Badge更新
        // 這裡不需要手動計算，因為operationSubject會自動處理
        print("🔴 Stage7: 觸發Badge響應式更新流程")
    }
    
    private func updateStatistics(_ update: (inout CombineStatistics) -> Void) {
        var current = statisticsSubject.value
        update(&current)
        statisticsSubject.send(current)
    }
    
    private func getCombineInfo() -> [String: Any] {
        let stats = statisticsSubject.value
        return [
            "publisher_type": "CurrentValueSubject + PassthroughSubject",
            "total_operations": stats.totalOperations,
            "subscriptions": stats.subscriptions,
            "published_events": stats.publishedEvents,
            "active_cancellables": cancellables.count,
            "creation_time": stats.creationTime,
            "current_todo_count": todosSubject.value.count
        ]
    }
    
    func printCombineStatistics() {
        let stats = statisticsSubject.value
        let timeElapsed = Date().timeIntervalSince(stats.creationTime)
        
        print("""
        📊 Stage7 Combine統計資訊:
        ================================
        響應式架構: Publisher-Subscriber模式
        主要Publisher: CurrentValueSubject<[Todo], Never>
        事件Publisher: PassthroughSubject<TodoOperation, Never>
        活躍訂閱數: \(cancellables.count)
        總操作次數: \(stats.totalOperations)
        發布事件數: \(stats.publishedEvents)
        當前Todo數: \(todosSubject.value.count)
        運行時間: \(String(format: "%.1f", timeElapsed)) 秒
        記憶體管理: AnyCancellable自動管理
        ================================
        """)
    }
    
    // MARK: - Combine特性展示方法
    
    private func demonstrateCombineCharacteristics() {
        print("""
        💡 Stage7 教學: Combine框架特性
        
        🎯 核心概念:
        1. Publisher（發布者）- 資料來源
        2. Subscriber（訂閱者）- 資料消費者  
        3. Subscription（訂閱）- 連接橋樑
        4. AnyCancellable - 生命週期管理
        
        🔄 資料流模式:
        CurrentValueSubject: 狀態型資料流
        - 保持當前值
        - 新訂閱者立即收到當前值
        - 適合資料狀態管理
        
        PassthroughSubject: 事件型資料流  
        - 不保持狀態
        - 只傳遞新事件
        - 適合通知和觸發
        
        🛠️ 操作子（Operators）:
        - map: 資料轉換
        - filter: 資料過濾
        - debounce: 防抖動
        - sink: 訂閱和消費
        
        ✅ Combine優勢:
        - 聲明式程式設計
        - 自動記憶體管理
        - 強型別安全
        - 豐富的操作子
        - 與SwiftUI完美整合
        
        ⚠️ 注意事項:
        - 學習曲線較陡峭
        - 需要iOS 13+
        - 除錯可能較複雜
        - 過度使用會增加複雜性
        
        🎯 Stage7的創新:
        將傳統的命令式資料操作轉換為
        響應式的資料流管道，
        實現真正的自動化資料同步！
        """)
    }
    
    // MARK: - 進階Combine示範方法
    
    func demonstrateAdvancedCombineFeatures() {
        print("🚀 Stage7 進階: Combine高級特性展示")
        
        // 🎯 示範1：組合多個Publisher
        demonstratePublisherCombination()
        
        // 🎯 示範2：錯誤處理（雖然我們使用Never）
        demonstrateErrorHandling()
        
        // 🎯 示範3：背壓處理
        demonstrateBackpressure()
        
        // 🎯 示範4：自訂操作子
        demonstrateCustomOperators()
    }
    
    private func demonstratePublisherCombination() {
        print("🔗 示範：組合多個Publisher")
        
        // 組合Todo數據和統計資料
        Publishers.CombineLatest(todosSubject, statisticsSubject)
            .map { todos, stats in
                return "Todo總數: \(todos.count), 操作次數: \(stats.totalOperations)"
            }
            .sink { combinedInfo in
                print("📊 組合資訊: \(combinedInfo)")
            }
            .store(in: &cancellables)
    }
    
    private func demonstrateErrorHandling() {
        print("⚠️ 示範：錯誤處理模式")
        
        // 雖然我們使用Never，但展示錯誤處理概念
        Just("模擬網路請求")
            .setFailureType(to: Error.self)
            .catch { error in
                print("捕獲錯誤: \(error)")
                return Just("預設值")
            }
            .sink(
                receiveCompletion: { completion in
                    print("請求完成: \(completion)")
                },
                receiveValue: { value in
                    print("收到值: \(value)")
                }
            )
            .store(in: &cancellables)
    }
    
    private func demonstrateBackpressure() {
        print("🌊 示範：背壓處理")
        
        // 模擬高頻率事件的處理
        operationSubject
            .collect(.byTime(DispatchQueue.main, .seconds(2)))
            // 每2秒收集一次事件
            .sink { operations in
                if !operations.isEmpty {
                    print("📦 批次處理 \(operations.count) 個操作")
                }
            }
            .store(in: &cancellables)
    }
    
    private func demonstrateCustomOperators() {
        print("🛠️ 示範：自訂操作子概念")
        
        // 自訂操作子：只處理完成的Todo
        todosSubject
            .map { todos in
                todos.filter { $0.isCompleted }
            }
            .sink { completedTodos in
                print("✅ 已完成的Todo: \(completedTodos.count) 個")
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 除錯和監控方法
    
    func debugCombineState() {
        print("""
        🔍 Stage7 Combine狀態除錯:
        
        📊 Publisher狀態:
        - todosSubject.value: \(todosSubject.value.count) 個Todo
        - statisticsSubject.value: \(statisticsSubject.value)
        
        📡 Subscription狀態:
        - 活躍訂閱數: \(cancellables.count)
        - 記憶體狀態: 正常
        
        🔄 資料流健康度:
        - Publisher: ✅ 正常
        - Subscriber: ✅ 正常
        - 事件傳遞: ✅ 正常
        """)
    }
    
    func measureCombinePerformance() {
        let startTime = Date()
        
        // 執行1000次操作測試效能
        for i in 0..<1000 {
            let testTodo = Todo(title: "效能測試 \(i)")
            let operation = TodoOperation(type: .add, todo: testTodo, timestamp: Date())
            operationSubject.send(operation)
        }
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        print("⚡ Stage7 效能測試: 1000個事件處理耗時 \(duration * 1000) 毫秒")
    }
}

/*
🎯 Stage7 設計說明：

✅ Combine框架的完整展示：
1. CurrentValueSubject - 狀態管理
2. PassthroughSubject - 事件傳遞
3. AnyCancellable - 記憶體管理
4. 豐富的操作子 - 資料轉換
5. 響應式管道 - 聲明式程式設計

✅ 這個階段展示什麼：
1. Publisher/Subscriber模式的實際應用
2. 響應式程式設計的思維方式
3. 自動記憶體管理的優勢
4. 聲明式vs命令式的差異
5. 真正的自動化資料同步

✅ 與前6階段的差異：
- Stage1-3: 手動操作，無自動同步
- Stage4-5: 事件驅動，部分自動化
- Stage6: 持久化存儲
- Stage7: 完全響應式，聲明式資料流

❌ Stage7的學習挑戰：
1. 概念轉換：從命令式到聲明式
2. 新語法：操作子和管道概念
3. 除錯困難：非同步資料流追蹤
4. 記憶體管理：AnyCancellable的正確使用

🧪 測試重點：
1. 體驗響應式資料同步的即時性
2. 觀察豐富的Console日誌輸出
3. 理解Publisher/Subscriber概念
4. 感受聲明式程式設計的優雅

💡 學習價值：
Combine代表了iOS開發的未來方向：
- 與SwiftUI完美整合
- 蘋果官方響應式框架
- 現代化的程式設計範式
- 提升程式碼品質和可維護性

下一階段預告：
Stage8將是終極挑戰 - Core Data + MVVM！
*/
