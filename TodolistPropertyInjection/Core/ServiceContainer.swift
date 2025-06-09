//
//  ServiceContainer.swift
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/2.
//

// MARK: - Enhanced DI Container with ViewModel Factory
// 升級版依賴注入容器，支援根據 Stage 自動選擇 ViewModel 類型
// 保持「一行切換」的特性，同時支援 UIKit 和 Combine 版本的 ViewModel

class ServiceContainer {
    static let shared = ServiceContainer()
    private init() {}
    
    // 編譯時切換：只需要改這一行！
    // 根據這個設定，整個 App 會自動選擇對應的 ViewModel 實作
    private let currentDataService: TodoDataServiceProtocol = Stage3_ClosureDataService()
    // Stage1_PropertyDataService
    // Stage2_DelegateDataService
    // Stage3_ClosureDataService
    // Stage4_NotificationDataService
    // Stage5_SingletonDataService
    // Stage6_UserDefaultsDataService
    // Stage7_CombineDataService
    
    // MARK: - DataService 工廠方法
    
    /// 獲取當前配置的 DataService
    /// - Returns: 當前階段的 DataService 實例
    func getDataService() -> TodoDataServiceProtocol {
        return currentDataService
    }
    
    // MARK: - ViewModel 工廠方法
    
    /// 核心：根據當前 Stage 自動選擇 TodoListViewModel 實作
    /// - Returns: 適合當前 Stage 的 TodoListViewModel 實例
    func createTodoListViewModel() -> TodoListViewModelProtocol {
        
        // 判斷邏輯：Stage 7+ 使用 Combine 版本，其他使用 UIKit 版本
        if currentDataService is Stage7_CombineDataService {
            print("ServiceContainer: 創建 Combine 版本 TodoListViewModel (Stage 7+)")
            return TodoListViewModel_Combine(dataService: currentDataService)
        } else {
            print("🔧 ServiceContainer: 創建 UIKit 版本 TodoListViewModel (Stage 1-6)")
            return TodoListViewModel_UIKit(dataService: currentDataService)
        }
    }
    
    /// 創建 TodoDetailViewModel
    /// - Parameter todoUUID: Todo 的 UUID
    /// - Returns: TodoDetailViewModel 實例
    func createTodoDetailViewModel(todoUUID: String) -> TodoDetailViewModel {
        print("ServiceContainer: 創建 TodoDetailViewModel")
        return TodoDetailViewModel(todoUUID: todoUUID, dataService: currentDataService)
    }
    
    /// 創建 AddTodoViewModel
    /// - Returns: AddTodoViewModel 實例
    func createAddTodoViewModel() -> AddTodoViewModel {
        print("ServiceContainer: 創建 AddTodoViewModel")
        return AddTodoViewModel(dataService: currentDataService)
    }
    
    // MARK: - 工具方法
    
    /// 獲取當前 Stage 資訊
    /// - Returns: 當前 Stage 的配置資訊
    func getCurrentStageInfo() -> TodoDataStage {
        return StageConfigurationManager.shared.getCurrentStage()
    }
    
    /// 檢查當前 Stage 是否支援 Badge
    /// - Returns: true 如果支援 Badge
    func isBadgeSupported() -> Bool {
        return getCurrentStageInfo().badgeSupported
    }
    
    /// 檢查當前 Stage 是否使用 Combine
    /// - Returns: true 如果使用 Combine
    func usesCombineFramework() -> Bool {
        return currentDataService is Stage7_CombineDataService
    }
    
    /// 獲取當前 Stage 的同步能力
    /// - Returns: 同步能力類型
    func getSyncCapability() -> SyncCapability {
        return getCurrentStageInfo().syncCapability
    }
    
    // MARK: - 除錯和開發輔助
    
