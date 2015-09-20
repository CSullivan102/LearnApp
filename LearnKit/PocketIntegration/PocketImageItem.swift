//
//  PocketImageItem.swift
//  Learn
//
//  Created by Christopher Sullivan on 9/16/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import Argo

public struct PocketImageItem {
    public let src: String
}

extension PocketImageItem: Decodable {
    static func create(src: String) -> PocketImageItem {
        return PocketImageItem(src: src)
    }
    
    public static func decode(json: JSON) -> Decoded<PocketImageItem> {
        return create
            <^> json <| "src"
    }
}
