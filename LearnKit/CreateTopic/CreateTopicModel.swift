//
//  CreateTopicModel.swift
//  Learn
//
//  Created by Christopher Sullivan on 9/23/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import Foundation

public struct CreateTopicModel {
    public init() {}
    
    private let maxEmojiTextLength = 1
    private let emojiRanges = [
        0x0080...0x00FF,
        0x2100...0x214F,
        0x2190...0x21FF,
        0x2300...0x23FF,
        0x25A0...0x27BF,
        0x2900...0x297F,
        0x2B00...0x2BFF,
        0x3001...0x303F,
        0x3200...0x32FF,
        0x1F000...0x1F02F,
        0x1F110...0x1F251,
        0x1F300...0x1F5FF,
        0x1F600...0x1F64F,
        0x1F680...0x1F6FF
    ]
    
    public func isValidTopicName(name: String, andIcon icon: String) -> Bool {
        return isValidTopicName(name) && isValidEmojiValue(icon)
    }
    
    public func canChangeTopicIconToString(string: String) -> Bool {
        return string.lengthWithEmoji() == 0 || isValidEmojiValue(string)
    }
    
    public func isValidTopicName(name: String) -> Bool {
        return name.lengthWithEmoji() > 0
    }
    
    public func isValidEmojiValue(string: String) -> Bool {
        if string.lengthWithEmoji() == 0 || string.lengthWithEmoji() > maxEmojiTextLength {
            return false
        }
        
        if let scalarVal = string.unicodeScalars.first?.value {
            var found = false
            for range in emojiRanges {
                if range.contains(Int(scalarVal)) {
                    found = true
                }
            }
            if !found {
                return false
            }
        }
        
        return true
    }
}