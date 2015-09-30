//
//  NSManagedObjectContext+InsertSave.swift
//  Learn
//
//  Created by Christopher Sullivan on 9/16/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
    public func insertObject<A: ManagedObject where A: ManagedObjectType>() -> A {
        guard let obj = NSEntityDescription.insertNewObjectForEntityForName(A.entityName, inManagedObjectContext: self) as? A else {
            fatalError("Wrong object type")
        }
        return obj
    }
    
    public func getObjectForObjectID<A: ManagedObject where A: ManagedObjectType>(objectID: NSManagedObjectID) -> A? {
        if let object = objectWithID(objectID) as? A {
            return object
        }
        return nil
    }
}

extension NSManagedObjectContext {
    public func saveOrRollback() {
        do {
            try save()
        } catch {
            rollback()
        }
    }
    
    public func performChanges(block: () -> ()) {
        performBlock {
            block()
            self.saveOrRollback()
        }
    }
}
