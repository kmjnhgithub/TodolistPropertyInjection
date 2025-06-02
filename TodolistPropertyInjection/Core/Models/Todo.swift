//
//  TodoItem.swift
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/2.
//
// MARK: - Todo Model
import Foundation

struct Todo {
    let uuid: String = UUID().uuidString
    var title: String
    var isCompleted: Bool = false
    
    init(title: String) {
        self.title = title
    }
}

