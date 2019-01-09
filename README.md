# macOS SDK v4 Sample App

The sample app for the [macOS SDK v4](https://github.com/PaddleHQ/Mac-Framework-V4) highlights features and best practices enabled by the SDK.

## Installation

The sample app uses Cocoapods to install the PaddleV4 pod. Other ways to integrate the macOS SDK exist,
such as Carthage or directly linking the dynamic framework, but the sample app cannot use all of
these methods simultaneously.

1. Install [Bundler](https://bundler.io/). Typically this will be `gem install bundler`.
1. Install the Cocoapods gem using `bundle install`.
1. Update Cocoapods' cache using `bundle exec pod repo update`.
1. Install the PaddleV4 pod using `bundle exec pod install`.
1. Open the Xcode workspace using `open "macOS SDK v4 Sample.xcworkspace"`.
1. Set your team for development signing and select a signing certificate managed by Apple.
1. Create your Paddle seller account and SDK product, if you haven't already. The app has been configured with a
product with a 14-day trial; you may want to use a similar product.
1. In `AppConfig.m` enter your
    * seller account ID,
    * seller acount name,
    * product ID,
    * product name, and,
    * framework API key.
1. Run the app in Xcode.

TODO: link to documentation to create Paddle account and an SDK product.

## Sample app functionality

The sample app only provides trivial functionality as the main purpose is to highlight the features and best practices of the Paddle SDK. The app can generate random numbers between 0 and 1000. The random number is generated when the user clicks the label in the centre of the app. 

## Features and best practices

### Dialogs as sheets

Dialogs in macOS apps can be displayed as either regular windows or sheets. Regular windows can be moved around and simply ignored. Sheets prevent most interaction with the app until the sheet is closed. This property is useful for gatekeeping functionality that you expect users to pay for.

Displaying dialogs as sheets can be achieved by implementing the Paddle delegate method `willShowPaddleUIType:product:` and returning a display configuration with a display type of "sheet", along with a window to attach the dialog. Note that some dialogs are only ever shown as regular windows, i.e. the mailing list dialog and the license recovery dialog.

All dialogs in the sample app are displayed as sheets to highlight the different behaviour from regular windows. You could also conditionally show some dialogs as regular windows, such as the checkout dialog or the license activation dialog.

### Verification strategy

Users can purchase your SDK product and activate the license assigned to them after the purchase. The local activation can then be remotely
destroyed via the Paddle dashboard. This results in needing to verify that the local activation is still valid and, if it is now invalid, that it is destroyed
to prevent further access to gated functionality.

Unfortunately the user may be offline for some time, leaving the activation in an unknown state of verification. A verification strategy must then handle this case, whilst also keeping users happy. It would be a mistake to destroy activations the moment the user loses connection to the internet, for instance.

The strategy implemented in the sample app handles the 4 possible states of the local activation as so:
* If there is no activation, then the product access dialog is used to enforce the trial of the SDK product. This will allow the user full access to the app until the trial has expired. After expiration the user must either purchase the product, activate a previously bought license or quit the app.
* If the activation is verified remotely, the user can continue using the app.
* If the activation state could not be accessed (possibly due to network issues), then a grace period of 7 days is granted: the user has 7 days to go back online (or fix whatever issue is preventing the verification). After the grace period, the activation is destroyed and the app returns to the initial, unactivated state.
* If the activation is unverified, then the activation has been remotely destroyed. We notify the user of this event and then destroy the local activation to prevent further notifications. The app again returns to the initial, unactivated state.

The above strategy is triggered at 2 key points in the lifecycle of the app: on app launch and when the user uses the core functionality of the app. The combination of these events is just enough to ensure that we are not overzealous in verifying the activation and not lenient enough to allow for unlimited free usage (e.g. when only checking on app launch). The timing could also be explicitly time-based, e.g. every 30 minutes the activation is verified. Both choices, and others, have their benefits.

### Recovering licenses

Users may already have a license for your app but could possibly not find the license in their inbox. For such cases the macOS SDK provides a dialog to recover licenses relevant to your product. The dialog asks for the user's email and if the email is valid, Paddle will send the user an email containing their license(s).

The sample app has a button in the trial bar called "Forgot your license?" to show this dialog.
