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
    @NSManaged var title: String
    @NSManaged var url: NSURL
    @NSManaged var type: Int16
    @NSManaged var read: Bool
    @NSManaged var topic: Topic?
    @NSManaged var dateAdded: NSDate
}

extension LearnItem: ManagedObjectType {
    public static var entityName: String {
        return "LearnItem"
    }
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "dateAdded", ascending: false)]
    }
}