# Braze Push Notifications (iOS)

The app is wired for **Braze push notifications** on iOS: when the user enables “Push Notifications” in Profile, the app requests system permission and registers the device with Braze so you can send push campaigns from the Braze dashboard.

---

## What’s implemented

- **iOS:** Braze is configured with `push.automation = true` so the SDK can request notification permission and register the device token with APNs/Braze. Push events (received, opened) are forwarded to Flutter.
- **Profile:** “Push Notifications” toggle calls the OS permission prompt when turned on; if the user grants permission, the preference is saved and Braze is set to subscribed. If they deny, the toggle stays off.
- **Braze subscription:** `BrazeService.setPushSubscription(true/false)` is synced from the user’s preference so Braze knows whether to send push to this user.

---

## What you need to do

### 1. Xcode: Push Notifications capability

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Select the **Runner** target → **Signing & Capabilities**.
3. Click **+ Capability** and add **Push Notifications**.
4. This adds the `aps-environment` entitlement so the app can receive remote notifications.

### 2. Braze dashboard: APNs credentials

Braze needs your Apple push credentials to send to APNs.

1. In **Apple Developer** → **Certificates, Identifiers & Profiles** → **Keys**, create an **APNs Key** (or use an existing one). Download the `.p8` file and note the **Key ID**.
2. In **Braze** go to **Settings** (or **Manage Settings**) → **Push Notifications** / **App Settings** → your iOS app.
3. Upload your **APNs Authentication Key** (`.p8`), and enter your **Key ID**, **Team ID**, and **Bundle ID** (`com.verygoodburgers.veryGoodBurgers` or whatever your `PRODUCT_BUNDLE_IDENTIFIER` is).
4. Alternatively, you can upload an **APNs Certificate** (`.p12`) if your workspace uses certificate-based auth.

Details: [Braze – Push notifications](https://www.braze.com/docs/developer_guide/push_notifications/).

### 3. Create and send a push campaign

1. In Braze go to **Messaging** → **Campaigns** → **Create Campaign**.
2. Select **Push notification**.
3. Set audience (e.g. segment or test user by external ID).
4. Compose the message and set delivery (e.g. send immediately or schedule).
5. Launch. Users who have granted notification permission and have “Push Notifications” turned on in the app will receive the push.

---

## Testing

1. Run the app on a **physical device** (push does not work on the simulator).
2. Open **Profile** and turn **Push Notifications** **ON**. Accept the system permission dialog.
3. In Braze, create a push campaign targeting your test user (by external ID / segment) and send (or schedule) the message.
4. Background or close the app and wait for the push; tap it to open the app.

If no push arrives, confirm: (a) Push Notifications capability is added in Xcode, (b) APNs key/certificate is uploaded in Braze for the correct bundle ID, (c) the user has granted permission and has the toggle on, and (d) the device has internet when the campaign is sent.
