//
//  TopicCollectionControllable.swift
//  Learn
//
//  Created by Christopher Sullivan on 9/7/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import CoreData

public protocol TopicCollectionControllable: ManagedObjectContextSettable {
    var parentTopic: Topic? { get set }
}

extension TopicCollectionControllable {
    
    public var topicViewState: TopicViewState {
        get {
            return TopicViewState(fromTopic: parentTopic)
        }
    }
    
    public func setupParentTopic(completion: () -> Void) {
        if let _ = parentTopic {
            completion()
        } else {
            getBaseTopic {
                topic in
                self.parentTopic = topic
                completion()
            }
        }
    }
    
    public func getFetchedResultsControllerForTopic(topic: Topic) -> NSFetchedResultsController {
        let request = Topic.sortedFetchRequest
        request.fetchBatchSize = 20
        request.predicate = NSPredicate(parentTopic: topic)
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    private func getBaseTopic(completion: (Topic) -> Void) {
        let baseTopicRequest = NSFetchRequest(entityName: Topic.entityName)
        baseTopicRequest.predicate = NSPredicate.predicateForBaseTopic()
        guard let result = try! managedObjectContext.executeFetchRequest(baseTopicRequest) as? [Topic] else {
            fatalError("Failed to fetch base topic")
        }
        if result.isEmpty {
            managedObjectContext.performChanges {
                let baseTopic: Topic = self.managedObjectContext.insertObject()
                baseTopic.name = "Base"
                baseTopic.icon = ""
                baseTopic.baseTopic = true
                completion(baseTopic)
            }
        } else {
            guard let baseTopic = result.first else {
                fatalError("Non-empty Base topic result doesn't have a first element")
            }
            completion(baseTopic)
        }

    }
}

public enum TopicViewState {
    case BaseTopic
    case SubTopic
    
    public init(fromTopic: Topic?) {
        if let topic = fromTopic {
            if topic.baseTopic {
                self = .BaseTopic
            } else {
                self = .SubTopic
            }
        } else {
            self = .BaseTopic
        }
    }
}