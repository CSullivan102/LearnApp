//
//  PocketAPI.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/20/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Argo
//import KeychainAccess

public protocol PocketAuthenticationDelegate {
    func promptOAuthUserAuthWithURL(URL: NSURL)
}

public class PocketAPI {
    private var consumerKey: String?
    private var appId: String?
    private var requestToken: String?
//    private let keychain: Keychain
    private let delegate: PocketAuthenticationDelegate
    private let AccessTokenKeychainKey = "PocketAccessToken"
    private let AuthUserKeychainKey = "PocketAuthUser"
    
    private var accessToken: String? {
        get {
            guard let defaults = NSUserDefaults(suiteName: "group.com.sullivan.j.chris.Learn")
                else { fatalError("Can't open user defaults") }
            let plist: AnyObject? = defaults.objectForKey(AccessTokenKeychainKey)
            return plist as? String
            // return keychain.getStringIfExists(AccessTokenKeychainKey)
        }
        set {
            guard let defaults = NSUserDefaults(suiteName: "group.com.sullivan.j.chris.Learn")
                else { fatalError("Can't open user defaults") }
            defaults.setObject(newValue, forKey: AccessTokenKeychainKey)
            defaults.synchronize()
            // keychain.setOrRemoveStringValue(newValue, forKey: AccessTokenKeychainKey)
        }
    }

    private var authenticatedUser: String? {
        get {
            guard let defaults = NSUserDefaults(suiteName: "group.com.sullivan.j.chris.Learn")
                else { fatalError("Can't open user defaults") }
            let plist: AnyObject? = defaults.objectForKey(AuthUserKeychainKey)
            return plist as? String
            // return keychain.getStringIfExists(AuthUserKeychainKey)
        }
        set {
            guard let defaults = NSUserDefaults(suiteName: "group.com.sullivan.j.chris.Learn")
                else { fatalError("Can't open user defaults") }
            defaults.setObject(newValue, forKey: AuthUserKeychainKey)
            defaults.synchronize()
            // keychain.setOrRemoveStringValue(newValue, forKey: AuthUserKeychainKey)
        }
    }
    
    public init(delegate: PocketAuthenticationDelegate) {
        guard let bundle = NSBundle(identifier: "com.sullivan.j.chris.LearnKit"),
            path = bundle.pathForResource("Keys", ofType: "plist"),
            pocketKeys = NSDictionary(contentsOfFile: path)
        else { fatalError("Could not find Keys.plist in bundle") }
        self.appId = pocketKeys["PocketAppId"] as? String
        self.consumerKey = pocketKeys["PocketConsumerKey"] as? String
        
        self.delegate = delegate
        
        // let appIdPrefix = NSBundle.mainBundle().objectForInfoDictionaryKey("AppIdentifierPrefix") as! String
        // keychain = Keychain(service: "com.sullivan.j.chris.Learn", accessGroup: "\(appIdPrefix)com.sullivan.j.chris.Learn")
    }
    
