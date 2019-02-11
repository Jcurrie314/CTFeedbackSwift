//
// Created by 和泉田 領一 on 2017/09/07.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import UIKit

final public class TopicCell: UITableViewCell {
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: TopicCell.reuseIdentifier)
    }

    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
}

extension TopicCell: CellFactoryProtocol {
    static func configure(_ cell: TopicCell,
                          with item: TopicItem,
                          for indexPath: IndexPath,
                          eventHandler: Any?) {
        cell.textLabel?.text = CTLocalizedString("CTFeedback.Topic")
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.text = item.topicTitle
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
    }
}
