//
//  TimeIntervalExtensions.swift
//  Tatsi
//
//  Created by Maciek on 10/03/2020.
//  Copyright © 2020 awkward. All rights reserved.
//

import Foundation

public extension TimeInterval {
    var asString: String {
        let defaultResult = "0:00"
        
        guard self > 0 else {
            return defaultResult
        }
        let ti = NSInteger(self)
        
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        
        if hours > 0 {
            return String(format: "%0.1d:%0.2d:%0.2d", hours, minutes, seconds)
        } else {
            return String(format: "%0.1d:%0.2d", minutes, seconds)
        }
    }
}
