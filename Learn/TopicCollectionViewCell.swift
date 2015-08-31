//
//  TopicCollectionViewCell.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/20/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit

public class TopicCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet public weak var iconLabel: UILabel!
    @IBOutlet public weak var iconBackgroundView: UIView!
    
    public var topic: Topic? {
        didSet {
            guard let iconLabel = iconLabel
            else { return }
            iconLabel.text = topic?.icon
        }
    }
    
    public var addableCell = false {
        didSet {
            if addableCell {
                iconLabel.text = nil
                guard let emojiHightlightColor = iconBackgroundView.backgroundColor else { return }
                let bgBounds = iconBackgroundView.bounds
                let dashedBorder = CAShapeLayer()
                let borderBounds = CGRect(x: bgBounds.origin.x + 1, y: bgBounds.origin.y + 1, width: bgBounds.width - 2, height: bgBounds.height - 2)
                dashedBorder.path = UIBezierPath(roundedRect: borderBounds, cornerRadius: iconBackgroundView.layer.cornerRadius - 1).CGPath
                dashedBorder.fillColor = UIColor.clearColor().CGColor
                dashedBorder.strokeColor = emojiHightlightColor.CGColor
                dashedBorder.lineWidth = 2.0
                dashedBorder.lineDashPattern = [5, 3]
                
                let plusLength = bgBounds.width * 0.4
                let plusPath = UIBezierPath()
                plusPath.moveToPoint(CGPoint(x: bgBounds.width / 2 - plusLength / 2, y: bgBounds.height / 2))
                plusPath.addLineToPoint(CGPoint(x: bgBounds.width / 2 + plusLength / 2, y: bgBounds.height / 2))
                plusPath.moveToPoint(CGPoint(x: bgBounds.width / 2, y: bgBounds.height / 2 - plusLength / 2))
                plusPath.addLineToPoint(CGPoint(x: bgBounds.width / 2, y: bgBounds.height / 2 + plusLength / 2))
                
                let plusLayer = CAShapeLayer()
                plusLayer.path = plusPath.CGPath
                plusLayer.fillColor = UIColor.clearColor().CGColor
                plusLayer.strokeColor = emojiHightlightColor.CGColor
                plusLayer.lineWidth = 2.0
                
                iconBackgroundView.backgroundColor = UIColor.clearColor()
                iconBackgroundView.layer.addSublayer(dashedBorder)
                iconBackgroundView.layer.addSublayer(plusLayer)
            }
        }
    }
    
    override public func prepareForReuse() {
        topic = nil
        addableCell = false
    }
}

public class LabeledTopicCollectionViewCell: TopicCollectionViewCell {
    @IBOutlet weak var topicNameLabel: UILabel!
    
    override public var topic: Topic? {
        didSet {
            guard let topicNameLabel = topicNameLabel
            else { return }

            topicNameLabel.text = topic?.name
        }
    }
}
