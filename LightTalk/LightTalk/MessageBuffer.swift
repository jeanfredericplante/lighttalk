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
    case Blank, Detected, Header, Body, Complete
}

class MessageBuffer {
    var levels: [UInt8] = []
    var time: [CMTime] = []
    var state: MessageState = .Blank
    let header = CharacterEncoder.Constants.messageHeader
    
    func addTransition(slope: Slope, time: CMTime) {
        switch state {
        case .Blank:
            if slope == .Up {
                state = .Detected
                levels.append(1)
                self.time.append(time)
            }
        case .Detected:
            break
        case .Header:
            break
        case .Complete:
            break
        default:
            break
        }
    }
    
    func slopeToLevel(slope: Slope) -> UInt8? {
        if let lastLevel = levels.last {
            switch lastLevel {
            case 0:
                if slope == .Up {
                    return 1
                } else {
                    return 0
                }
            case 1:
                if slope == .Down {
                    return 0
                } else {
                    return 1
                }
            default:
                return nil
            }
        } else {
            return nil
        }
    }
    
    
}
