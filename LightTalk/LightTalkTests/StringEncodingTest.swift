//
//  StringEncodingTest.swift
//  LightTalk
//
//  Created by Jean-Frederic Plante on 5/16/16.
//  Copyright © 2016 Jean Frederic Plante. All rights reserved.
//

import XCTest
@testable import LightTalk

class StringEncodingTest: XCTestCase {
    var encoder: CharacterEncoder = CharacterEncoder()

    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCharacterEncoding() {
        // default is 1 bit level
        encoder.setMessage("l")
        XCTAssertNotNil(encoder.getBits())
        XCTAssertEqual(encoder.getBits()!, [0,1,1,0,1,1,0,0] )
        encoder.setMessage(" ")
        XCTAssertEqual(encoder.getBits()!, [0,0,1,0,0,0,0,0] )

        // testing with 2 bits levels
        encoder.setEncodingLevels(2)
        encoder.setMessage(" ")
        XCTAssertEqual(encoder.getBits()!, [0,2,0,0] )

    }
    
    func testMessageValidation() {
        encoder.setMessage("U")
        XCTAssertEqual(encoder.getBits()!, [0,1,0,1,0,1,0,1] )
        XCTAssertEqual(encoder.getValidationBits(encoder.getBits()!), [0] )
        encoder.setMessage(" ")
        XCTAssertEqual(encoder.getBits()!, [0,0,1,0,0,0,0,0] )
        XCTAssertEqual(encoder.getValidationBits(encoder.getBits()!), [1] )
    }
    
    func testFramedMessage() {
        encoder.setMessage("U")
        XCTAssertEqual(encoder.getFramedMessage()!, [1,0,1,0,0,1,0,1,0,1,0,1,0] )
        encoder.setMessage(" ")
        XCTAssertEqual(encoder.getFramedMessage()!, [1,0,1,0,0,0,1,0,0,0,0,0,1] )
    }
    
    func testMessageBuffer() {
        let messageBuffer = MessageBuffer()
        XCTAssertEqual(messageBuffer.state, MessageState.Blank)
        encoder.setMessage("U")
        messageBuffer.levels = encoder.getFramedMessage()!
        XCTAssertEqual(messageBuffer.levels, [1,0,1,0,0,1,0,1,0,1,0,1,0] )
        var header  = messageBuffer.getMessagePart(.Header)
        XCTAssertNotNil(header)
        XCTAssertEqual(header!, [1,0,1,0] )
        var body  = messageBuffer.getMessagePart(.Body)
        XCTAssertEqual(body!, [0,1,0,1,0,1,0,1] )
        var crc  = messageBuffer.getMessagePart(.CRC)
        XCTAssertEqual(crc!, [0] )
        
        encoder.setMessage(" ")
        messageBuffer.levels = encoder.getFramedMessage()!

        XCTAssertEqual(messageBuffer.levels, [1,0,1,0,0,0,1,0,0,0,0,0,1] )
        header  = messageBuffer.getMessagePart(.Header)
        XCTAssertNotNil(header)
        XCTAssertEqual(header!, [1,0,1,0] )
        body  = messageBuffer.getMessagePart(.Body)
        XCTAssertEqual(body!, [0,0,1,0,0,0,0,0] )
        crc  = messageBuffer.getMessagePart(.CRC)
        XCTAssertEqual(crc!, [1] )
    }
    
    func testMessageBufferCRC() {
        let messageBuffer = MessageBuffer()
        messageBuffer.levels = [1,0,1,0,0,0,1,0,0,0,0,0,0]
        XCTAssertFalse(messageBuffer.crcValid)
        messageBuffer.levels = [1,0,1,0,0,0,1,0,0,0,0,0,1]
        XCTAssertTrue(messageBuffer.crcValid)

    }

  
}
