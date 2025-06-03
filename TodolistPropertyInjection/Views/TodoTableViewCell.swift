// MARK: - 修正的TodoTableViewCell
// 解決Todo狀態切換後文字樣式不正確的問題

import UIKit

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
    
    // MARK: - Cell重用準備
    override func prepareForReuse() {
        super.prepareForReuse()
        // 🎯 關鍵：清除之前的狀態，避免重用問題
        titleLabel.attributedText = nil
        titleLabel.text = nil
        statusLabel.text = nil
        statusLabel.textColor = .label
        print("🔄 Cell重用清理完成")
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
        titleLabel.numberOfLines = 0
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
    
    // MARK: - 核心配置方法 (修正版)
    func configure(with todo: Todo) {
        print("🎨 配置Cell - Title: \(todo.title), Completed: \(todo.isCompleted)")
        
        // 🎯 Step 1: 先清除所有之前的樣式
        titleLabel.attributedText = nil
        titleLabel.text = nil
        
        // 🎯 Step 2: 設置狀態標籤
        statusLabel.text = todo.isCompleted ? "✅ 完成" : "⏳ 待辦"
        statusLabel.textColor = todo.isCompleted ? .systemGreen : .systemOrange
        
        // 🎯 Step 3: 根據狀態設置文字樣式
        if todo.isCompleted {
            // 已完成：使用刪除線
            let attributedString = NSMutableAttributedString(string: todo.title)
            attributedString.addAttribute(
                .strikethroughStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSRange(location: 0, length: todo.title.count)
            )
            attributedString.addAttribute(
                .strikethroughColor,
                value: UIColor.systemGray,
                range: NSRange(location: 0, length: todo.title.count)
            )
            attributedString.addAttribute(
                .foregroundColor,
                value: UIColor.systemGray,
                range: NSRange(location: 0, length: todo.title.count)
            )
            
            titleLabel.attributedText = attributedString
            print("✅ 已套用完成樣式：刪除線 + 灰色文字")
            
        } else {
            // 未完成：普通文字
            titleLabel.text = todo.title
            titleLabel.textColor = .label
            print("⏳ 已套用待辦樣式：普通文字")
        }
        
        // 🎯 Step 4: 強制刷新顯示
        titleLabel.setNeedsDisplay()
        layoutIfNeeded()
        
        print("🎨 Cell配置完成 - 最終狀態檢查:")
        print("   - attributedText: \(titleLabel.attributedText != nil ? "有" : "無")")
        print("   - text: \(titleLabel.text ?? "nil")")
        print("   - textColor: \(titleLabel.textColor)")
    }
    
    // MARK: - 除錯方法
    func debugCellState() {
        print("""
        🔍 Cell狀態除錯:
        - titleLabel.text: \(titleLabel.text ?? "nil")
        - titleLabel.attributedText: \(titleLabel.attributedText?.string ?? "nil")
        - titleLabel.textColor: \(titleLabel.textColor)
        - statusLabel.text: \(statusLabel.text ?? "nil")
        - statusLabel.textColor: \(statusLabel.textColor)
        """)
    }
}

/*
🎯 修正重點說明：

✅ 解決的問題：
1. Cell重用時的狀態混亂
2. attributedText和text的衝突
3. 樣式更新不即時
4. 視覺狀態與資料狀態不一致

✅ 關鍵改進：
1. prepareForReuse() - 清除重用狀態
2. 明確的樣式設置順序
3. 強制刷新顯示
4. 詳細的除錯日誌

✅ 設置順序：
1. 清除之前的attributedText
2. 設置狀態標籤
3. 根據isCompleted設置文字樣式
4. 強制刷新顯示

⚠️ 常見錯誤避免：
- 不要同時設置text和attributedText
- 重用Cell時要清除之前的狀態
- 屬性設置要有明確的順序
- 複雜樣式變更後要強制刷新

這個修正版本確保：
✅ 完成的Todo：刪除線 + 灰色文字
✅ 未完成的Todo：普通黑色文字
✅ 狀態切換後立即更新
✅ Cell重用不會有樣式混亂
*/
