//
//  String+EmojiStringLength.swift
//  Learn
//
//  Created by Christopher Sullivan on 9/16/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

extension String {
    func lengthWithEmoji() -> Int {
        let range = Range<String.Index>(start: self.startIndex, end: self.endIndex)
        var length = 0
        self.enumerateSubstringsInRange(range, options: .ByComposedCharacterSequences) { (substring, substringRange, enclosingRange, stop) -> () in
            length++
        }
        return length
    }
}