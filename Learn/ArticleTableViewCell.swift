//
//  ArticleTableViewCell.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/20/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit
import LearnKit

class ArticleTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var excerptLabel: UILabel!
    
    var learnItem: LearnItem? {
        didSet {
            guard let titleLabel = titleLabel, urlLabel = urlLabel, excerptLabel = excerptLabel else {
                return
            }
            titleLabel.text = learnItem?.title
            urlLabel.text = learnItem?.url?.host
            excerptLabel.text = learnItem?.excerpt
        }
    }
}
