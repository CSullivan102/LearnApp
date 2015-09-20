//
//  CoreDataSetup.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/18/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import CoreData

// Core Data Setup

private let ModelName = "LearnModel"

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
    guard let directory = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.com.sullivan.j.chris.Learn") else {
        fatalError("Could not get container URL for app group")
    }
    
    return directory
        .URLByAppendingPathComponent(ModelName)
        .URLByAppendingPathExtension("sqlite")
}

private func model() -> NSManagedObjectModel {
    let bundle = NSBundle(forClass: Topic.self)
    
    guard let modelURL = bundle.URLForResource(ModelName, withExtension: "momd") else {
        fatalError("Managed object model not found")
    }
    guard let model = NSManagedObjectModel(contentsOfURL: modelURL) else {
        fatalError("Could not load managed object model from \(modelURL)")
    }
    return model
}
