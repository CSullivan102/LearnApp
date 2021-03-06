//
//  PocketItemTableViewCell.swift
//  Learn
//
//  Created by Christopher Sullivan on 9/14/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit
import LearnKit
import Haneke

class PocketItemTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var excerptLabel: UILabel!
    @IBOutlet weak var articleImageView: UIImageView!
    
    var pocketItem: PocketItem? {
        didSet {
            guard let titleLabel = titleLabel, urlLabel = urlLabel, excerptLabel = excerptLabel, articleImageView = articleImageView else {
                return
            }
            
            titleLabel.text = pocketItem?.resolved_title ?? ""
            urlLabel.text = pocketItem?.given_url ?? ""
            excerptLabel.text = pocketItem?.excerpt
            
            if let alreadyImported = pocketItem?.importedToLearn where alreadyImported == true {
                contentView.alpha = 0.2
                urlLabel.text = "Already Imported ✅"
                self.userInteractionEnabled = false
            }
            
            if let images = pocketItem?.images,
                (_, firstImage) = images.first,
                imageURL = NSURL(string: firstImage.src) {
                    articleImageView.hnk_setImageFromURL(imageURL, format: Format<UIImage>(name: "101x101") {
                        let resizer = ImageResizer(size: CGSizeMake(101,101), scaleMode: articleImageView.hnk_scaleMode)
                        return resizer.resizeImage($0)
                        })
            } else {
                articleImageView.hidden = true
            }
        }
    }
    
    override func prepareForReuse() {
        articleImageView.image = UIImage(named: "LearnIconInverted")
        articleImageView.hidden = false
        userInteractionEnabled = true
        contentView.alpha = 1.0
    }
}
