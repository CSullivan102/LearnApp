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
    @NSManaged var name: String
    @NSManaged var parent: Topic?
    @NSManaged var children: Set<Topic>?
    @NSManaged var items: Set<LearnItem>?
}

extension Topic: ManagedObjectType {
    public static var entityName: String {
        return "Topic"
    }
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "name", ascending: true)]
    }
}