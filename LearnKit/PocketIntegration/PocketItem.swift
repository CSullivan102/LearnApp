//
//  PocketItem.swift
//  Learn
//
//  Created by Christopher Sullivan on 9/16/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import Argo

public struct PocketItem {
    public let item_id: String
    public let title: String?
    public let resolved_title: String?
    public let given_url: String?
    public let excerpt: String?
    public let word_count: String?
    public let images: [String: PocketImageItem]?
    public var importedToLearn: Bool?
    
    public mutating func setImported(imported: Bool) {
        importedToLearn = imported
    }
}

extension PocketItem: Decodable {
    static func create(item_id: String)(title: String?)(resolved_title: String?)(given_url: String?)(excerpt: String?)(word_count: String?)(images: [String: PocketImageItem]?)(importedToLearn: Bool?) -> PocketItem {
        return PocketItem(item_id: item_id, title: title, resolved_title: resolved_title, given_url: given_url, excerpt: excerpt, word_count: word_count, images: images, importedToLearn: importedToLearn)
    }
    
    public static func decode(json: JSON) -> Decoded<PocketItem> {
        return create
            <^> json <| "item_id"
            <*> json <|? "title"
            <*> json <|? "resolved_title"
            <*> json <|? "given_url"
            <*> json <|? "excerpt"
            <*> json <|? "word_count"
            <*> json <|~? "images"
            <*> json <|? "importedToLearn"
    }
}
