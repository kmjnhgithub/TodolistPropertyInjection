//
//  TodoDetailViewController.swift
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/2.
//

//
//  TodoDetailViewController.swift (重構版)
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/2.
//  Updated by AI Assistant on 2025/6/5.
//

import UIKit

// MARK: - TodoDetail ViewController (ServiceContainer版)
// 🎯 使用 ServiceContainer 統一創建 ViewModel
// 確保與整體架構的一致性

class TodoDetailViewController: UIViewController {
    var todoUUID: String!
    private var viewModel: TodoDetailViewModel!
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let statusLabel = UILabel()
    private let uuidLabel = UILabel()
    private let toggleButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)
    
    // MARK: - Stage配置管理
    private let stageManager = StageConfigurationManager.shared
    private var currentStage: TodoDataStage {
        return stageManager.getCurrentStage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔍 TodoDetailViewController: viewDidLoad 開始")
        setupViewModel()
        setupUI()
        updateUI()
        print("🔍 TodoDetailViewController: viewDidLoad 完成")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("🔍 TodoDetailViewController: viewWillAppear 開始")
        
        // 🎯 各Stage都需要手動刷新資料
        updateUI()
        print("🔄 \(currentStage.displayName): 手動刷新TodoDetail資料")
        
        print("🔍 TodoDetailViewController: viewWillAppear 完成")
    }
    
    // MARK: - 設置方法
    
    private func setupViewModel() {
        print("🔍 開始設置TodoDetailViewModel（透過ServiceContainer）")
        
        // 🎯 關鍵改變：透過 ServiceContainer 創建 ViewModel
        viewModel = ServiceContainer.shared.createTodoDetailViewModel(todoUUID: todoUUID)
        
        print("✅ TodoDetailViewModel創建完成：\(type(of: viewModel))")
        print("🔍 管理的Todo UUID: \(todoUUID ?? "nil")")
    }
    
    private func setupUI() {
        title = "Todo詳情"
        view.backgroundColor = .systemBackground
        
        setupScrollView()
        setupContentView()
        setupNavigationBar()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupContentView() {
        // 標題標籤
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        
        // 狀態標籤
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .systemFont(ofSize: 18, weight: .medium)
        statusLabel.textAlignment = .center
        contentView.addSubview(statusLabel)
        
        // UUID標籤
        uuidLabel.translatesAutoresizingMaskIntoConstraints = false
        uuidLabel.font = .systemFont(ofSize: 12, weight: .regular)
        uuidLabel.textColor = .systemGray
        uuidLabel.textAlignment = .center
        uuidLabel.numberOfLines = 0
        contentView.addSubview(uuidLabel)
        
        // 切換完成狀態按鈕
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        toggleButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        toggleButton.backgroundColor = .systemBlue
        toggleButton.setTitleColor(.white, for: .normal)
        toggleButton.layer.cornerRadius = 8
        toggleButton.addTarget(self, action: #selector(toggleButtonTapped), for: .touchUpInside)
        contentView.addSubview(toggleButton)
        
        // 刪除按鈕
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setTitle("🗑️ 刪除Todo", for: .normal)
        deleteButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        deleteButton.backgroundColor = .systemRed
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.layer.cornerRadius = 8
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        contentView.addSubview(deleteButton)
        
        // 設定約束
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            uuidLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            uuidLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            uuidLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            toggleButton.topAnchor.constraint(equalTo: uuidLabel.bottomAnchor, constant: 40),
            toggleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            toggleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            toggleButton.heightAnchor.constraint(equalToConstant: 50),
            
            deleteButton.topAnchor.constraint(equalTo: toggleButton.bottomAnchor, constant: 20),
            deleteButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            deleteButton.heightAnchor.constraint(equalToConstant: 50),
            deleteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func setupNavigationBar() {
        // 🎯 使用 ServiceContainer 的工具方法獲取 Stage 資訊
        let stage = ServiceContainer.shared.getCurrentStageInfo()
        let usesCombine = ServiceContainer.shared.usesCombineFramework()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "\(stage.displayName)\(usesCombine ? " 🚀" : "")",
            style: .plain,
            target: self,
            action: #selector(stageInfoTapped)
        )
        
        // 根據同步能力設置顏色
        let color: UIColor = {
            switch stage.syncCapability {
            case .reactive: return .systemPurple
            case .automatic: return .systemGreen
            case .manual: return .systemOrange
            case .none: return .systemGray
            }
        }()
        navigationItem.rightBarButtonItem?.tintColor = color
    }
    
    // MARK: - UI 更新
    
    private func updateUI() {
        print("🔍 TodoDetailViewController: 開始更新UI")
        
        guard let todo = viewModel.todo else {
            print("⚠️ Todo已被刪除，返回上一頁")
            // Todo已被刪除，返回上一頁
            navigationController?.popViewController(animated: true)
            return
        }
        
        titleLabel.text = todo.title
        statusLabel.text = todo.isCompleted ? "✅ 已完成" : "⏳ 待完成"
        statusLabel.textColor = todo.isCompleted ? .systemGreen : .systemOrange
        uuidLabel.text = "UUID: \(todo.uuid)"
        
        let toggleTitle = todo.isCompleted ? "標記為待完成" : "標記為已完成"
        toggleButton.setTitle(toggleTitle, for: .normal)
        toggleButton.backgroundColor = todo.isCompleted ? .systemOrange : .systemGreen
        
        print("✅ TodoDetailViewController: UI更新完成")
        print("📝 Todo資訊: \(todo.title) - \(todo.isCompleted ? "已完成" : "待完成")")
    }
    
    // MARK: - 事件處理
    
    @objc private func toggleButtonTapped() {
        print("🔄 切換Todo完成狀態")
        
        viewModel.toggleCompletion()
        
        // 🎯 各Stage都需要手動更新UI
        updateUI()
        print("🔄 \(currentStage.displayName): 手動更新完成狀態UI")
        
        // 🎯 提供視覺回饋
        provideFeedbackForToggle()
    }
    
    @objc private func deleteButtonTapped() {
        print("🗑️ 準備刪除Todo")
        
        let alert = UIAlertController(
            title: "確認刪除",
            message: "確定要刪除這個Todo嗎？",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel) { _ in
            print("❌ 用戶取消刪除")
        })
        
        alert.addAction(UIAlertAction(title: "刪除", style: .destructive) { [weak self] _ in
            self?.performDelete()
        })
        
        present(alert, animated: true)
    }
    
    @objc private func stageInfoTapped() {
        // 🎯 顯示當前Stage的詳細資訊
        showStageInfoAlert()
    }
    
    // MARK: - 輔助方法
    
    private func performDelete() {
        print("🗑️ 執行刪除操作")
        
        viewModel.deleteTodo()
        
        // 🎯 各Stage刪除後都需要手動返回
        navigationController?.popViewController(animated: true)
        print("🗑️ \(currentStage.displayName): 刪除後手動返回上一頁")
        
        // 🎯 提供視覺回饋
        provideFeedbackForDelete()
    }
    
    private func provideFeedbackForToggle() {
        // 🎯 根據Stage特性提供不同的回饋
        let message: String
        switch currentStage.syncCapability {
        case .reactive:
            message = "狀態已更新（響應式同步）"
        case .automatic:
            message = "狀態已更新（自動同步）"
        case .manual:
            message = "狀態已更新（需手動刷新清單）"
        case .none:
            message = "狀態已更新"
        }
        
        print("💬 切換回饋: \(message)")
        // 可以在這裡加入 Toast 或其他視覺回饋
    }
    
    private func provideFeedbackForDelete() {
        let message: String
        switch currentStage.syncCapability {
        case .reactive:
            message = "Todo已刪除（響應式同步到清單）"
        case .automatic:
            message = "Todo已刪除（自動同步到清單）"
        case .manual:
            message = "Todo已刪除（清單需手動刷新）"
        case .none:
            message = "Todo已刪除"
        }
        
        print("💬 刪除回饋: \(message)")
    }
    
    private func showStageInfoAlert() {
        let stage = currentStage
        let usesCombine = ServiceContainer.shared.usesCombineFramework()
        
        let alert = UIAlertController(
            title: "📝 Todo詳情頁面",
            message: """
            🎯 當前Stage: \(stage.fullDescription)
            🎨 架構: \(usesCombine ? "Combine" : "UIKit")
            🔄 同步能力: \(stage.syncCapability.rawValue) \(stage.syncCapability.emoji)
            
            在此頁面可以：
            • 檢視Todo詳細資訊
            • 切換完成狀態
            • 刪除Todo項目
            """,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "知道了", style: .default))
        
        present(alert, animated: true)
    }
    
    // MARK: - 清理
    deinit {
        print("🧹 TodoDetailViewController: 清理完成")
    }
}

