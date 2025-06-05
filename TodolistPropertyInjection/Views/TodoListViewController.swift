//
//  TodoListViewController.swift (最小化重構版)
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/2.
//

import UIKit

// MARK: - TodoList ViewController (統一接口版)
// 🎯 使用統一的 TodoListViewModelProtocol 接口
// 自動適配 UIKit (Stage 1-6) 和 Combine (Stage 7+) 版本

class TodoListViewController: UIViewController {
    
    // 🎯 關鍵改變：使用 Protocol 而非具體類型
    private var viewModel: TodoListViewModelProtocol!
    private var tableView: UITableView!
    
    // MARK: - Stage配置管理
    private let stageManager = StageConfigurationManager.shared
    private var currentStage: TodoDataStage {
        return stageManager.getCurrentStage()
    }
    
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
        
        // 🎯 手動刷新資料（保持各 Stage 的行為一致性）
        tableView.reloadData()
        print("🔄 手動刷新TodoList資料")
        
        // 🎯 Badge處理：當用戶查看清單時清除Badge（只有支援Badge的Stage）
        if currentStage.badgeSupported {
            viewModel.markBadgeAsViewed()
            print("👁️ 用戶查看清單，清除Badge")
        } else {
            print("🔍 \(currentStage.displayName) 不支援Badge，跳過清除")
        }
        
        print("🔍 TodoListViewController: viewWillAppear 完成")
    }
    
    // MARK: - 設置方法
    
    private func setupViewModel() {
        print("🔍 開始設置ViewModel（透過ServiceContainer）")
        
        // 🎯 關鍵改變：透過 ServiceContainer 自動選擇正確的 ViewModel
        viewModel = ServiceContainer.shared.createTodoListViewModel()
        
        // 🔍 除錯：印出實際創建的 ViewModel 類型
        print("✅ ViewModel創建完成：\(type(of: viewModel))")
        
        // 🔍 印出當前容器配置
        ServiceContainer.shared.printContainerInfo()
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
        // 🎯 使用 ServiceContainer 的工具方法
        let stage = ServiceContainer.shared.getCurrentStageInfo()
        let usesCombine = ServiceContainer.shared.usesCombineFramework()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "\(stage.displayName)\(usesCombine ? " 🚀" : "")",
            style: .plain,
            target: self,
            action: #selector(stageInfoTapped)
        )
        
        // 根據Badge支援狀態設置顏色
        let color: UIColor = stage.badgeSupported ? .systemGreen : .systemOrange
        navigationItem.rightBarButtonItem?.tintColor = color
    }
    
    // MARK: - Badge觀察設置（統一接口版）
    
    private func setupBadgeObservation() {
        print("🔍 開始設置Badge觀察（統一接口）")
        
        // 🎯 只有支援Badge的Stage才設置觀察
        guard currentStage.badgeSupported else {
            print("🔍 \(currentStage.displayName) 不支援Badge，跳過設置")
            return
        }
        
        // 🎯 關鍵改變：使用統一的回調接口，不管底層是UIKit還是Combine
        viewModel.badgeUpdateHandler = { [weak self] badgeCount in
            print("🔍 收到Badge更新回調: \(badgeCount)")
            self?.updateTabBarBadge(count: badgeCount)
        }
        
        print("✅ TodoListViewController: Badge觀察已設置（統一接口）")
    }
    
    private func updateTabBarBadge(count: Int) {
        print("🔍 準備更新TabBar Badge: \(count)")
        
        // 🎯 確保只有支援Badge的Stage才更新
        guard currentStage.badgeSupported else {
            print("🔍 \(currentStage.displayName) 不支援Badge，跳過更新")
            return
        }
        
        // 🎯 更新TabBar的Badge
        DispatchQueue.main.async { [weak self] in
            print("🔍 在主線程更新Badge")
            
            guard let self = self,
                  let tabBarController = self.tabBarController,
                  let tabBarItems = tabBarController.tabBar.items,
                  !tabBarItems.isEmpty else {
                print("⚠️ TabBar相關組件不可用")
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
                print("✅ Badge驗證成功: 已清除")
            }
        }
    }
    
    // MARK: - 事件處理
    
    @objc private func stageInfoTapped() {
        // 🎯 顯示當前Stage的詳細資訊
        showStageInfoAlert()
    }
    
    private func showStageInfoAlert() {
        let stage = currentStage
        let usesCombine = ServiceContainer.shared.usesCombineFramework()
        let vmType = usesCombine ? "Combine" : "UIKit"
        
        let alert = UIAlertController(
            title: "\(stage.fullDescription)",
            message: """
            🎨 ViewModel: \(vmType) 版本
            \(stage.badgeDescription)
            🔄 同步能力: \(stage.syncCapability.rawValue) \(stage.syncCapability.emoji)
            
            點擊「查看說明」了解更多詳情
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
        print("🧹 TodoListViewController: 清理完成")
    }
}

// MARK: - TodoList TableView Methods (保持原樣)
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
        
        // 🎯 使用 ServiceContainer 創建 DetailViewController 的 ViewModel
        let detailVC = TodoDetailViewController()
        detailVC.todoUUID = todo.uuid
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteTodo(at: indexPath.row)
            // 🎯 需要手動更新UI
            tableView.deleteRows(at: [indexPath], with: .fade)
            print("🗑️ 手動刪除TableView列")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - ViewController 重構說明
/*
🎯 重構重點：

1. **統一接口使用**：
   - 從具體的 TodoListViewModel 改為 TodoListViewModelProtocol
   - 透過 ServiceContainer 自動選擇正確的實作版本
   - ViewController 完全不知道底層是 UIKit 還是 Combine

2. **自動化架構選擇**：
   - ServiceContainer 根據 DataService 類型自動選擇 ViewModel
   - Stage 7+ 自動使用 Combine 版本
   - Stage 1-6 自動使用 UIKit 版本

3. **統一的 Badge 處理**：
   - 使用 badgeUpdateHandler 回調接口
   - 不管底層技術，都使用相同的回調機制
   - UIKit 版本直接使用回調，Combine 版本橋接回調

4. **保持學習體驗**：
   - 各 Stage 的行為特性保持不變
   - Badge 支援狀態正確反映
   - 手動刷新機制保持一致

5. **除錯和資訊展示**：
   - 導航欄顯示 Stage 和 ViewModel 類型
   - 新增容器資訊查看功能
   - 豐富的日誌輸出便於除錯

6. **程式碼簡化**：
   - 移除了 Combine 特定的程式碼
   - 不需要條件判斷 Stage 類型
   - 統一的接口讓程式碼更清晰

✅ 重構效果：
- ViewController 程式碼更簡潔
- 自動適配不同 Stage 的架構
- 保持完整的學習體驗
- 便於未來擴展和維護

🎓 學習價值：
- 體驗接口導向程式設計
- 理解多型的實際應用
- 感受架構抽象的威力
- 掌握統一接口的設計技巧
*/
