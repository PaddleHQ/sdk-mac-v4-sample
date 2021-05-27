# macOS SDK v4 Sample App Swift

The sample app for the [macOS SDK v4](https://github.com/PaddleHQ/Mac-Framework-V4) highlights features and best practices enabled by the SDK.

To report Issues / Bugs Please contact Paddle Support by emailing sellers@paddle.com

## Installation

The sample app uses Cocoapods to install the PaddleV4 pod. Other ways to integrate the macOS SDK exist,
such as Carthage or directly linking the dynamic framework, but the sample app cannot use all of
these methods simultaneously.

1. Update Cocoapods' cache using `pod repo update`.
1. Install the PaddleV4 pod using `pod install`.
1. Open the Xcode workspace using `open "macOS SDK v4 Swift Sample.xcworkspace"`.
1. Set your team for development signing and select a signing certificate managed by Apple.
1. Create your Paddle seller account and SDK product, if you haven't already. 
1. In `AppConfig.swift` enter your
    * seller account ID,
    * seller acount name,
    * product ID,
    * product name,
    * Second product ID,
    * Second product name,
    * framework API key.
1. Run the app in Xcode.
