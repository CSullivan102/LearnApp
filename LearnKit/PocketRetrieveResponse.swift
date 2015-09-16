//
//  PocketRetrieveResponse.swift
//  Learn
//
//  Created by Christopher Sullivan on 9/16/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import Argo

public struct PocketRetrieveResponse {
    public let status: Int
    public let list: [String: PocketItem]
}

extension PocketRetrieveResponse: Decodable {
    static func create(status: Int)(list: [String: PocketItem]) -> PocketRetrieveResponse {
        return PocketRetrieveResponse(status: status, list: list)
    }
    
    public static func decode(json: JSON) -> Decoded<PocketRetrieveResponse> {
        return create
            <^> json <| "status"
            <*> json <|~ "list"
    }
}
