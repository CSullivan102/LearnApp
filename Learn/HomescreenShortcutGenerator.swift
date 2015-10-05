//
//  HomescreenShortcutGenerator.swift
//  EmojiReadingList
//
//  Created by Christopher Sullivan on 10/5/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import Foundation
import LearnKit
import CoreData

struct HomescreenShortcutGenerator {
    static func generateShortcutsFromBaseTopic(baseTopic: Topic, andManagedObjectContext managedObjectContext: NSManagedObjectContext) {
        let fetchRequest = Topic.sortedFetchRequest
        fetchRequest.predicate = NSPredicate(parentTopic: baseTopic)
        let results = try! managedObjectContext.executeFetchRequest(fetchRequest)
        if let topicArray = results as? [Topic] {
            var shortcutItems = [UIMutableApplicationShortcutItem]()
            for (index, topic) in topicArray.enumerate() where index < 3 {
                let shortcutItem = UIMutableApplicationShortcutItem(type: "com.sullivan.j.chris.Learn.topic", localizedTitle: topic.iconAndName, localizedSubtitle: nil, icon: nil, userInfo: ["objectID": topic.objectID.URIRepresentation().absoluteString])
                shortcutItems.append(shortcutItem)
            }
            UIApplication.sharedApplication().shortcutItems = shortcutItems
        }
    }
}