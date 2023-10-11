//
//  File.swift
//  
//
//  Created by test on 11.10.23.
//

import Foundation
import SwiftUI

//If resource efficiency isn' your main concern, you can also use a viewmodifier with a shared instance of the DeviceOrientationHelper. It will only be de-init if no .orientationRotation modifiers are present in the current view

@available(iOS 14.0, *)
extension View {
    public func rotation(_ rotationMode: rotationModes = .normal) -> some View {
        self.modifier(OrientationRotationModifier(rotationMode: rotationMode))
    }
}

@available(iOS 14.0, *)
struct OrientationRotationModifier: ViewModifier {
    @ObservedObject var orientationHelper = DeviceOrientationHelper.shared()
    var rotationMode: rotationModes

    func body(content: Content) -> some View {
        let radians: Double

        switch rotationMode {
        case .normal:
            radians = orientationHelper.deviceRotationRadians
        case .constant:
            radians = orientationHelper.constantRotationRadians
        }

        return content.rotationEffect(.radians(radians))
    }
}




