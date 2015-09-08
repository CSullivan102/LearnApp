//
//  ArticleTableViewCell.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/20/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit
import LearnKit
import Haneke

class ArticleTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var excerptLabel: UILabel!
    @IBOutlet weak var articleImageView: UIImageView!
    
    var learnItem: LearnItem? {
        didSet {
            guard let titleLabel = titleLabel, urlLabel = urlLabel, excerptLabel = excerptLabel, articleImageView = articleImageView
            else { return }
            titleLabel.text = learnItem?.title
            urlLabel.text = learnItem?.url?.host
            excerptLabel.text = learnItem?.excerpt
            
            if let imageURL = learnItem?.imageURL {
                articleImageView.hnk_setImageFromURL(imageURL)
            } else {
                articleImageView.hidden = true
            }
        }
    }
    
    override func prepareForReuse() {
        articleImageView.image = nil
    }
}
