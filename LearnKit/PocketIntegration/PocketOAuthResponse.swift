//
//  PocketOAuthResponse.swift
//  Learn
//
//  Created by Christopher Sullivan on 9/16/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import Argo

struct PocketOAuthResponse {
    let code: String
    
    static func create(code: String) -> PocketOAuthResponse {
        return PocketOAuthResponse(code: code)
    }
}

extension PocketOAuthResponse: Decodable {
    static func decode(json: JSON) -> Decoded<PocketOAuthResponse> {
        return create
            <^> json <| "code"
    }
}
