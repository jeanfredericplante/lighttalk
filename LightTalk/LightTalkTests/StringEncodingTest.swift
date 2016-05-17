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
        encoder.setMessage("l")
        XCTAssertNotNil(encoder.getBits())
        XCTAssertEqual(encoder.getBits()!, [0,1,1,0,1,1,0,0] )
        
    }

  
}
