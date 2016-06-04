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
    case Blank, Header(Int), Length(Int), Body(Int), CRC(Int), Complete, Invalid
}
enum MessagePart {
    case Header, Body, CRC
}

class MessageBuffer {
    var levels: [UInt8] = []
    var time: [CMTime] = []
    var state: MessageState = .Blank
    let header = CharacterEncoder.Constants.messageHeader

    let crcLength = CharacterEncoder.Constants.crcLength
    let bytesInMessage = CharacterEncoder.Constants.bytesInMessage
    var headerValid : Bool {
        return Array(levels[0...3]) == header
    }
    var crcValid : Bool {
        return true
    }
    func getMessagePart(part: MessagePart) -> [UInt8]? {
        let headerLength = header.count
        let messageLength = headerLength + (8 * bytesInMessage) + crcLength
        guard levels.count > messageLength else {
            return nil
        }
        switch part {
        case .Header:
            return levels[0..<headerLength]
            if levels.count > headerLength {
                
            }
        default:
            break
        }
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
                    state = .Body(1); addMessageBit(level, time: time)
                } else {
                    return resetMessage()
                }
            }
        case .Body(let bitNum):
            guard let level = slopeToLevel(slope) else { return resetMessage() }
            if bitNum < 8 * bytesInMessage {
                state = .Body(bitNum + 1); addMessageBit(level, time: time)
            } else {
                // all bits in, moving to CRC
                state = .CRC(1); addMessageBit(level, time: time)
            }
        case .CRC(let bitNum):
            guard let level = slopeToLevel(slope) else { return resetMessage() }
            if bitNum < Int(crcLength) {
                state = .CRC(bitNum + 1); addMessageBit(level, time: time)
            } else {
                // crc is in
                if headerValid {
                    state = .Body(1); addMessageBit(level, time: time)
                } else {
                    return resetMessage()
                }
            }

            break
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
