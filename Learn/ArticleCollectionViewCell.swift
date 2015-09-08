//
//  ArticleCollectionViewCell.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/20/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit
import LearnKit

class ArticleCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    
    var learnItem: LearnItem? {
        didSet {
            guard let titleLabel = titleLabel, urlLabel = urlLabel else {
                return
            }
            titleLabel.text = learnItem?.title
            urlLabel.text = learnItem?.url?.host
        }
    }
}
