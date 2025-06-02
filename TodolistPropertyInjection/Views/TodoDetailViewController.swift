//
//  TodoDetailViewController.swift
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/2.
//

import UIKit

// MARK: - TodoDetail ViewController
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupUI()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 🎯 Stage1限制：需要手動刷新資料
        updateUI()
        print("🔄 Stage1: 手動刷新TodoDetail資料")
    }
    
    private func setupViewModel() {
        viewModel = TodoDetailViewModel(todoUUID: todoUUID)
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Stage1",
            style: .plain,
            target: nil,
            action: nil
        )
        navigationItem.rightBarButtonItem?.tintColor = .systemGreen
    }
    
    private func updateUI() {
        guard let todo = viewModel.todo else {
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
    }
    
    @objc private func toggleButtonTapped() {
        viewModel.toggleCompletion()
        // 🎯 Stage1限制：需要手動更新UI
        updateUI()
        print("🔄 Stage1: 手動更新完成狀態UI")
    }
    
    @objc private func deleteButtonTapped() {
        let alert = UIAlertController(
            title: "確認刪除",
            message: "確定要刪除這個Todo嗎？",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "刪除", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteTodo()
            // 🎯 Stage1限制：刪除後需要手動返回
            self?.navigationController?.popViewController(animated: true)
            print("🗑️ Stage1: 刪除後手動返回上一頁")
        })
        
        present(alert, animated: true)
    }
}
