//
//  TopicShareCollectionViewCell.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/25/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit
import LearnKit

class TopicShareCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var topic: Topic? {
        didSet {
            guard let titleLabel = titleLabel else {
                return
            }
            titleLabel.text = topic?.icon
        }
    }
}
