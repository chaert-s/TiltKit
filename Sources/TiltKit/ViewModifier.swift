//
//  File.swift
//  
//
//  Created by test on 11.10.23.
//

import Foundation
import SwiftUI

@available(iOS 14.0, *)
extension View {
    public func orientationRotation() -> some View {
        self.modifier(OrientationRotationModifier())
    }
}

@available(iOS 14.0.0, *)
struct OrientationRotationModifier: ViewModifier {
    func body(content: Content) -> some View {
        @StateObject var rotation = DeviceOrientationHelper.shared
        return content.rotationEffect(.radians(rotation.radians))
    }
}
