//
//  LearnKitTests.swift
//  LearnKitTests
//
//  Created by Christopher Sullivan on 8/24/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import XCTest
@testable import LearnKit

class LearnKitTests: XCTestCase {
    
    let createTopicModel = CreateTopicModel()
    
    func testBlankTopicNameInvalid() {
        XCTAssertFalse(createTopicModel.isValidTopicName(""))
    }
    
    func testTopicNameWithCharsValid() {
        XCTAssertTrue(createTopicModel.isValidTopicName("Topic"))
    }
    
    func testCanChangeTopicIconToBlankString() {
        XCTAssertTrue(createTopicModel.canChangeTopicIconToString(""))
    }
    
    func testCanChangeTopicIconToValidEmoji() {
        XCTAssertTrue(createTopicModel.canChangeTopicIconToString("👨🏻"))
    }
    
    func test👨🏻ValidEmoji() {
        XCTAssertTrue(createTopicModel.isValidEmojiValue("👨🏻"))
    }
    
    func test🌄ValidEmoji() {
        XCTAssertTrue(createTopicModel.isValidEmojiValue("🌄"))
    }
    
    func test📢ValidEmoji() {
        XCTAssertTrue(createTopicModel.isValidEmojiValue("📢"))
    }
    
    func test🅿️ValidEmoji() {
        XCTAssertTrue(createTopicModel.isValidEmojiValue("🅿️"))
    }
    
    func testBlankStringInvalidEmoji() {
        XCTAssertFalse(createTopicModel.isValidEmojiValue(""))
    }
    func test😐😐InvalidEmoji() {
        XCTAssertFalse(createTopicModel.isValidEmojiValue("😐😐"))
    }
    
    func test😐DotInvalidEmoji() {
        XCTAssertFalse(createTopicModel.isValidEmojiValue("😐."))
    }
    
    func testAInvalidEmoji() {
        XCTAssertFalse(createTopicModel.isValidEmojiValue("A"))
    }
    
    func test9InvalidEmoji() {
        XCTAssertFalse(createTopicModel.isValidEmojiValue("9"))
    }
    
    func testSlashInvalidEmoji() {
        XCTAssertFalse(createTopicModel.isValidEmojiValue("/"))
    }
}
