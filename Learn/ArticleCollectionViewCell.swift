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
    
    var learnItem: LearnItem? {
        didSet {
            guard let titleLabel = titleLabel else {
                return
            }
            titleLabel.text = learnItem?.title
        }
    }
}
