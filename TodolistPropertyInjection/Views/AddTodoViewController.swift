//
//  AddTodoViewController.swift (重構版)
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/2.
//
import UIKit

// MARK: - AddTodo ViewController (重構版)
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
        setupViewModel()
        setupUI()
        
        // 🔍 Debug: 印出當前Stage資訊
        stageManager.printCurrentStageInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 每次出現時更新Stage相關UI (以防ServiceContainer被更改)
        updateStageRelatedUI()
    }
    
    // MARK: - 設置方法
    private func setupViewModel() {
        viewModel = AddTodoViewModel()
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
        // 🎯 使用enum安全地設置導航標題
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: currentStage.displayName,
            style: .plain,
            target: self,
            action: #selector(stageInfoTapped)
        )
        
        // 根據Stage設置不同顏色
        let color: UIColor = currentStage.badgeSupported ? .systemGreen : .systemOrange
        navigationItem.rightBarButtonItem?.tintColor = color
    }
    
    private func updateStageRelatedUI() {
        // 更新說明文字
        instructionLabel.text = stageManager.getStageInstruction(for: currentStage)
        
        // 更新導航欄
        updateNavigationBar()
        
        // 更新按鈕樣式 (響應式Stage可以有不同的視覺效果)
        updateButtonStyle()
    }
    
    private func updateButtonStyle() {
        switch currentStage.syncCapability {
        case .reactive:
            // Stage7: 響應式風格
            addButton.backgroundColor = .systemPurple
            addButton.setTitle("🚀 響應式新增", for: .normal)
        case .automatic:
            // Stage4-6: 自動同步風格
            addButton.backgroundColor = .systemGreen
            addButton.setTitle("✅ 自動新增", for: .normal)
        default:
            // Stage1-3: 基礎風格
            addButton.backgroundColor = .systemBlue
            addButton.setTitle("📝 新增Todo", for: .normal)
        }
    }
    
    private func setupKeyboardObservers() {
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
        guard let title = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !title.isEmpty else {
            return
        }
        
        // 🎯 新增前的Stage特定處理
        handlePreAddAction(for: currentStage)
        
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
    private func handlePreAddAction(for stage: TodoDataStage) {
        switch stage.syncCapability {
        case .reactive:
            print("🚀 \(stage.displayName): 準備響應式新增")
        case .automatic:
            print("✅ \(stage.displayName): 準備自動同步新增")
        case .manual:
            print("🔄 \(stage.displayName): 準備手動同步新增")
        case .none:
            print("❌ \(stage.displayName): 無同步能力")
        }
    }
    
    private func handlePostAddAction(for stage: TodoDataStage, todoTitle: String) {
        let badgeStatus = stage.badgeSupported ? "Badge將更新" : "Badge不會更新"
        print("📝 \(stage.displayName): 新增「\(todoTitle)」完成，\(badgeStatus)")
        
        // 🎯 根據Stage特性給出不同的視覺反饋
        if !stage.badgeSupported {
            // Stage1-3: 給出提示
            showTemporaryFeedback("新增完成，請手動切換到Todo清單查看")
        }
    }
    
    private func showTemporaryFeedback(_ message: String) {
        // 簡單的臨時反饋 (替代Alert的輕量級方案)
        let feedbackView = createFeedbackView(message: message)
        view.addSubview(feedbackView)
        
        // 動畫顯示和隱藏
        UIView.animate(withDuration: 0.3, animations: {
            feedbackView.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 2.0, options: [], animations: {
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
        
        feedbackView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: feedbackView.topAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: feedbackView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: feedbackView.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: feedbackView.bottomAnchor, constant: -12)
        ])
        
        feedbackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            feedbackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            feedbackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60)
        ])
        
        return feedbackView
    }
    
    private func showStageInfoAlert() {
        let stage = currentStage
        let alert = UIAlertController(
            title: stage.fullDescription,
            message: """
            \(stage.badgeDescription)
            同步能力: \(stage.syncCapability.rawValue) \(stage.syncCapability.emoji)
            
            點擊「查看說明」了解更多詳情
            """,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "知道了", style: .default))
        alert.addAction(UIAlertAction(title: "查看說明", style: .default) { _ in
            self.showDetailedStageInfo()
        })
        
        present(alert, animated: true)
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
    }
}
