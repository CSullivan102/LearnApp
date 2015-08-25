//
//  KeychainAccess+LearnAdditions.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/24/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import Foundation
import KeychainAccess

extension Keychain {
    func getStringIfExists(key: String) -> String? {
        let result = getStringOrError(key)
        switch result {
        case .Success:
            return result.value
        case .Failure(let e):
            print("keychain error: \(e)")
            return nil
        }
    }
    
    func setOrRemoveStringValue(value: String?, forKey key: String) {
        if let val = value {
            if let error = set(val, key: key) {
                print("keychain error: \(error)")
            }
        } else {
            if let error = remove(key) {
                print("keychain error: \(error)")
            }
        }
    }
}