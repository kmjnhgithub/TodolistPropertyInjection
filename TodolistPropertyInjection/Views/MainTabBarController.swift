//
//  MainTabBarController.swift
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/2.
//

// MARK: - Main TabBar Controller
import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupViewControllers()
    }
    
    private func setupTabBar() {
        tabBar.backgroundColor = .systemBackground
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .systemGray
    }
    
    private func setupViewControllers() {
        // Tab 1: Todo清單
        let todoListVC = TodoListViewController()
        let todoListNav = UINavigationController(rootViewController: todoListVC)
        todoListNav.tabBarItem = UITabBarItem(
            title: "Todo清單",
            image: UIImage(systemName: "list.bullet"),
            selectedImage: UIImage(systemName: "list.bullet.circle.fill")
        )
        
        // Tab 2: 新增Todo
        let addTodoVC = AddTodoViewController()
        let addTodoNav = UINavigationController(rootViewController: addTodoVC)
        addTodoNav.tabBarItem = UITabBarItem(
            title: "新增Todo",
            image: UIImage(systemName: "plus.circle"),
            selectedImage: UIImage(systemName: "plus.circle.fill")
        )
        
        viewControllers = [todoListNav, addTodoNav]
    }
}
