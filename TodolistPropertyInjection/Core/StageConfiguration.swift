//  StageConfiguration.swift
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/3.

// MARK: - Stage配置管理系統
import Foundation

// MARK: - Stage枚舉定義
enum TodoDataStage: String, CaseIterable {
    case stage1 = "Stage1"
    case stage2 = "Stage2"
    case stage3 = "Stage3"
    case stage4 = "Stage4"
    case stage5 = "Stage5"
    case stage6 = "Stage6"
    case stage7 = "Stage7"
    case stage8 = "Stage8"
    case unknown = "Unknown"
    
    // MARK: - Stage資訊配置
    var displayName: String {
        return self.rawValue
    }
    
    var title: String {
        switch self {
        case .stage1: return "Property直接傳遞"
        case .stage2: return "Delegate委託模式"
        case .stage3: return "Closure回調機制"
        case .stage4: return "NotificationCenter通知"
        case .stage5: return "Singleton全域狀態"
        case .stage6: return "UserDefaults持久化"
        case .stage7: return "Combine響應式框架"
        case .stage8: return "Core Data + MVVM"
        case .unknown: return "未知階段"
        }
    }
    
    var complexity: String {
        switch self {
        case .stage1: return "⭐"
        case .stage2: return "⭐⭐"
        case .stage3: return "⭐⭐"
        case .stage4: return "⭐⭐⭐"
        case .stage5: return "⭐⭐⭐"
        case .stage6: return "⭐⭐"
        case .stage7: return "⭐⭐⭐⭐"
        case .stage8: return "⭐⭐⭐⭐⭐"
        case .unknown: return "❓"
        }
    }
    
    var badgeSupported: Bool {
        switch self {
        case .stage1, .stage2, .stage3: return false
        case .stage4, .stage5, .stage6, .stage7, .stage8: return true
        case .unknown: return false
        }
    }
    
    var syncCapability: SyncCapability {
        switch self {
        case .stage1, .stage2, .stage3: return .manual
        case .stage4, .stage5, .stage6: return .automatic
        case .stage7, .stage8: return .reactive
        case .unknown: return .none
        }
    }
}

// MARK: - 同步能力枚舉
enum SyncCapability: String {
    case none = "無同步"
    case manual = "手動同步"
    case automatic = "自動同步"
    case reactive = "響應式同步"
    
    var emoji: String {
        switch self {
        case .none: return "❌"
        case .manual: return "🔄"
        case .automatic: return "✅"
        case .reactive: return "🚀"
        }
    }
}

// MARK: - Stage配置管理器
class StageConfigurationManager {
    static let shared = StageConfigurationManager()
    private init() {}
    
    // MARK: - 當前Stage檢測
    func getCurrentStage() -> TodoDataStage {
        let dataService = ServiceContainer.shared.getDataService()
        
        switch type(of: dataService) {
        case is Stage1_PropertyDataService.Type:
            return .stage1
        case is Stage2_DelegateDataService.Type:
            return .stage2
        case is Stage3_ClosureDataService.Type:
            return .stage3
        case is Stage4_NotificationDataService.Type:
            return .stage4
        case is Stage5_SingletonDataService.Type:
            return .stage5
        case is Stage6_UserDefaultsDataService.Type:
            return .stage6
        case is Stage7_CombineDataService.Type:
            return .stage7
        // case is Stage8_CoreDataService.Type:
        //     return .stage8
        default:
            return .unknown
        }
    }
    
    // MARK: - Stage說明文字配置
    func getStageInstruction(for stage: TodoDataStage) -> String {
        return StageInstructionProvider.getInstruction(for: stage)
    }
    
    // MARK: - Stage特性檢查
    func isBadgeSupported(for stage: TodoDataStage = StageConfigurationManager.shared.getCurrentStage()) -> Bool {
        return stage.badgeSupported
    }
    
    func getSyncCapability(for stage: TodoDataStage = StageConfigurationManager.shared.getCurrentStage()) -> SyncCapability {
        return stage.syncCapability
    }
}

// MARK: - Stage說明文字提供者
struct StageInstructionProvider {
    static func getInstruction(for stage: TodoDataStage) -> String {
        switch stage {
        case .stage1:
            return StageInstructions.stage1
        case .stage2:
            return StageInstructions.stage2
        case .stage3:
            return StageInstructions.stage3
        case .stage4:
            return StageInstructions.stage4
        case .stage5:
            return StageInstructions.stage5
        case .stage6:
            return StageInstructions.stage6
        case .stage7:
            return StageInstructions.stage7
        case .stage8:
            return StageInstructions.stage8
        case .unknown:
            return StageInstructions.unknown
        }
    }
}

