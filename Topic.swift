//
//  Topic.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/18/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import Foundation
import CoreData

public final class Topic: ManagedObject {
    @NSManaged public var name: String
    @NSManaged public var icon: String
    @NSManaged public var parent: Topic?
    @NSManaged public var childTopics: NSOrderedSet? //<Topic>
    @NSManaged public var learnItems: NSOrderedSet? //<LearnItem>

    public var iconAndName: String {
        get {
            return "\(icon) \(name)"
        }
    }
}

extension Topic: ManagedObjectType {
    public static var entityName: String {
        return "Topic"
    }
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "name", ascending: true)]
    }
}