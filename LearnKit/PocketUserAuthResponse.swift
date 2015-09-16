//
//  PocketUserAuthResponse.swift
//  Learn
//
//  Created by Christopher Sullivan on 9/16/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import Argo

struct PocketUserAuthResponse {
    let access_token: String
    let username: String
}

extension PocketUserAuthResponse: Decodable {
    static func create(access_token: String)(username: String) -> PocketUserAuthResponse {
        return PocketUserAuthResponse(access_token: access_token, username: username)
    }
    
    static func decode(json: JSON) -> Decoded<PocketUserAuthResponse> {
        return create
            <^> json <| "access_token"
            <*> json <| "username"
    }
}
