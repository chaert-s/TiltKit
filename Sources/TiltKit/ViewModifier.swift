//
//  File.swift
//  
//
//  Created by test on 11.10.23.
//

import Foundation
import SwiftUI

@available(iOS 13.0, *)
extension View {
    public func orientationRotation() -> some View {
        self.modifier(OrientationRotationModifier())
    }
}

@available(iOS 13.0.0, *)
struct OrientationRotationModifier: ViewModifier {
    func body(content: Content) -> some View {
        let radians = DeviceOrientationHelper.shared.radians
        return content.rotationEffect(.radians(radians))
    }
}
