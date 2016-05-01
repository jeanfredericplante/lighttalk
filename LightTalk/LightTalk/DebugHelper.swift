//
//  DebugHelper.swift
//  LightTalk
//
//  Created by Jean Frederic Plante on 5/1/16.
//  Copyright © 2016 Jean Frederic Plante. All rights reserved.
//

import Foundation

struct Constants {
    static let debugTraces: Bool = true
}

func printDebug(message: String, withTime: Bool = false) {
    let message = "DEBUG: \(message)"
    if Constants.debugTraces {
        if withTime {
            NSLog(message)
        } else {
            print(message)
        }
    }
}
    