//
//  TopicCollectionViewCell.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/20/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit
import LearnKit

class TopicCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var topicNameLabel: UILabel!
    
    var topic: Topic? {
        didSet {
            guard let topicNameLabel = topicNameLabel else {
                return
            }
            topicNameLabel.text = topic?.name
        }
    }
}
