//
//  TodoTableViewCell.swift
//  TodolistPropertyInjection
//
//  Created by mike liu on 2025/6/2.
//

import UIKit

// MARK: - Custom TodoTableViewCell
class TodoTableViewCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let statusLabel = UILabel()
    private let containerView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // 容器視圖
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .systemGray6
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        contentView.addSubview(containerView)
        
        // 標題標籤
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        containerView.addSubview(titleLabel)
        
        // 狀態標籤
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .systemFont(ofSize: 12, weight: .regular)
        statusLabel.textAlignment = .right
        containerView.addSubview(statusLabel)
        
        // 設定約束
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: statusLabel.leadingAnchor, constant: -8),
            
            statusLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            statusLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            statusLabel.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func configure(with todo: Todo) {
        titleLabel.text = todo.title
        statusLabel.text = todo.isCompleted ? "✅ 完成" : "⏳ 待辦"
        statusLabel.textColor = todo.isCompleted ? .systemGreen : .systemOrange
        
        // 完成的項目使用刪除線
        if todo.isCompleted {
            let attributedString = NSAttributedString(
                string: todo.title,
                attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
            titleLabel.attributedText = attributedString
        } else {
            titleLabel.attributedText = nil
            titleLabel.text = todo.title
        }
    }
}
