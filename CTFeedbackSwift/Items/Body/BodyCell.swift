//
//  BodyCell.swift
//  CTFeedbackSwift
//
//  Created by 和泉田 領一 on 2017/09/16.
//  Copyright © 2017年 CAPH TECH. All rights reserved.
//

import UIKit

protocol BodyCellEventProtocol {
    func bodyCellHeightChanged()
    func bodyTextDidChange(_ text: String?)
}

class BodyCell: UITableViewCell {
    var eventHandler: BodyCellEventProtocol?

    let textView: UITextView = {
        let result = UITextView(frame: CGRect.zero)
        result.textContainerInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15);
        result.translatesAutoresizingMaskIntoConstraints = false
        result.isScrollEnabled = false
        result.font = .systemFont(ofSize: 14.0)
        result.isOpaque = false
        result.layer.borderWidth = 0
        result.layer.borderColor = UIColor.white.cgColor
        result.backgroundColor = UIColor.black.withAlphaComponent(0.15)

        result.layer.cornerRadius = 10
        return result
    }()
    var heightConstraint: NSLayoutConstraint?

    var height: CGFloat {
        let size = textView.sizeThatFits(CGSize(width: textView.frame.width,
                                                height: CGFloat.greatestFiniteMagnitude))
        return max(100.0, size.height)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        textView.delegate = self
        textView.textColor = .white
        contentView.addSubview(textView)
        contentView.backgroundColor = .clear
        contentView.topAnchor.constraint(equalTo: textView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: textView.bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: -15).isActive = true
        contentView.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 15).isActive = true
        heightConstraint = contentView.heightAnchor.constraint(equalToConstant: height)
        heightConstraint?.priority = .defaultHigh
        heightConstraint?.isActive = true
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }
}

extension BodyCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        heightConstraint?.constant = height
        eventHandler?.bodyCellHeightChanged()
        eventHandler?.bodyTextDidChange(textView.text)
    }
}

extension BodyCell: CellFactoryProtocol {
    static func configure(_ cell: BodyCell,
                          with item: BodyItem,
                          for indexPath: IndexPath,
                          eventHandler: BodyCellEventProtocol) {
        cell.textView.text = item.bodyText
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.eventHandler = eventHandler
    }
}
