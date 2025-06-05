//
//  AddTodoViewController.swift (重構版)
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/2.
//
import UIKit

// MARK: - AddTodo ViewController (ServiceContainer版)
// 🎯 使用 ServiceContainer 統一創建 ViewModel
// 根據不同 Stage 提供對應的用戶體驗

class AddTodoViewController: UIViewController {
    private var viewModel: AddTodoViewModel!
    
    // MARK: - UI元件
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let textField = UITextField()
    private let addButton = UIButton(type: .system)
    private let instructionLabel = UILabel()
    
    // MARK: - Stage配置管理
    private let stageManager = StageConfigurationManager.shared
    private var currentStage: TodoDataStage {
        return stageManager.getCurrentStage()
    }
    
    // MARK: - 生命週期
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔍 AddTodoViewController: viewDidLoad 開始")
        setupViewModel()
        setupUI()
        
        // 🔍 Debug: 印出當前Stage資訊
        stageManager.printCurrentStageInfo()
        print("🔍 AddTodoViewController: viewDidLoad 完成")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("🔍 AddTodoViewController: viewWillAppear 開始")
        
        // 每次出現時更新Stage相關UI (以防ServiceContainer被更改)
        updateStageRelatedUI()
        
        print("🔍 AddTodoViewController: viewWillAppear 完成")
    }
    
    // MARK: - 設置方法
    
    private func setupViewModel() {
        print("🔍 開始設置AddTodoViewModel（透過ServiceContainer）")
        
        // 🎯 關鍵改變：透過 ServiceContainer 創建 ViewModel
        viewModel = ServiceContainer.shared.createAddTodoViewModel()
        
        print("✅ AddTodoViewModel創建完成：\(type(of: viewModel))")
        
        // 🔍 印出容器配置資訊
        if ServiceContainer.shared.usesCombineFramework() {
            print("🚀 當前使用 Combine 架構")
        } else {
            print("🔧 當前使用 UIKit 架構")
        }
    }
    
    private func setupUI() {
        title = "新增Todo"
        view.backgroundColor = .systemBackground
        
        setupScrollView()
        setupContentView()
        setupNavigationBar()
        setupKeyboardObservers()
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
        // 標題
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "新增一個Todo項目"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        
        // 輸入框
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "輸入Todo內容..."
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 16)
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        contentView.addSubview(textField)
        
        // 新增按鈕
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setTitle("📝 新增Todo", for: .normal)
        addButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        addButton.backgroundColor = .systemBlue
        addButton.setTitleColor(.white, for: .normal)
        addButton.layer.cornerRadius = 8
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        addButton.isEnabled = false
        addButton.alpha = 0.5
        contentView.addSubview(addButton)
        
        // 說明文字 - 使用配置管理器
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.text = stageManager.getStageInstruction(for: currentStage)
        instructionLabel.font = .systemFont(ofSize: 14)
        instructionLabel.textColor = .systemGray
        instructionLabel.numberOfLines = 0
        instructionLabel.textAlignment = .left
        contentView.addSubview(instructionLabel)
        
        // 設定約束
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            textField.heightAnchor.constraint(equalToConstant: 44),
            
            addButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            addButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 50),
            
            instructionLabel.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 40),
            instructionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            instructionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func setupNavigationBar() {
        updateNavigationBar()
    }
    
    private func updateNavigationBar() {
        // 🎯 使用 ServiceContainer 的工具方法獲取完整資訊
        let stage = ServiceContainer.shared.getCurrentStageInfo()
        let usesCombine = ServiceContainer.shared.usesCombineFramework()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "\(stage.displayName)\(usesCombine ? " 🚀" : "")",
            style: .plain,
            target: self,
            action: #selector(stageInfoTapped)
        )
        
        // 根據Stage設置不同顏色
        let color: UIColor = {
            if usesCombine {
                return .systemPurple  // Combine 架構用紫色
            } else {
                return stage.badgeSupported ? .systemGreen : .systemOrange
            }
        }()
        navigationItem.rightBarButtonItem?.tintColor = color
    }
    
    private func updateStageRelatedUI() {
        print("🔄 更新Stage相關UI")
        
        // 更新說明文字
        instructionLabel.text = stageManager.getStageInstruction(for: currentStage)
        
        // 更新導航欄
        updateNavigationBar()
        
        // 更新按鈕樣式 (根據架構類型和Stage特性)
        updateButtonStyle()
        
        print("✅ Stage相關UI更新完成")
    }
    
    private func updateButtonStyle() {
        let usesCombine = ServiceContainer.shared.usesCombineFramework()
        let syncCapability = ServiceContainer.shared.getSyncCapability()
        
        if usesCombine {
            // Combine 架構：響應式風格
            addButton.backgroundColor = .systemPurple
            addButton.setTitle("🚀 響應式新增", for: .normal)
            print("🎨 設置響應式按鈕樣式")
        } else {
            switch syncCapability {
            case .automatic:
                // Stage4-6: 自動同步風格
                addButton.backgroundColor = .systemGreen
                addButton.setTitle("✅ 自動新增", for: .normal)
                print("🎨 設置自動同步按鈕樣式")
            case .manual:
                // Stage1-3: 基礎風格
                addButton.backgroundColor = .systemBlue
                addButton.setTitle("📝 新增Todo", for: .normal)
                print("🎨 設置手動同步按鈕樣式")
            default:
                // 預設風格
                addButton.backgroundColor = .systemBlue
                addButton.setTitle("📝 新增Todo", for: .normal)
                print("🎨 設置預設按鈕樣式")
            }
        }
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    // MARK: - 事件處理
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    @objc private func textFieldDidChange() {
        let hasText = !(textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        addButton.isEnabled = hasText
        addButton.alpha = hasText ? 1.0 : 0.5
    }
    
    @objc private func addButtonTapped() {
        print("🔍 addButtonTapped 被調用！") 
        guard let title = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !title.isEmpty else {
            print("⚠️ 嘗試新增空白Todo，已忽略")
            return
        }
        
        print("📝 準備新增Todo: \(title)")
        
        // 🎯 新增前的Stage特定處理
        handlePreAddAction(for: currentStage, todoTitle: title)
        
        // 🎯 透過 ViewModel 新增 Todo
        viewModel.addTodo(title: title)
        
        // 清空輸入框
        textField.text = ""
        textFieldDidChange()
        textField.resignFirstResponder()
        
        // 🎯 新增後的Stage特定處理
        handlePostAddAction(for: currentStage, todoTitle: title)
        
        print("✅ Todo新增完成，體驗\(currentStage.displayName)的同步效果")
    }
    
    @objc private func stageInfoTapped() {
        // 🎯 顯示當前Stage的詳細資訊
        showStageInfoAlert()
    }
    
    // MARK: - Stage特定行為處理
    
    private func handlePreAddAction(for stage: TodoDataStage, todoTitle: String) {
        let usesCombine = ServiceContainer.shared.usesCombineFramework()
        
        if usesCombine {
            print("🚀 \(stage.displayName): 準備響應式新增 - \(todoTitle)")
        } else {
            switch stage.syncCapability {
            case .automatic:
                print("✅ \(stage.displayName): 準備自動同步新增 - \(todoTitle)")
            case .manual:
                print("🔄 \(stage.displayName): 準備手動同步新增 - \(todoTitle)")
            case .reactive:
                print("🚀 \(stage.displayName): 準備響應式新增 - \(todoTitle)")
            case .none:
                print("❌ \(stage.displayName): 無同步能力新增 - \(todoTitle)")
            }
        }
    }
    
    private func handlePostAddAction(for stage: TodoDataStage, todoTitle: String) {
        let badgeStatus = stage.badgeSupported ? "Badge將更新" : "Badge不會更新"
        let usesCombine = ServiceContainer.shared.usesCombineFramework()
        let architecture = usesCombine ? "Combine" : "UIKit"
        
        print("📝 \(stage.displayName) (\(architecture)): 新增「\(todoTitle)」完成，\(badgeStatus)")
        
        // 🎯 根據Stage特性給出不同的視覺反饋
        let feedbackMessage = generateFeedbackMessage(for: stage, usesCombine: usesCombine)
        
        if !stage.badgeSupported {
            // Stage1-3: 給出提示
            showTemporaryFeedback(feedbackMessage)
        } else {
            // Stage4+: 簡短確認
            showTemporaryFeedback("✅ 新增成功！\(usesCombine ? "響應式" : "自動")同步中...")
        }
    }
    
    private func generateFeedbackMessage(for stage: TodoDataStage, usesCombine: Bool) -> String {
        if usesCombine {
            return "🚀 新增成功！響應式同步到Todo清單，Badge即時更新"
        } else {
            switch stage.syncCapability {
            case .automatic:
                return "✅ 新增成功！自動同步到Todo清單，Badge即時更新"
            case .manual:
                return "📝 新增完成，請手動切換到Todo清單查看，Badge不會更新"
            case .reactive:
                return "🚀 新增成功！響應式同步中..."
            case .none:
                return "📝 新增完成，請手動檢查Todo清單"
            }
        }
    }
    
    private func showTemporaryFeedback(_ message: String) {
        print("💬 顯示回饋訊息: \(message)")
        
        // 簡單的臨時反饋 (替代Alert的輕量級方案)
        let feedbackView = createFeedbackView(message: message)
        view.addSubview(feedbackView)
        
        // 將 feedbackView 加入 view 後再設置約束
        NSLayoutConstraint.activate([
            feedbackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            feedbackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            feedbackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            feedbackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
        
        
        // 動畫顯示和隱藏
        UIView.animate(withDuration: 0.3, animations: {
            feedbackView.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 2.5, options: [], animations: {
                feedbackView.alpha = 0.0
            }) { _ in
                feedbackView.removeFromSuperview()
            }
        }
    }
    
    private func createFeedbackView(message: String) -> UIView {
        let feedbackView = UIView()
        feedbackView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        feedbackView.layer.cornerRadius = 8
        feedbackView.alpha = 0.0
        
        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        feedbackView.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: feedbackView.topAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: feedbackView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: feedbackView.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: feedbackView.bottomAnchor, constant: -12)
        ])
        
        feedbackView.translatesAutoresizingMaskIntoConstraints = false
        return feedbackView
    }
    
    private func showStageInfoAlert() {
        let stage = currentStage
        let usesCombine = ServiceContainer.shared.usesCombineFramework()
        let architecture = usesCombine ? "Combine" : "UIKit"
        
        let alert = UIAlertController(
            title: "➕ 新增Todo頁面",
            message: """
            🎯 當前Stage: \(stage.fullDescription)
            🎨 架構類型: \(architecture) \(usesCombine ? "🚀" : "🔧")
            \(stage.badgeDescription)
            🔄 同步能力: \(stage.syncCapability.rawValue) \(stage.syncCapability.emoji)
            
            在此頁面新增Todo後：
            \(generateStageExplanation(for: stage, usesCombine: usesCombine))
            """,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "知道了", style: .default))
        alert.addAction(UIAlertAction(title: "查看說明", style: .default) { _ in
            self.showDetailedStageInfo()
        })
        alert.addAction(UIAlertAction(title: "容器資訊", style: .default) { _ in
            ServiceContainer.shared.printContainerInfo()
        })
        
        present(alert, animated: true)
    }
    
    private func generateStageExplanation(for stage: TodoDataStage, usesCombine: Bool) -> String {
        if usesCombine {
            return "• 響應式即時同步到Todo清單\n• Badge立即更新\n• 無需手動刷新"
        } else {
            switch stage.syncCapability {
            case .automatic:
                return "• 自動同步到Todo清單\n• Badge自動更新\n• 無需手動操作"
            case .manual:
                return "• 需要手動切換Tab查看\n• Badge不會更新\n• 體驗手動同步限制"
            case .reactive:
                return "• 響應式同步\n• Badge即時更新"
            case .none:
                return "• 無自動同步功能\n• 需要手動檢查"
            }
        }
    }
    
    private func showDetailedStageInfo() {
        let stage = currentStage
        let detailVC = UIViewController()
        detailVC.title = stage.fullDescription
        
        let textView = UITextView()
        textView.text = stageManager.getStageInstruction(for: stage)
        textView.font = .systemFont(ofSize: 16)
        textView.isEditable = false
        textView.backgroundColor = .systemBackground
        
        detailVC.view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: detailVC.view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: detailVC.view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: detailVC.view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: detailVC.view.bottomAnchor)
        ])
        
        detailVC.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissDetailInfo)
        )
        
        let navController = UINavigationController(rootViewController: detailVC)
        present(navController, animated: true)
    }
    
    @objc private func dismissDetailInfo() {
        dismiss(animated: true)
    }
    
    // MARK: - 清理
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("🧹 AddTodoViewController: 清理完成")
    }
}

