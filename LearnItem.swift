//
//  LearnItem.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/18/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import Foundation
import CoreData

public final class LearnItem: ManagedObject {
    @NSManaged public var title: String
    @NSManaged public var url: NSURL?
    @NSManaged public var read: Bool
    @NSManaged public var topic: Topic?
    @NSManaged public var dateAdded: NSDate
    @NSManaged private var type: Int16

    public var itemType: LearnItemType {
        get {
            guard let t = LearnItemType(rawValue: type) else {
                fatalError("Unknown item type")
            }
            return t
        }
        set {
            type = newValue.rawValue
        }
    }
}

extension LearnItem: ManagedObjectType {
    public static var entityName: String {
        return "LearnItem"
    }
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "dateAdded", ascending: false)]
    }
}