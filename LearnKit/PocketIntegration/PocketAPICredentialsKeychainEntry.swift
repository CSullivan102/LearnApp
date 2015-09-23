//
//  PocketAPICredentialsKeychainEntry.swift
//  Learn
//
//  Created by Christopher Sullivan on 9/22/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import Foundation
import Locksmith

struct PocketAPICredentialsKeychainEntry: CreateableSecureStorable, ReadableSecureStorable, DeleteableSecureStorable, GenericPasswordSecureStorable {
    let credentials: PocketAPICredentials
    
    let service = "Pocket"
    var account: String { return credentials.authenticatedUser }
    var data: [String: AnyObject] { return ["accessToken": credentials.accessToken] }
}