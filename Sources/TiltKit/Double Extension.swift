//
//  Double Extension.swift
//
//
//  Created by test on 10.10.23.
//

import Foundation

extension Double {
    // Convert degrees to radians
    public func toRadians() -> Double {
        return self * .pi / 180.0
    }

    // Convert radians to degrees
    public func toDegrees() -> Double {
        return self * 180.0 / .pi
    }
}
