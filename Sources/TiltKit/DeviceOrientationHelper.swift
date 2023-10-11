//
//  DeviceOrientationHelper.swift
//  
//
//  Created by test on 10.10.23.
//

import Foundation
import CoreMotion
import UIKit
import SwiftUI

@available(iOS 13.0, *)
@MainActor
public class DeviceOrientationHelper: ObservableObject {
    public static var sharedHelper = DeviceOrientationHelper()
    
    public class func shared() -> DeviceOrientationHelper { // Singleton is recommended because an app should create only a single instance of the CMMotionManager class.
        sharedHelper.startDeviceOrientationNotifier { deviceOrientation in
            //print("did this")
        }
        return self.sharedHelper
    }
    
    @Published public var deviceRotationDegrees: Double = 0.0
    @Published public var deviceRotationRadians: Double = 0.0
    @Published public var constantRotationDegrees: Double = 0.0
    @Published public var constantRotationRadians: Double = 0.0
    @Published public var currentDeviceOrientation: UIDeviceOrientation = .portrait
    
    public var motionLimit: Double // Smallers values makes it more sensitive to detect an orientation change. [0 to 1]
    public var animationType: Animation
    
    public var supportedOrientations: [UIDeviceOrientation]
    
    
    private let motionManager: CMMotionManager
    private let queue: OperationQueue
    
    public typealias DeviceOrientationHandler = ((_ deviceOrientation: UIDeviceOrientation) -> Void)?
    private var deviceOrientationAction: DeviceOrientationHandler?

    
    
    public init(motionLimit: Double = 0.6, animationType: Animation = .default, supportedOrientations: [UIDeviceOrientation] = [.portrait,.landscapeRight,.landscapeLeft], updateInterval: Double = 0.2) {
        //User set parameters
        self.motionLimit = motionLimit
        self.animationType = animationType
        self.supportedOrientations = supportedOrientations
        
        
        motionManager = CMMotionManager()
        motionManager.accelerometerUpdateInterval = updateInterval // Specify an update interval in seconds, personally found this value provides a good UX
        
        motionManager.deviceMotionUpdateInterval = updateInterval
        queue = OperationQueue()
    }
    
    public func startDeviceOrientationNotifier(with handler: DeviceOrientationHandler) {
        self.deviceOrientationAction = handler
        
        //  Using main queue is not recommended. So create new operation queue and pass it to startAccelerometerUpdatesToQueue.
        //  Dispatch U/I code to main thread using dispach_async in the handler.
        
        motionManager.startAccelerometerUpdates(to: queue) { (data, error) in
            if let accelerometerData = data {
                var newDeviceOrientation: UIDeviceOrientation?
                if (accelerometerData.acceleration.x >= self.motionLimit) && self.supportedOrientations.contains(.landscapeLeft){
                    newDeviceOrientation = .landscapeLeft
                }
                else if (accelerometerData.acceleration.x <= -self.motionLimit) && self.supportedOrientations.contains(.landscapeRight){
                    newDeviceOrientation = .landscapeRight
                }
                else if (accelerometerData.acceleration.y <= -self.motionLimit) && self.supportedOrientations.contains(.portrait){
                    newDeviceOrientation = .portrait
                }
                else if (accelerometerData.acceleration.y >= self.motionLimit) && self.supportedOrientations.contains(.portraitUpsideDown){
                    newDeviceOrientation = .portraitUpsideDown
                }
                else {
                    return
                }
                
                // Only if a different orientation is detected, execute handler
                if newDeviceOrientation != self.currentDeviceOrientation {
                    DispatchQueue.main.async {
                    self.currentDeviceOrientation = newDeviceOrientation!
                    self.orientationChanged(orientation: self.currentDeviceOrientation)
                    if let deviceOrientationHandler = self.deviceOrientationAction {
                            deviceOrientationHandler!(self.currentDeviceOrientation)
                        }
                    }
                }
            }
        }
        
        motionManager.startDeviceMotionUpdates(to: queue) { data, error in
            if let gyroData = data{
                DispatchQueue.main.async{
                    self.constantRotationRadians = atan2(gyroData.gravity.x, gyroData.gravity.y) - Double.pi
                    self.constantRotationDegrees = self.constantRotationRadians.toDegrees()
                }
            }
        }
    }
    
    public func stopDeviceOrientationNotifier() {
        motionManager.stopAccelerometerUpdates()
    }
    
    private func orientationChanged(orientation: UIDeviceOrientation){
        DispatchQueue.main.async{ [self] in
            switch orientation {
                
            case .portrait:
                withAnimation(animationType){
                    deviceRotationRadians = 0.0
                    deviceRotationDegrees = deviceRotationRadians.toDegrees()
                }
                break
                
            case .portraitUpsideDown:
                withAnimation(animationType){
                    deviceRotationRadians = Double.pi
                    deviceRotationDegrees = deviceRotationRadians.toDegrees()
                }
                break
                
            case .landscapeLeft:
                withAnimation(animationType){
                    deviceRotationRadians = -Double.pi / 2
                    deviceRotationDegrees = deviceRotationRadians.toDegrees()
                }
                break
                
            case .landscapeRight:
                withAnimation(animationType){
                    deviceRotationRadians = Double.pi / 2
                    deviceRotationDegrees = deviceRotationRadians.toDegrees()
                }
                break
                
            default:
                break
            }
        }
    }
}
