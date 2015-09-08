//
//  CoreDataStack.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/18/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import Foundation
import CoreData

// Core Data Setup

private let ModelName = "LearnModel"

public class ManagedObject: NSManagedObject {
}

public protocol ManagedObjectContextSettable: class {
    var managedObjectContext: NSManagedObjectContext! { get set }
}

public protocol ManagedObjectType {
    static var entityName: String { get }
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
}

extension ManagedObjectType {
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return []
    }
    
    public static var sortedFetchRequest: NSFetchRequest {
        let request = NSFetchRequest(entityName: entityName)
        request.sortDescriptors = defaultSortDescriptors
        return request
    }
}

public func createMainContext() -> NSManagedObjectContext {
    let context = NSManagedObjectContext(
        concurrencyType: .MainQueueConcurrencyType)
    context.persistentStoreCoordinator = createCoordinator()
    return context
}

private func createCoordinator() -> NSPersistentStoreCoordinator {
    let coordinator = NSPersistentStoreCoordinator(
        managedObjectModel: model())
    try! coordinator.addPersistentStoreWithType(NSSQLiteStoreType,
        configuration: nil, URL: storeURL(), options: nil)
    return coordinator
}

private func storeURL() -> NSURL {
    guard let directory = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.com.sullivan.j.chris.Learn")
    else { fatalError("Could not get container URL for app group") }
    
    return directory
        .URLByAppendingPathComponent(ModelName)
        .URLByAppendingPathExtension("sqlite")
}

private func model() -> NSManagedObjectModel {
    let bundle = NSBundle(forClass: Topic.self)
    guard let modelURL = bundle.URLForResource(ModelName,
        withExtension: "momd")
        else {
            fatalError("Managed object model not found")
    }
    guard let model = NSManagedObjectModel(contentsOfURL: modelURL)
        else {
            fatalError("Could not load managed object model from \(modelURL)")
    }
    return model
}

extension NSManagedObjectContext {
    public func insertObject<A: ManagedObject where A: ManagedObjectType>() -> A {
        guard let obj = NSEntityDescription.insertNewObjectForEntityForName(A.entityName, inManagedObjectContext: self) as? A else {
            fatalError("Wrong object type")
        }
        return obj
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