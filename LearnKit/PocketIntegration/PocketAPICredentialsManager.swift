//
//  PocketAPICredentialsManager.swift
//  Learn
//
//  Created by Christopher Sullivan on 9/22/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import Foundation

public protocol PocketAPICredentialsManager {
    func getPocketAPICredentialsFromStore() -> PocketAPICredentials?
    func setPocketAPICredentials(credentials: PocketAPICredentials)
    func clearPocketAPICredentials()
}