// MARK: - Stage說明文字常量 (安全的全域資料)
private struct StageInstructions {
    static let stage1 = """
    🎯 Stage1: Property直接傳遞
    
    特點：
    • 簡單直接的資料傳遞方式
    • 新增後需要手動切換到Todo清單才能看到結果
    • 無法即時同步到其他頁面
    • Badge不會自動更新
    
    體驗重點：
    • 感受手動同步的不便
    • 觀察Badge始終為0的限制
    """
    
    static let stage2 = """
    🎯 Stage2: Delegate委託模式
    
    特點：
    • 展示一對一委託關係概念
    • 仍無法實現真正的UI自動更新
    • Badge依然不會自動更新
    
    體驗重點：
    • 理解委託模式的基本概念
    • 感受純DataService層通訊的限制
    """
    
    static let stage3 = """
    🎯 Stage3: Closure回調機制
    
    特點：
    • 展示回調函數的使用方式
    • 學習記憶體管理重要性
    • Badge仍無法自動更新
    
    體驗重點：
    • 理解Closure的語法和概念
    • 觀察weak self的安全性
    """
    
    static let stage4 = """
    🎯 Stage4: NotificationCenter通知
    
    特點：
    • 第一個實現真正UI自動更新的階段
    • 跨層級通訊能力
    • Badge開始有反應！
    
    體驗重點：
    • 感受自動同步的驚喜
    • 觀察Badge的即時更新
    """
    
    static let stage5 = """
    🎯 Stage5: Singleton全域狀態
    
    特點：
    • 全域唯一實例管理
    • 狀態在App生命週期內持續存在
    • Badge自動更新
    
    體驗重點：
    • 理解全域狀態管理
    • 觀察持久的記憶體狀態
    """
    
    static let stage6 = """
    🎯 Stage6: UserDefaults持久化
    
    特點：
    • App重啟後資料仍然存在
    • 記憶體快取 + 持久化存儲
    • Badge自動更新
    
    體驗重點：
    • 感受真正的資料持久化
    • 重啟App後資料不丟失
    """
    
    static let stage7 = """
    🎯 Stage7: Combine響應式框架
    
    特點：
    • 現代化響應式程式設計
    • 聲明式資料流管理
    • 完美的自動記憶體管理
    • 最流暢的Badge響應式更新
    
    體驗重點：
    • 感受響應式的優雅和流暢
    • 觀察即時的Badge動畫效果
    • 體驗現代iOS開發的威力
    """
    
    static let stage8 = """
    🎯 Stage8: Core Data + MVVM
    
    特點：
    • 企業級資料管理解決方案
    • 複雜關聯資料處理
    • 高效能資料查詢和快取
    • 完整的CRUD操作支援
    
    體驗重點：
    • 感受企業級架構的複雜性
    • 理解資料持久化的最佳實踐
    • 體驗專業iOS開發的完整流程
    """
    
    static let unknown = """
    🎯 Unknown Stage
    
    請確認ServiceContainer中的DataService設定
    或檢查是否有新的Stage尚未配置。
    """
}

// MARK: - 便利擴展
extension TodoDataStage {
    var fullDescription: String {
        return "🎯 \(displayName): \(title) \(complexity)"
    }
    
    var badgeDescription: String {
        if badgeSupported {
            return "\(syncCapability.emoji) Badge支援: ✅"
        } else {
            return "🔴 Badge支援: ❌"
        }
    }
}

// MARK: - Debug和開發輔助
extension StageConfigurationManager {
    func printCurrentStageInfo() {
        let stage = getCurrentStage()
        print("""
        📋 當前Stage資訊:
        ==================
        \(stage.fullDescription)
        \(stage.badgeDescription)
        同步能力: \(stage.syncCapability.rawValue) \(stage.syncCapability.emoji)
        ==================
        """)
    }
    
    func getAllStagesInfo() -> [String] {
        return TodoDataStage.allCases.compactMap { stage in
            guard stage != .unknown else { return nil }
            return "\(stage.displayName): \(stage.title) \(stage.complexity)"
        }
    }
}
