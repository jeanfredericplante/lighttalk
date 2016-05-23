//
//  CharacterEncoder.swift
//  LightTalk
//
//  Created by Jean Frederic Plante on 5/15/16.
//  Copyright © 2016 Jean Frederic Plante. All rights reserved.
//
// message: [header][length][message][validation]
// message: [1010][xx][message][x]


import Foundation

class CharacterEncoder {
    
    struct Constants {
        static let messageHeader: [UInt8] = [1,0,1,0]
        static let messageLengthInBytes: [UInt8] = [0,1]
    }
    
    private var message : String?
    private var bytesInMessage: UInt8 {
        get { return 2*Constants.messageLengthInBytes[0] + Constants.messageLengthInBytes[1] }
    }
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
    
    let messageHeader = Constants.messageHeader + Constants.messageLengthInBytes
    func setMessage(c: String) {
        message = c
    }
    
    func setEncodingLevels(levels: UInt8) {
        encodingLevels = max(min(levels,2),1)
    }
    

    func getValidationBits(message: [UInt8]) -> [UInt8] {
        var crc: UInt8 = 0
        for b in message {
            crc = crc ^ b
        }
        return [crc]
    }
    
    
    func getBits() -> [UInt8]? {
        if let message = message {
            var levels: [UInt8] = []
            for char in [UInt8](message.utf8) {
                levels = getCharBits(char) + levels
            }
            return levels
        } else { return nil }
    }
    
    func getCharBits(char: UInt8) -> [UInt8] {
        var levels: [UInt8] = []
        var currentChar = char
        for _ in 0..<8/encodingLevels {
            let firstBit = currentChar & firstBitMask
            levels.insert(firstBit, atIndex: 0)
            currentChar = currentChar >> encodingLevels
        }
        return levels
    }

    func getFramedMessage() -> [UInt8]? {
        if let message = message {
            var framedMessage: [UInt8] = []

            for char in [UInt8](message.utf8) {
                let charBits = getCharBits(char)
                let validation = getValidationBits(charBits)
                framedMessage = framedMessage + messageHeader + charBits + validation
            }
            return framedMessage
        } else {
            return nil
        }
    }
    
    func getLevels() -> [Double] {
        return [0.0]
    }
    
}
