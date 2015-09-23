//
//  PocketAPICredentialsKeychainManager.swift
//  Learn
//
//  Created by Christopher Sullivan on 9/22/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import Foundation

public struct PocketAPICredentialsKeychainManager: PocketAPICredentialsManager {
    public init() {}
    
    private let UserDefaultsAuthenticatedUserKey = "PocketAuthUser"
    
    public func getPocketAPICredentialsFromStore() -> PocketAPICredentials? {
        guard let defaults = NSUserDefaults(suiteName: "group.com.sullivan.j.chris.Learn") else {
            fatalError("Can't open user defaults")
        }
        
        if let authenticatedUser = defaults.objectForKey(UserDefaultsAuthenticatedUserKey) as? String {
            let credentialsForRetrieval = PocketAPICredentials(authenticatedUser: authenticatedUser, accessToken: "")
            let keychainEntry = PocketAPICredentialsKeychainEntry(credentials: credentialsForRetrieval)
            let result = keychainEntry.readFromSecureStore()
            if let data = result?.data, token = data["accessToken"] as? String {
                return PocketAPICredentials(authenticatedUser: authenticatedUser, accessToken: token)
            } else {
                return PocketAPICredentials(authenticatedUser: authenticatedUser, accessToken: "")
            }
        } else {
            return nil
        }
    }
    
    public func setPocketAPICredentials(credentials: PocketAPICredentials) {
        guard let defaults = NSUserDefaults(suiteName: "group.com.sullivan.j.chris.Learn") else {
            fatalError("Can't open user defaults")
        }
        defaults.setObject(credentials.authenticatedUser, forKey: UserDefaultsAuthenticatedUserKey)
        defaults.synchronize()
        
        let keychainEntry = PocketAPICredentialsKeychainEntry(credentials: credentials)
        do {
            try keychainEntry.deleteFromSecureStore()
        } catch {
            // This will fail if the credentials didn't already exist, ignore
        }
        
        do {
            try keychainEntry.createInSecureStore()
        } catch {
            print(error)
        }
    }
    
    public func clearPocketAPICredentials() {
        guard let defaults = NSUserDefaults(suiteName: "group.com.sullivan.j.chris.Learn") else {
            fatalError("Can't open user defaults")
        }
        let authenticatedUser = defaults.objectForKey(UserDefaultsAuthenticatedUserKey) as? String
        defaults.removeObjectForKey(UserDefaultsAuthenticatedUserKey)
        defaults.synchronize()
        
        guard let authenticatedUserString = authenticatedUser else {
            return
        }
        let credentials = PocketAPICredentials(authenticatedUser: authenticatedUserString, accessToken: "")
        let keychainEntry = PocketAPICredentialsKeychainEntry(credentials: credentials)
        do {
            try keychainEntry.deleteFromSecureStore()
        } catch {
            print(error)
        }
    }
}
