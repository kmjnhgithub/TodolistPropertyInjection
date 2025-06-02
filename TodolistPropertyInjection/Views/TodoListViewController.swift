//
//  Untitled.swift
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/2.
//

import UIKit

// MARK: - TodoList ViewController
class TodoListViewController: UIViewController {
    private var viewModel: TodoListViewModel!
    private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 🎯 Stage1限制：需要手動刷新資料
        tableView.reloadData()
        print("🔄 Stage1: 手動刷新TodoList資料")
    }
    
    private func setupViewModel() {
        viewModel = TodoListViewModel()
    }
    
    private func setupUI() {
        title = "Todo清單"
        view.backgroundColor = .systemBackground
        
        setupTableView()
        setupNavigationBar()
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TodoTableViewCell.self, forCellReuseIdentifier: "TodoCell")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Stage1",
            style: .plain,
            target: nil,
            action: nil
        )
        // 顯示目前使用的資料傳遞方式
        navigationItem.rightBarButtonItem?.tintColor = .systemGreen
    }
}

// MARK: - TodoList TableView Methods
extension TodoListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TodoTableViewCell
        let todo = viewModel.getTodo(at: indexPath.row)
        cell.configure(with: todo)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let todo = viewModel.getTodo(at: indexPath.row)
        let detailVC = TodoDetailViewController()
        detailVC.todoUUID = todo.uuid
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteTodo(at: indexPath.row)
            // 🎯 Stage1限制：需要手動更新UI
            tableView.deleteRows(at: [indexPath], with: .fade)
            print("🗑️ Stage1: 手動刪除TableView列")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
