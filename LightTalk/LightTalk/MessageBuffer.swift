//
//  MessageBuffer.swift
//  LightTalk
//
//  Created by Jean Frederic Plante on 5/30/16.
//  Copyright © 2016 Jean Frederic Plante. All rights reserved.
//

import Foundation
import CoreMedia

enum MessageState {
    case Blank, Header(Int), Length(Int), Body(Int), CRC(Int), Complete
}

class MessageBuffer {
    var levels: [UInt8] = []
    var time: [CMTime] = []
    var state: MessageState = .Blank
    let header = CharacterEncoder.Constants.messageHeader
    let crcLength = CharacterEncoder.Constants.crcLength
    let bytesInMessage = CharacterEncoder.Constants.messageLengthInBytes
    var headerValid : Bool {
        return Array(levels[0...3]) == header
    }
    var messageLength: UInt8? {
        guard levels.count >= 6 else {
            return nil
        }
        let length = levels[4]*2 + levels[5]
        if length < 1 || length > 3 { return nil }
        return length
    }
    
    func addTransition(slope: Slope, time: CMTime) -> MessageState {
        switch state {
        case .Blank:
            if slope == .Up {
                state = .Header(1)
                addMessageBit(1, time: time)
            }
        case .Header(let bitNum):
            guard let level = slopeToLevel(slope) else { return resetMessage() }
            if bitNum < header.count {
                state = .Header(bitNum + 1); addMessageBit(level, time: time)
            } else {
                if headerValid {
                    state = .Length(1); addMessageBit(level, time: time)
                } else {
                    return resetMessage()
                }
            }
        case .Length(let bitNum):
            guard let level = slopeToLevel(slope) else { return resetMessage() }
            if bitNum < 2 {
                state = .Length(bitNum + 1); addMessageBit(level, time: time)
            } else {
                guard let messageLength = messageLength else {
                     return resetMessage()
                }
                state = .Body(1); addMessageBit(level, time: time)
            }
        case .Body(let bitNum):
            guard let level = slopeToLevel(slope), messageLength = messageLength else { return resetMessage() }
            if bitNum < 8 * Int(messageLength) {
                state = .Body(bitNum + 1); addMessageBit(level, time: time)
            } else {
                // all bits in, moving to CRC
                state = .CRC(1); addMessageBit(level, time: time)
            }
        case .CRC(let bitNum):

        case .Complete:
            break
        default:
            break
        }
        return state
    }
    
    func addMessageBit(level: UInt8, time: CMTime) {
        levels.append(level)
        self.time.append(time)
    }
    
    func slopeToLevel(slope: Slope) -> UInt8? {
        guard let lastLevel = levels.last else {
            return nil
        }
        
        switch lastLevel {
        case 0:
            return slope == .Up ?  1 : 0
        case 1:
            return slope == .Down ?  0 : 1
        default:
            return nil
        }
    }
    
    func resetMessage() -> MessageState {
        state = .Blank; levels = []; time = []
        return state
    }
    
    
}
