//
//  PocketAuthenticationDelegate.swift
//  Learn
//
//  Created by Christopher Sullivan on 9/16/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

public protocol PocketAuthenticationDelegate {
    func promptOAuthUserAuthWithPocketAppURL(pocketAppURL: NSURL, orWebURL webURL: NSURL)
}
