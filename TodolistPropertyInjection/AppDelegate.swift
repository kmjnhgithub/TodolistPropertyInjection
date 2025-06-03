//
//  AppDelegate.swift
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/2.
//

// MARK: - AppDelegate.swift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 創建主視窗
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = MainTabBarController()
        window?.makeKeyAndVisible()
        
        // 印出目前使用的階段資訊
        print("""
        
          ========================================
           Todo App - 資料傳遞學習專案
        ========================================
        
        📱 目前階段：Stage 1 - Property直接傳遞
        
         測試重點：
        • 在Tab2新增Todo後，Tab1不會自動更新
        • 需要手動切換Tab或重新進入才能看到新資料
        • Detail頁面刪除後，List頁面需要手動刷新
        
          體驗方式：
        1. 在「新增Todo」頁面新增項目
        2. 觀察「Todo清單」沒有自動更新
        3. 手動切換Tab才能看到新項目
        4. 進入Detail頁面測試刪除功能
        5. 觀察返回後需要手動刷新的限制
        
         Stage 1 特點：
          簡單直觀的資料傳遞
         Tab間無法自動同步
         需要手動刷新UI
         資料回傳困難
        
        ========================================
        
        """)
        
        return true
    }

    // MARK: UISceneSession Lifecycle (iOS 13+支援)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // 清理被丟棄的scene sessions
    }
    
    // MARK: - App Lifecycle
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("📱 App進入背景")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("📱 App即將進入前景")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("📱 App變為活躍狀態")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("📱 App即將變為非活躍狀態")
    }
}

