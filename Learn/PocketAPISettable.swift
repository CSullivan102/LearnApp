//
//  APISettable.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/20/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import Foundation

public protocol PocketAPISettable: class {
    var pocketAPI: PocketAPI! { get set }
}
