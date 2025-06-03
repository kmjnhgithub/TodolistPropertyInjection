//
//  AddTodoViewController.swift
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/2.
//
import UIKit

// MARK: - AddTodo ViewController (移除Alert版)
class AddTodoViewController: UIViewController {
    private var viewModel: AddTodoViewModel!
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let textField = UITextField()
    private let addButton = UIButton(type: .system)
    private let instructionLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupUI()
    }
    
    private func setupViewModel() {
        viewModel = AddTodoViewModel()
    }
    
    private func setupUI() {
        title = "新增Todo"
        view.backgroundColor = .systemBackground
        
        setupScrollView()
        setupContentView()
        setupNavigationBar()
        
        // 鍵盤處理
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
        
        // 說明文字 - 動態顯示當前Stage資訊
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.text = getCurrentStageInstruction()
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: getCurrentStageName(),
            style: .plain,
            target: nil,
            action: nil
        )
        navigationItem.rightBarButtonItem?.tintColor = .systemGreen
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
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
        guard let title = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !title.isEmpty else {
            return
        }
        
        viewModel.addTodo(title: title)
        
        // 清空輸入框
        textField.text = ""
        textFieldDidChange()
        textField.resignFirstResponder()
        
        // 🎯 新設計：移除Alert，讓用戶純粹體驗各階段差異
        // Stage1-3: 用戶會發現沒有即時反饋
        // Stage4+: 用戶會驚喜發現Badge立即更新
        // Stage7: 用戶會體驗到完全流暢的響應式更新
        
        print("✅ Todo新增完成，體驗不同Stage的同步效果")
    }
    
    // MARK: - 動態Stage資訊
    
    private func getCurrentStageName() -> String {
        let dataService = ServiceContainer.shared.getDataService()
        
        if dataService is Stage1_PropertyDataService {
            return "Stage1"
        } else if dataService is Stage2_DelegateDataService {
            return "Stage2"
        } else if dataService is Stage3_ClosureDataService {
            return "Stage3"
        } else if dataService is Stage4_NotificationDataService {
            return "Stage4"
        } else if dataService is Stage5_SingletonDataService {
            return "Stage5"
        } else if dataService is Stage6_UserDefaultsDataService {
            return "Stage6"
        } else if dataService is Stage7_CombineDataService {
            return "Stage7"
        } else {
            return "Unknown"
        }
    }
    
    private func getCurrentStageInstruction() -> String {
        let dataService = ServiceContainer.shared.getDataService()
        
        if dataService is Stage1_PropertyDataService {
            return """
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
        } else if dataService is Stage2_DelegateDataService {
            return """
            🎯 Stage2: Delegate委託模式
            
            特點：
            • 展示一對一委託關係概念
            • 仍無法實現真正的UI自動更新
            • Badge依然不會自動更新
            
            體驗重點：
            • 理解委託模式的基本概念
            • 感受純DataService層通訊的限制
            """
        } else if dataService is Stage3_ClosureDataService {
            return """
            🎯 Stage3: Closure回調機制
            
            特點：
            • 展示回調函數的使用方式
            • 學習記憶體管理重要性
            • Badge仍無法自動更新
            
            體驗重點：
            • 理解Closure的語法和概念
            • 觀察weak self的安全性
            """
        } else if dataService is Stage4_NotificationDataService {
            return """
            🎯 Stage4: NotificationCenter通知
            
            特點：
            • 第一個實現真正UI自動更新的階段
            • 跨層級通訊能力
            • Badge開始有反應！
            
            體驗重點：
            • 感受自動同步的驚喜
            • 觀察Badge的即時更新
            """
        } else if dataService is Stage5_SingletonDataService {
            return """
            🎯 Stage5: Singleton全域狀態
            
            特點：
            • 全域唯一實例管理
            • 狀態在App生命週期內持續存在
            • Badge自動更新
            
            體驗重點：
            • 理解全域狀態管理
            • 觀察持久的記憶體狀態
            """
        } else if dataService is Stage6_UserDefaultsDataService {
            return """
            🎯 Stage6: UserDefaults持久化
            
            特點：
            • App重啟後資料仍然存在
            • 記憶體快取 + 持久化存儲
            • Badge自動更新
            
            體驗重點：
            • 感受真正的資料持久化
            • 重啟App後資料不丟失
            """
        } else if dataService is Stage7_CombineDataService {
            return """
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
        } else {
            return """
            🎯 Unknown Stage
            
            請確認ServiceContainer中的DataService設定
            """
        }
    }
}
