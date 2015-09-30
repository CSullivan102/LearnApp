//
//  NSPredicate+ParentTopic.swift
//  Learn
//
//  Created by Christopher Sullivan on 9/25/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import Foundation

extension NSPredicate {
    public convenience init(parentTopic: Topic) {
        self.init(format: "parent = %@", parentTopic)
    }
    
    public class func predicateForBaseTopic() -> NSPredicate {
        return NSPredicate(format: "baseTopic == YES")
    }
}