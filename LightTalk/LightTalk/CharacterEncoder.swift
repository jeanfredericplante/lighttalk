//
//  CharacterEncoder.swift
//  LightTalk
//
//  Created by Jean Frederic Plante on 5/15/16.
//  Copyright © 2016 Jean Frederic Plante. All rights reserved.
//

import Foundation

class CharacterEncoder {
    private var message : String?
    private var firstBitMask: UInt8 =  0b00000001
    private var encodingLevels: UInt8 = 1 {
        didSet {
            if encodingLevels == 2 {
                firstBitMask =  0b00000011
            } else {
                firstBitMask =  0b00000001
            }
        }
    }
    
    func setMessage(c: String) {
        message = c
    }
    
    func setEncodingLevels(levels: UInt8) {
        encodingLevels = max(min(levels,2),1)
    }
    
    
    func getBits() -> [UInt8]? {
        // gets bits for the first character
        if let message = message {
            var levels: [UInt8] = []
            for char in [UInt8](message.utf8) {
                var currentChar = char
                for _ in 0..<8/encodingLevels {
                    let firstBit = currentChar & firstBitMask
                    levels.insert(firstBit, atIndex: 0)
                    currentChar = currentChar >> encodingLevels
                }
            }
            return levels
        } else { return nil }
    }
    
    func getLevels() -> [Double] {
        return [0.0]
    }
    
}
