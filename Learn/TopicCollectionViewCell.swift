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
    
    private var dashedBorder: CAShapeLayer?
    private var plusLayer: CAShapeLayer?
    
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
                let borderBounds = CGRect(x: bgBounds.origin.x + 1, y: bgBounds.origin.y + 1, width: bgBounds.width - 2, height: bgBounds.height - 2)
                
                dashedBorder = CAShapeLayer()
                guard let dashed = dashedBorder
                else { return }
            
                dashed.path = UIBezierPath(roundedRect: borderBounds, cornerRadius: iconBackgroundView.layer.cornerRadius - 1).CGPath
                dashed.fillColor = UIColor.clearColor().CGColor
                dashed.strokeColor = emojiHightlightColor.CGColor
                dashed.lineWidth = 2.0
                dashed.lineDashPattern = [5, 3]
                
                let plusLength = bgBounds.width * 0.4
                let plusPath = UIBezierPath()
                plusPath.moveToPoint(CGPoint(x: bgBounds.width / 2 - plusLength / 2, y: bgBounds.height / 2))
                plusPath.addLineToPoint(CGPoint(x: bgBounds.width / 2 + plusLength / 2, y: bgBounds.height / 2))
                plusPath.moveToPoint(CGPoint(x: bgBounds.width / 2, y: bgBounds.height / 2 - plusLength / 2))
                plusPath.addLineToPoint(CGPoint(x: bgBounds.width / 2, y: bgBounds.height / 2 + plusLength / 2))
                
                plusLayer = CAShapeLayer()
                guard let plus = plusLayer
                else { return }
                
                plus.path = plusPath.CGPath
                plus.fillColor = UIColor.clearColor().CGColor
                plus.strokeColor = emojiHightlightColor.CGColor
                plus.lineWidth = 2.0
                
                iconBackgroundView.backgroundColor = UIColor.clearColor()
                iconBackgroundView.layer.addSublayer(dashed)
                iconBackgroundView.layer.addSublayer(plus)
            }
        }
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        topic = nil
        addableCell = false
        dashedBorder?.removeFromSuperlayer()
        plusLayer?.removeFromSuperlayer()
        iconBackgroundView.backgroundColor = UIColor(red: 66.0 / 255.0, green: 213.0 / 255.0, blue: 81.0 / 255.0, alpha: 1.0)
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
    
    override public var addableCell: Bool {
        didSet {
            if addableCell {
                guard let topicNameLabel = topicNameLabel
                else { return }
                
                topicNameLabel.text = nil
            }
        }
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        topicNameLabel.text = nil
    }
}
