import Flutter
import UIKit
import BrazeKit
import BrazeUI
import braze_plugin

@main
@objc class AppDelegate: FlutterAppDelegate {
  var contentCardsSubscription: Braze.Cancellable?
  var pushEventsSubscription: Braze.Cancellable?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let configuration = Braze.Configuration(
      apiKey: "e5065844-aba5-4514-a84c-a1108a40beb3",
      endpoint: "sdk.fra-02.braze.eu"
    )
    // Enable Braze push: auto request permission and register device token with APNs/Braze
    configuration.push.automation = true
    let braze = BrazePlugin.initBraze(configuration)
    // Forward in-app messages to Flutter for display (do not show natively).
    braze.inAppMessagePresenter = FlutterInAppMessagePresenter()
    // Forward content cards to Flutter (e.g. for home screen under Limited time offer).
    contentCardsSubscription = braze.contentCards.subscribeToUpdates { contentCards in
      BrazePlugin.processContentCards(contentCards)
    }
    // Forward push events to Flutter (e.g. push received, opened).
    pushEventsSubscription = braze.notifications.subscribeToUpdates { payload in
      BrazePlugin.processPushEvent(payload)
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

/// Sends in-app messages to the Flutter layer; does not display them natively.
final class FlutterInAppMessagePresenter: BrazeInAppMessageUI {
  override func present(message: Braze.InAppMessage) {
    BrazePlugin.processInAppMessage(message)
    // Do not call super.present(message:) so the message is only shown in Flutter.
  }
}
