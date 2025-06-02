//
//  AddTodoViewController.swift
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/2.
//
import UIKit

// MARK: - AddTodo ViewController
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
        
        // 說明文字
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.text = """
        🎯 Stage1: Property直接傳遞
        
        特點：
        • 簡單直接的資料傳遞方式
        • 新增後需要手動切換到Todo清單才能看到結果
        • 無法即時同步到其他頁面
        
        限制：
        • Tab間無法自動同步資料
        • 需要手動刷新UI來更新顯示
        """
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
            title: "Stage1",
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
        
        // 🎯 Stage1限制：顯示提示訊息，因為無法自動同步到Tab1
        showAddSuccessAlert()
    }
    
    private func showAddSuccessAlert() {
        let alert = UIAlertController(
            title: "✅ 新增成功",
            message: "Stage1限制：請手動切換到「Todo清單」頁面查看新增的項目",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "知道了", style: .default))
        alert.addAction(UIAlertAction(title: "切換到Todo清單", style: .default) { [weak self] _ in
            self?.tabBarController?.selectedIndex = 0
        })
        
        present(alert, animated: true)
    }
}