    public func addURLToPocket(url: NSURL, completion: (PocketItem) -> ()) {
        authenticateAndMakeRequest(.POST, urlAsString: "https://getpocket.com/v3/add", params: ["url": url.description]) { (result) -> () in
            switch result {
            case .Success(let JSON):
                let decodedResponse: Decoded<PocketAddResponse> = decode(JSON)
                
                switch decodedResponse {
                case .Success(let responseObj):
                    completion(responseObj.item)
                case .MissingKey(let s):
                    print("JSON decoding failed for Add to Pocket, missing key \(s)")
                case .TypeMismatch(let s):
                    print("JSON decoding failed for Add to Pocket, type mismatch \(s)")
                }
            case .Failure(let data, let error):
                print("Request failed with error: \(error)")
                if let data = data {
                    print("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                }
            }
        }
    }
    
    public func isAuthenticated() -> Bool {
        if accessToken != nil {
            return true
        }
        return false
    }
    
    public func authenticate(completion: (() -> ())?) {
        // Need to set up a closure on this object, something to come back to
        
        guard let consumerKey = consumerKey, appId = appId
        else { return }
        let oAuthRequestParams = ["consumer_key": consumerKey, "redirect_uri": "pocketapp\(appId):authorizationFinished"]
        
        Alamofire.request(.POST, "https://getpocket.com/v3/oauth/request", parameters: oAuthRequestParams, encoding: .JSON, headers: ["X-Accept": "application/json"])
        .responseJSON { (_, _, result) -> Void in
            switch result {
            case .Success(let JSON):
                self.handleOAuthRequestSuccess(JSON)
            case .Failure(let data, let error):
                print("Request failed with error: \(error)")
                if let data = data {
                    print("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                }
            }
        }
    }
    
    public func oAuthCallbackReceived() {
        guard let consumerKey = consumerKey, requestToken = requestToken
            else { return }
        let userAuthRequestParams = ["consumer_key": consumerKey, "code": requestToken]
        
        Alamofire.request(.POST, "https://getpocket.com/v3/oauth/authorize", parameters: userAuthRequestParams, encoding: .JSON, headers: ["X-Accept": "application/json"])
            .responseJSON { (_, _, result) -> Void in
                switch result {
                case .Success(let JSON):
                    self.handleOAuthAuthorizeSuccess(JSON)
                case .Failure(let data, let error):
                    print("Request failed with error: \(error)")
                    if let data = data {
                        print("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                    }
                }
        }
    }
    
    private func handleOAuthRequestSuccess(JSON: AnyObject) {
        let decodedResponse: Decoded<PocketOAuthResponse> = decode(JSON)
        switch decodedResponse {
        case .Success(let responseObj):
            self.requestToken = responseObj.code
            guard let requestToken = self.requestToken, appId = self.appId, URL = NSURL(string: "pocket-oauth-v1:///authorize?request_token=\(requestToken)&redirect_uri=pocketapp\(appId):authorizationFinished")
            else { fatalError("Bad URL for pocket oauth") }
            delegate.promptOAuthUserAuthWithURL(URL)
        case .MissingKey(let s):
            print("JSON decoding failed for OAuth Request, missing key \(s)")
        case .TypeMismatch(let s):
            print("JSON decoding failed for OAuth Request, type mismatch \(s)")
        }
    }
    
    private func handleOAuthAuthorizeSuccess(JSON: AnyObject) {
        let decodedResponse: Decoded<PocketUserAuthResponse> = decode(JSON)
        
        switch decodedResponse {
        case .Success(let responseObj):
            self.accessToken = responseObj.access_token
            self.authenticatedUser = responseObj.username
            // Need to have a closure available with the original request in it here
        case .MissingKey(let s):
            print("JSON decoding failed for OAuth Authorize, missing key \(s)")
        case .TypeMismatch(let s):
            print("JSON decoding failed for OAuth Authorize, type mismatch \(s)")
        }
    }

    private func authenticateAndMakeRequest(method: Alamofire.Method, urlAsString: String, params: [String: String]?, completion: (Result<AnyObject>) -> ()) {
        if isAuthenticated() {
            makeRequest(method, urlAsString: urlAsString, params: params, completion: completion)
        } else {
            authenticate {
                self.makeRequest(method, urlAsString: urlAsString, params: params, completion: completion)
            }
        }
    }
    
    private func makeRequest(method: Alamofire.Method, urlAsString: String, params: [String: String]?, completion: (Result<AnyObject>) -> ()) {
        guard let consumerKey = consumerKey, accessToken = accessToken
        else { return }
        
        var newParams = params ?? [String: String]()
        newParams["consumer_key"] = consumerKey
        newParams["access_token"] = accessToken
        
        Alamofire.request(method, urlAsString, parameters: newParams, encoding: .JSON, headers: ["X-Accept": "application/json"]).responseJSON { (_, _, result) -> Void in
            completion(result)
        }
    }
}

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

public struct PocketAddResponse {
    public let item: PocketItem
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

public struct PocketItem {
    public let item_id: String
}

extension PocketItem: Decodable {
    static func create(item_id: String) -> PocketItem {
        return PocketItem(item_id: item_id)
    }
    
    public static func decode(json: JSON) -> Decoded<PocketItem> {
        return create
            <^> json <| "item_id"
    }
}
