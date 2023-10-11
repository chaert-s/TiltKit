## TiltKit

# Installation
Copy this repo's [link](https://github.com/chaert-s/TiltKit) and simply add it to your Swift package dependencies.


# Configuration
Make sure to import TiltKit by adding `import TiltKit` to the top of your file and only have `portrait` mode selected as available device orientations in your project settings.     
To use TiltKit the easiest, simply apply `.rotation()` to any view element you want to rotate. Additionally you can choose to pass an argument of `.tilt` alongside it which instructs the element to always stay level with the ground.   

TiltKit also provides a shared instance of the class class `DeviceOrientationHelper` which you can access via `DeviceOrientationHelper.shared()` that contains `@Published` vars for `deviceRotationDegrees` and `deviceRotationRadians`. You can use these to drive `.rotationEffect(Angle())` on any SwiftUI element. This is described in detail below.    
Though you can still create your own instances of `DeviceOrientationHelper`, it is strongly recommended to use the shared instance throughout your app to avoid multiple instances of CMMotionManager to be active at once. 
Here is a possible implementation:
```swift

struct RotationDemo: View {
    var body: some View {
        HStack{
            //This will rotate
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .rotationEffect(Angle(degrees: DeviceOrientationHelper.shared().deviceRotationDegrees))
            
            //This will not rotate
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
            
            //This will rotate
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .rotation()
            
            
            //This will rotate
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .rotation(.tilt)
            
        }
    }
}
```

# Configuration (old)
The `DeviceOrientationHelper()` works out of the box but has many customization options.   
```swift
@StateObject var rotationHelper = DeviceOrientationHelper(motionLimit: 0.8, animationType: .default, supportedOrientations: [.portrait,.landscapeRight, .landscapeLeft,.portraitUpsideDown], updateInterval: 0.2)
```
The example above shows the default configuration of the helper.  

`motionLimit` defines the tilt amount needed for a device orientation change to occur. Smaller values make the helper more sensitive. The range is between 0 and 1.  

`animationType` defines the SwiftUI animation style with which the published values `degrees` and `radians` are updated with. This is fully compatible with any animation style.  

`supportedOrientations` lets you define what device orientations the user can access.  

`updateInterval` specfies the clock speed of the `CMMotionManager`'s updates in seconds. Please note that Apple specifies a maximum refresh rate of 100Hz for the accelerometer, so values lower than `0.01` will not do anything. Also, weird things tend to start happening with high refresh rates, so it is advised to keep the value within reason.  


# Usage example
Make sure to import TiltKit by adding `import TiltKit` to the top of your file and only have `portrait` mode selected as available device orientations in your project settings.  
TiltKit provides a class `DeviceOrientationHelper` that contains `@Published` vars for `degrees` and `radians`. You can use these to drive `.rotationEffect(Angle())` on any SwiftUI elements.  

Here is a possible implementation:  
```swift
struct RotationDemo: View {
@StateObject var rotationHelper = DeviceOrientationHelper()
var body: some View {
        HStack{
            //This will rotate
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .rotationEffect(Angle(radians: rotationHelper.radians))
            
            //This will not rotate
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
            
            //This will rotate
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .rotationEffect(Angle(degrees: rotationHelper.degrees))
            
        }.onAppear(){
            //The function provides the possibility to execute additional code when a new device orientation is detected.
            rotationHelper.startDeviceOrientationNotifier { deviceOrientation in
                print("Device orientation changed to: \(deviceOrientation)")
            }
        }
        .onDisappear(){
            //Make sure to stop updates when the view disappears to efficiently use device resources and avoid conflicts with other CoreMotion implementations in other parts of the app
            rotationHelper.stopDeviceOrientationNotifier()
        }
    }
}
```

# Further information
I opted for a custom CoreMotion implementation, as `UIDevice.current.beginGeneratingDeviceOrientationNotifications()` didn't work on SwiftUI views for me. Also, with CoreMotion driving the interface changes, they work even when Orientation Lock is on.  
If you are concerned about creating multiple instances of a `CMMotionManager`, you can use the `.shared` instance of the `DeviceOrientationHelper` that uses all standard settings.   
This package was inspired by Pablo Dominé who [explains the process here](https://medium.com/@PabloDomine/developing-camille-how-to-determine-device-orientation-in-a-camera-app-4c622d251993).  
I brought the concepts into SwiftUI and expanded upon the implementation to make it more user friendly.
