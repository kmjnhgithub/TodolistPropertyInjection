//
//  ServiceContainer.swift
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/2.
//

// MARK: - Simple DI Container
class ServiceContainer {
    static let shared = ServiceContainer()
    private init() {}
    
    //  編譯時切換：只需要改這一行！
    private let currentDataService: TodoDataServiceProtocol = Stage3_ClosureDataService()
    
    func getDataService() -> TodoDataServiceProtocol {
        return currentDataService
    }
}
