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

