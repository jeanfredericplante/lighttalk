//
//  ImageProcessingTests.swift
//  LightTalk
//
//  Created by Jean Frederic Plante on 5/28/16.
//  Copyright © 2016 Jean Frederic Plante. All rights reserved.
//

import XCTest
@testable import LightTalk

class ImageProcessingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testLightnessCalculation() {
        let flash = UIImage(named: "flash")!
        let noflash = UIImage(named: "no_flash")!
        let flashBrightness = flash.averageBrightness
        let noFlashBrightness = noflash.averageBrightness
        XCTAssertNotNil(flashBrightness)
        XCTAssertNotNil(noFlashBrightness)
        XCTAssertLessThan(noFlashBrightness!, flashBrightness!)
        XCTAssertLessThanOrEqual(noFlashBrightness!, 255)
        XCTAssertLessThanOrEqual(0, noFlashBrightness!)
        XCTAssertLessThanOrEqual(flashBrightness!, 255)
        XCTAssertLessThanOrEqual(0, flashBrightness!)
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
