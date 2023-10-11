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
    @State private var radians: Double = 0.0

    init() {
        _radians = State(initialValue: DeviceOrientationHelper.shared.radians)
    }

    func body(content: Content) -> some View {
        content
            .rotationEffect(.radians(radians))
            .onReceive(DeviceOrientationHelper.shared.$radians) { newRadians in
                self.radians = newRadians
            }
    }
}