    /// 印出當前容器配置資訊
    func printContainerInfo() {
        let stage = getCurrentStageInfo()
        let vmType = usesCombineFramework() ? "Combine" : "UIKit"
        
        print("""
        
        🏗️ ServiceContainer 配置資訊:
        =====================================
        當前 Stage: \(stage.fullDescription)
        🔧 DataService: \(type(of: currentDataService))
        ViewModel 類型: \(vmType)
        \(stage.badgeDescription)
        同步能力: \(stage.syncCapability.rawValue) \(stage.syncCapability.emoji)
        =====================================
        
        切換方式：
        只需修改 currentDataService 即可切換整個架構！
        
        """)
    }
    
    /// 檢查容器配置是否正確
    /// - Returns: true 如果配置正確
    func validateConfiguration() -> Bool {
        let stage = getCurrentStageInfo()
        let dataServiceType = type(of: currentDataService)
        
        // 檢查 DataService 類型是否與 Stage 配置一致
        switch stage {
        case .stage1:
            return dataServiceType == Stage1_PropertyDataService.self
        case .stage2:
            return dataServiceType == Stage2_DelegateDataService.self
        case .stage3:
            return dataServiceType == Stage3_ClosureDataService.self
        case .stage4:
            return dataServiceType == Stage4_NotificationDataService.self
        case .stage5:
            return dataServiceType == Stage5_SingletonDataService.self
        case .stage6:
            return dataServiceType == Stage6_UserDefaultsDataService.self
        case .stage7:
            return dataServiceType == Stage7_CombineDataService.self
        case .stage8:
            // Stage8 暫未實作
            return false
        case .unknown:
            return false
        }
    }
    
    /// 列出所有可用的 Stage 配置
    /// - Returns: 所有 Stage 的描述列表
    func listAvailableStages() -> [String] {
        return StageConfigurationManager.shared.getAllStagesInfo()
    }
    
    // MARK: - 未來擴展預留
    
    /// 預留：創建其他類型的 ViewModel
    /// 當專案擴展時可以在這裡新增更多 ViewModel 工廠方法
    
    /*
    // 未來可能的擴展：
    
    func createSettingsViewModel() -> SettingsViewModelProtocol {
        if usesCombineFramework() {
            return SettingsViewModel_Combine(dataService: currentDataService)
        } else {
            return SettingsViewModel_UIKit(dataService: currentDataService)
        }
    }
    
    func createProfileViewModel() -> ProfileViewModelProtocol {
        // ... 類似的工廠邏輯
    }
    */
}

// MARK: - ServiceContainer 設計說明
/*
設計原則與特點：

1. **一行切換保持**：
   - 只需修改 currentDataService 就能切換整個架構
   - 自動選擇對應的 ViewModel 實作
   - 保持原有的簡潔性

2. **智能工廠模式**：
   - 根據 DataService 類型自動選擇 ViewModel
   - Stage 7+ 自動使用 Combine 版本
   - Stage 1-6 自動使用 UIKit 版本

3. **統一創建點**：
   - 所有 ViewModel 都透過 ServiceContainer 創建
   - 確保依賴注入的一致性
   - 便於統一管理和配置

4. **開發輔助工具**：
   - 配置驗證功能
   - 除錯資訊輸出
   - Stage 資訊查詢

5. **向後兼容**：
   - 保持原有的 getDataService() 方法
   - 不影響現有的 DataService 邏輯
   - 漸進式升級路徑

6. **擴展性考量**：
   - 為未來新增的 ViewModel 預留空間
   - 易於新增新的 Stage 支援
   - 模組化的架構設計

🔧 使用方式：

```swift
// 在 ViewController 中：
let viewModel = ServiceContainer.shared.createTodoListViewModel()

// 在需要檢查 Stage 資訊時：
if ServiceContainer.shared.isBadgeSupported() {
    // 處理 Badge 相關邏輯
}
```

⚡ 效能考量：
- ServiceContainer 是單例，避免重複創建
- ViewModel 創建時才進行類型判斷
- 最小化執行時的效能開銷

🎓 學習價值：
- 展示工廠模式的實際應用
- 理解依賴注入的進階技巧
- 體驗架構設計的彈性和擴展性
*/