// MARK: - AddTodoViewController 重構說明
/*
🎯 重構重點：

1. **統一創建方式**：
   - 透過 ServiceContainer.createAddTodoViewModel() 創建
   - 確保與整體架構的一致性
   - 自動使用正確的 DataService

2. **智能UI適配**：
   - 根據 Stage 和架構類型調整按鈕樣式
   - Combine 架構顯示響應式特色
   - 按 Stage 同步能力提供不同的視覺回饋

3. **增強的用戶體驗**：
   - 詳細的新增操作回饋
   - 根據 Stage 特性給出對應的提示
   - 清晰的架構類型展示

4. **完整的學習支援**：
   - Stage 資訊彈窗詳細說明後續行為
   - 容器配置資訊一鍵查看
   - 豐富的日誌輸出便於理解

5. **架構整合**：
   - 與 TodoListViewController 保持一致的風格
   - 使用 ServiceContainer 的所有工具方法
   - 支援 UIKit 和 Combine 兩種架構

✅ 重構效果：
- UI 智能適配不同 Stage 和架構
- 提供更豐富的用戶回饋
- 保持完整的學習體驗
- 與整體架構完美整合

🎓 學習價值：
- 體驗不同 Stage 的新增行為差異
- 理解 Badge 更新機制的變化
- 感受 UIKit vs Combine 的不同特色
- 掌握架構切換的無縫體驗

⚡ 特色功能：
- 智能按鈕樣式 (響應式/自動/手動)
- 階段感知的回饋訊息
- 完整的 Stage 說明展示
- 容器配置即時查看

🎨 視覺設計：
- Stage 1-3: 藍色按鈕，手動同步提示
- Stage 4-6: 綠色按鈕，自動同步確認
- Stage 7+: 紫色按鈕，響應式特色
- 導航欄顏色根據 Stage 特性調整
*/
