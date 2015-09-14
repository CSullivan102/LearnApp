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
    @NSManaged public var excerpt: String?
    @NSManaged public var wordCount: NSNumber?
    @NSManaged public var imageURL: NSURL?
    @NSManaged public var pocketItemID: NSNumber?

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
    
    public func copyDataFromPocketItem(pocketItem: PocketItem) {
        // Only overwrite title, URL if they're the default value
        if let resolvedTitle = pocketItem.resolved_title where title == ""{
            title = resolvedTitle
        }
        
        if let givenUrl = pocketItem.given_url where url == nil {
            url = NSURL(string: givenUrl)
        }
        
        excerpt = pocketItem.excerpt
        if let itemID = Int32(pocketItem.item_id) {
            pocketItemID = NSNumber(int: itemID)
        }
        if let images = pocketItem.images,
            (_, firstImage) = images.first {
                imageURL = NSURL(string: firstImage.src)
        }
        if let wordCount = pocketItem.word_count, wordCountInt = Int32(wordCount) {
            self.wordCount = NSNumber(int: wordCountInt)
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