// MARK: - TodoDetailViewController 重構說明
/*
🎯 重構重點：

1. **統一創建方式**：
   - 透過 ServiceContainer.createTodoDetailViewModel() 創建
   - 確保與整體架構的一致性
   - 自動使用正確的 DataService

2. **Stage 感知功能**：
   - 導航欄顯示當前 Stage 和架構類型
   - 根據同步能力提供不同的視覺回饋
   - Stage 資訊彈窗展示

3. **保持學習體驗**：
   - 各 Stage 的手動刷新特性保持不變
   - 切換和刪除操作的回饋符合 Stage 特性
   - 清晰的日誌輸出便於理解執行流程

4. **統一的架構整合**：
   - 使用 ServiceContainer 的工具方法
   - 與 TodoListViewController 保持一致的風格
   - 支援未來的架構擴展

5. **用戶體驗改善**：
   - 提供操作回饋訊息
   - 根據 Stage 特性調整 UI 顏色
   - 清晰的 Stage 資訊展示

✅ 重構效果：
- 與整體架構更好的整合
- 保持各 Stage 的學習特性
- 提供更好的用戶回饋
- 便於除錯和理解

🎓 學習價值：
- 理解 Detail 頁面在不同架構下的行為
- 體驗手動 vs 自動同步的差異
- 感受統一架構的好處
- 掌握 Stage 特性的正確展示方式

⚠️ 注意事項：
- TodoDetailViewModel 本身不需要分版本
- 主要差異在於 DataService 的行為
- UI 更新邏輯保持各 Stage 的一致性
- 記得在操作後提供適當的回饋
*/
