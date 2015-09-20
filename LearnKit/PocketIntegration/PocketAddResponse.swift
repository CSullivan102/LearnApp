//
//  PocketAddResponse.swift
//  Learn
//
//  Created by Christopher Sullivan on 9/16/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import Argo

public struct PocketAddResponse {
    public var item: PocketItem
    public let status: Int
}

extension PocketAddResponse: Decodable {
    static func create(item: PocketItem)(status: Int) -> PocketAddResponse {
        return PocketAddResponse(item: item, status: status)
    }
    
    public static func decode(json: JSON) -> Decoded<PocketAddResponse> {
        return create
            <^> json <| "item"
            <*> json <| "status"
    }
}
