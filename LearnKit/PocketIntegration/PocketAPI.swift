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

public class PocketAPI {
    private var consumerKey: String?
    private var appId: String?
    private var requestToken: String?
    
    private var onAuthenticationCompletion: (() -> ())?
    
    private let delegate: PocketAuthenticationDelegate
    private let credentialsManager: PocketAPICredentialsManager
    
    private var accessToken: String?
    private var authenticatedUser: String?
    
    public init(delegate: PocketAuthenticationDelegate, andCredentialsManager credentialsManager: PocketAPICredentialsManager) {
        self.delegate = delegate
        self.credentialsManager = credentialsManager
        
        if let credentials = credentialsManager.getPocketAPICredentialsFromStore() {
            setAuthenticated(credentials)
        }

        guard let bundle = NSBundle(identifier: "com.sullivan.j.chris.LearnKit"),
            path = bundle.pathForResource("Keys", ofType: "plist"),
            pocketKeys = NSDictionary(contentsOfFile: path) else {
                return
        }
        self.appId = pocketKeys["PocketAppId"] as? String
        self.consumerKey = pocketKeys["PocketConsumerKey"] as? String
    }
    
    public func getAuthenticatedUserString() -> String? {
        return authenticatedUser
    }
    
    public func addURLToPocket(url: NSURL, completion: (PocketItem) -> ()) {
        authenticateAndMakeRequest(.POST, urlAsString: "https://getpocket.com/v3/add", params: ["url": url.description]) {
            result in
            switch result {
            case .Success(let JSON):
                let decodedResponse: Decoded<PocketAddResponse> = decode(JSON)
                switch decodedResponse {
                case .Success(let responseObj):
                    completion(responseObj.item)
                case .Failure(let error):
                    if case .TypeMismatch = error {
                        // The Pocket API's add URL response normally returns an "item" with a key "images"
                        // which is an object of key -> image object, however when there are no images, it incorrectly
                        // assigns "images" an empty array instead of an empty object, so rebuild the JSON without the "images"
                        // key and try parsing the PocketItem again
                        if let j = JSON as? [String: AnyObject] {
                            if let item = j["item"] as? [String: AnyObject] {
                                var modifiedJSON = [String: AnyObject]()
                                for (key, val) in item {
                                    if key == "images" {
                                        continue
                                    }
                                    modifiedJSON[key] = val
                                }
                                let decodedModifiedPocketItem: Decoded<PocketItem> = decode(modifiedJSON)
                                switch decodedModifiedPocketItem {
                                case .Success(let pocketItem):
                                    completion(pocketItem)
                                case .Failure(let error):
                                    print(error)
                                }
                            }
                        }
                    }
                }
            case .Failure(let data, let error):
                print("Request failed with error: \(error)")
                if let data = data {
                    print("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                }
            }
        }
    }
    
    public func getPocketItemsWithCount(count: Int, andOffset offset: Int, completion: ([PocketItem]) -> ()) {
        authenticateAndMakeRequest(.POST, urlAsString: "https://getpocket.com/v3/get", params: ["count": "\(count)", "offset": "\(offset)", "sort": "newest", "detailType": "complete"]) {
            result in
            switch result {
            case .Success(let JSON):
                let decodedResponse: Decoded<PocketRetrieveResponse> = decode(JSON)
                switch decodedResponse {
                case .Success(let responseObj):
                    completion(Array(responseObj.list.values))
                case .Failure(let error):
                    print(error)
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
    
    private func setAuthenticated(credentials: PocketAPICredentials) {
        credentialsManager.setPocketAPICredentials(credentials)
        self.accessToken = credentials.accessToken
        self.authenticatedUser = credentials.authenticatedUser
    }
    
    private func clearAuthentication() {
        credentialsManager.clearPocketAPICredentials()
        self.accessToken = nil
        self.authenticatedUser = nil
    }
    
    public func authenticate(completion: (() -> ())?) {
        guard let consumerKey = consumerKey, appId = appId else {
            return
        }
        let oAuthRequestParams = ["consumer_key": consumerKey, "redirect_uri": "pocketapp\(appId):authorizationFinished"]
        
        onAuthenticationCompletion = completion
        
        Alamofire.request(.POST, "https://getpocket.com/v3/oauth/request", parameters: oAuthRequestParams, encoding: .JSON, headers: ["X-Accept": "application/json"])
        .responseJSON { (_, _, result) -> Void in
            switch result {
            case .Success(let JSON):
                self.handleOAuthRequestSuccess(JSON)
            case .Failure(let data, let error):
                self.onAuthenticationCompletion = nil
                print("Request failed with error: \(error)")
                if let data = data {
                    print("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                }
            }
        }
    }
    
    public func oAuthCallbackReceived() {
        guard let consumerKey = consumerKey, requestToken = requestToken else {
            return
        }
        let userAuthRequestParams = ["consumer_key": consumerKey, "code": requestToken]
        
        Alamofire.request(.POST, "https://getpocket.com/v3/oauth/authorize", parameters: userAuthRequestParams, encoding: .JSON, headers: ["X-Accept": "application/json"])
            .responseJSON { (_, _, result) -> Void in
                switch result {
                case .Success(let JSON):
                    self.handleOAuthAuthorizeSuccess(JSON)
                case .Failure(let data, let error):
                    self.onAuthenticationCompletion = nil
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
            guard let requestToken = self.requestToken,
                appId = self.appId,
                URL = NSURL(string: "pocket-oauth-v1:///authorize?request_token=\(requestToken)&redirect_uri=pocketapp\(appId):authorizationFinished") else {
                    fatalError("Bad URL for pocket oauth")
            }
            delegate.promptOAuthUserAuthWithURL(URL)
        case .Failure(let error):
            self.onAuthenticationCompletion = nil
            print(error)
        }
    }
    
    private func handleOAuthAuthorizeSuccess(JSON: AnyObject) {
        let decodedResponse: Decoded<PocketUserAuthResponse> = decode(JSON)
        
        switch decodedResponse {
        case .Success(let responseObj):
            let credentials = PocketAPICredentials(authenticatedUser: responseObj.username, accessToken: responseObj.access_token)
            setAuthenticated(credentials)
            onAuthenticationCompletion?()
            onAuthenticationCompletion = nil
        case .Failure(let error):
            onAuthenticationCompletion = nil
            print(error)
        }
    }

    private func authenticateAndMakeRequest(method: Alamofire.Method, urlAsString: String, params: [String: String]?, completion: (Result<AnyObject>) -> ()) {
        if isAuthenticated() {
            makeRequest(method, urlAsString: urlAsString, params: params, completion: completion)
        } else {
            authenticate {
                [unowned self] in
                self.makeRequest(method, urlAsString: urlAsString, params: params, authAttempted: true, completion: completion)
            }
        }
    }
    
    private func makeRequest(method: Alamofire.Method, urlAsString: String, params: [String: String]?, authAttempted: Bool = false, completion: (Result<AnyObject>) -> ()) {
        guard let consumerKey = consumerKey, accessToken = accessToken else {
            return
        }
        
        var newParams = params ?? [String: String]()
        newParams["consumer_key"] = consumerKey
        newParams["access_token"] = accessToken

        Alamofire.request(method, urlAsString, parameters: newParams, encoding: .JSON, headers: ["X-Accept": "application/json"]).responseJSON { (_, response, result) -> Void in
            if let statusCode = response?.statusCode where statusCode == 401 && !authAttempted {
                // existing credentials are incorrect, clear them and re-authenticate
                self.clearAuthentication()
                self.authenticateAndMakeRequest(method, urlAsString: urlAsString, params: params, completion: completion)
            } else {
                completion(result)
            }
        }
    }
}
