//
//  TodoListViewController.swift (Debug版本)
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/2.
//

import UIKit
import Combine

// MARK: - TodoList ViewController (Badge除錯版)
class TodoListViewController: UIViewController {
    private var viewModel: TodoListViewModel!
    private var tableView: UITableView!
    
    // 🎯 Combine訂閱管理
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔍 TodoListViewController: viewDidLoad 開始")
        setupViewModel()
        setupUI()
        setupBadgeObservation()
        print("🔍 TodoListViewController: viewDidLoad 完成")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("🔍 TodoListViewController: viewWillAppear 開始")
        // 🎯 Stage1限制：需要手動刷新資料
        tableView.reloadData()
        print("🔄 手動刷新TodoList資料")
        
        // 🎯 Badge處理：當用戶查看清單時清除Badge
        viewModel.markBadgeAsViewed()
        print("🔍 TodoListViewController: viewWillAppear 完成")
    }
    
    private func setupViewModel() {
        print("🔍 開始設置TodoListViewModel")
        viewModel = TodoListViewModel()
        print("🔍 TodoListViewModel設置完成，當前Badge: \(viewModel.badgeCount)")
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
            title: getCurrentStageName(),
            style: .plain,
            target: nil,
            action: nil
        )
        // 顯示目前使用的資料傳遞方式
        navigationItem.rightBarButtonItem?.tintColor = .systemGreen
    }
    
    // MARK: - Badge觀察設置 (Debug版)
    
    private func setupBadgeObservation() {
        print("🔍 開始設置Badge觀察")
        
        // 🎯 使用Combine觀察Badge變化
        viewModel.$badgeCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] badgeCount in
                print("🔍 Badge變化觀察到: \(badgeCount)")
                self?.updateTabBarBadge(count: badgeCount)
            }
            .store(in: &cancellables)
        
        print("✅ TodoListViewController: Badge觀察已設置")
        
        // 🔍 立即檢查當前Badge狀態
        print("🔍 當前Badge狀態: \(viewModel.badgeCount)")
        updateTabBarBadge(count: viewModel.badgeCount)
    }
    
    private func updateTabBarBadge(count: Int) {
        print("🔍 準備更新TabBar Badge: \(count)")
        
        // 🎯 更新TabBar的Badge
        DispatchQueue.main.async { [weak self] in
            print("🔍 在主線程更新Badge")
            
            guard let self = self else {
                print("⚠️ self已被釋放")
                return
            }
            
            guard let tabBarController = self.tabBarController else {
                print("⚠️ tabBarController不存在")
                return
            }
            
            guard let tabBarItems = tabBarController.tabBar.items else {
                print("⚠️ tabBar.items不存在")
                return
            }
            
            guard tabBarItems.count > 0 else {
                print("⚠️ tabBar.items為空")
                return
            }
            
            if count > 0 {
                tabBarItems[0].badgeValue = "\(count)"
                tabBarItems[0].badgeColor = .systemRed
                print("🔴 TabBar Badge已設置: \(count)")
            } else {
                tabBarItems[0].badgeValue = nil
                print("🔴 TabBar Badge已清除")
            }
            
            // 🔍 驗證Badge是否真的設置了
            if let badgeValue = tabBarItems[0].badgeValue {
                print("✅ Badge驗證成功: \(badgeValue)")
            } else {
                print("❌ Badge驗證失敗: nil")
            }
        }
    }
    
    // MARK: - Debug方法
    
    func debugBadgeState() {
        print("""
        🔍 Badge狀態除錯:
        ========================
        ViewModel Badge Count: \(viewModel.badgeCount)
        TabBar Items Count: \(tabBarController?.tabBar.items?.count ?? 0)
        Tab 0 Badge Value: \(tabBarController?.tabBar.items?[0].badgeValue ?? "nil")
        Tab 0 Badge Color: \(tabBarController?.tabBar.items?[0].badgeColor?.description ?? "nil")
        Cancellables Count: \(cancellables.count)
        ========================
        """)
    }
    
    // MARK: - 工具方法
    
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
    
    deinit {
        // 🎯 清理Combine訂閱
        cancellables.removeAll()
        print("🧹 TodoListViewController: 清理完成")
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
            // 🎯 需要手動更新UI（Stage1-3的限制）
            tableView.deleteRows(at: [indexPath], with: .fade)
            print("🗑️ 手動刪除TableView列")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
