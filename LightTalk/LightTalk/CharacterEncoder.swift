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
    
    func setMessage(c: String) {
        message = c
    }
    
    func getBits() -> [UInt8]? {
        // gets bits for the first character
        if let message = message {
            let firstBitMask: UInt8 = 0b00000001
            var levels: [UInt8] = []
            for char in [UInt8](message.utf8) {
                var currentChar = char
                for _ in 0..<8 {
                    let firstBit = currentChar & firstBitMask
                    levels.insert(firstBit, atIndex: 0)
                    currentChar = currentChar >> 1
                }
            }
            return levels
        } else { return nil }
    }
    
    func getLevels() -> [Double] {
        return [0.0]
    }
    
}
