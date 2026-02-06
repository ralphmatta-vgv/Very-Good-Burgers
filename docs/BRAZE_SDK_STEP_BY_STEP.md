# Braze SDK — Step-by-Step Setup

Follow these steps in order. You’ll need your **Braze sandbox** (or dashboard) open.

---

## Step 1: Get your Braze API key and endpoint

1. Log in to **Braze** (your sandbox).
2. Go to **Settings** (gear) → **Partner Integrations** → **Braze SDK** (or **Manage Settings** → **SDK Keys**).
3. Find **iOS** (or **Apple**) and copy:
   - **API Key** (sometimes called “SDK Key” or “App Identifier API Key”) — looks like `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` or a long string.
   - **SDK Endpoint** (or “REST Endpoint” / “Data Cluster”) — e.g. `sdk.iad-01.braze.com` or `sdk.iad-02.braze.com`.  
     If you only see a REST endpoint, the SDK endpoint is often the same host with `sdk.` in front (e.g. `iad-01.braze.com` → `sdk.iad-01.braze.com`).

**Share with me (you can redact the middle of the key if you prefer):**
- **API Key (iOS):** `________________`
- **SDK Endpoint:** `________________`

I’ll plug these into the project. If your Braze dashboard uses different labels, tell me what you see and we’ll map them.

---

## Step 2: Add the Braze Flutter package

- In the project, we’ll **uncomment** `braze_plugin` in `pubspec.yaml` and run `flutter pub get`.  
- I can do this once you’re ready (or you can do it: uncomment the line and run `flutter pub get` in the project root).

---

## Step 3: Configure iOS (AppDelegate)

- Braze must be **initialized on the native iOS side** with your API key and endpoint.
- **`ios/Runner/AppDelegate.swift`** is already set up to:
  - Import Braze (BrazeKit + braze_plugin)
  - Create a Braze configuration and call `BrazePlugin.initBraze(configuration)`.

**What you need to do:** Open `ios/Runner/AppDelegate.swift` and replace the placeholders with your Braze sandbox values from Step 1:
- `<YOUR_BRAZE_IOS_API_KEY>` → your iOS API Key
- `<YOUR_BRAZE_SDK_ENDPOINT>` → your SDK Endpoint (e.g. `sdk.iad-01.braze.com`)

If you prefer, you can share the key and endpoint (you can redact part of the key) and we can plug them in for you.

---

## Step 4: Wire the Dart app to the Braze SDK

- In **`main.dart`** we’ll create a `BrazePlugin()` instance and pass it to **`BrazeService`** so all tracking (events, attributes, purchases, subscription state) goes to the real Braze SDK instead of the console.
- **`lib/services/braze_service.dart`** will be updated to call the Braze plugin’s methods (e.g. `changeUser`, `logCustomEvent`, `logPurchase`, `setPushNotificationSubscriptionType`, etc.) when the plugin is set.

No changes needed from you here; I’ll implement it once Steps 1–3 are done.

---

## Step 5: Run the app and confirm in Braze

1. Run the app on the **iOS Simulator** or a device (profile mode recommended):  
   `flutter run --profile`
2. **Optional — migrate legacy id to UUID:** If you want the app to rename `user_1` (or any non-UUID id) to a UUID in Braze (one profile, no duplicate), get a Braze **REST API key** with `users.external_ids.rename` and run:  
   `flutter run --profile --dart-define=BRAZE_REST_API_KEY=your_rest_key --dart-define=BRAZE_REST_ENDPOINT=https://rest.fra-02.braze.eu`  
   (Use your cluster’s REST URL, e.g. `rest.fra-02.braze.eu` for EU.)
3. In the app: open a tab, add an item to cart, place an order (or use the test 1-click order button).
4. In **Braze** go to **User Search** and look up your user (UUID or `user_1`).
5. Check that you see:
   - **Custom events** (e.g. `add_to_cart`, `order_completed`)
   - **Custom attributes** (e.g. `loyalty_points`, `total_orders`)
   - **Purchase events** (if you placed an order)
   - **Favorite store** and other derived attributes (refreshed on every app launch)

If something doesn’t show up, we’ll debug (e.g. endpoint, API key, or Braze dashboard filters).

---

## Checklist

- [ ] **Step 1:** Get API Key (iOS) and SDK Endpoint from Braze; share them (or placeholders) with me.
- [x] **Step 2:** Add `braze_plugin` (done in pubspec + `flutter pub get`).
- [ ] **Step 3:** Put your key and endpoint in `ios/Runner/AppDelegate.swift` (replace the `<YOUR_...>` placeholders).
- [x] **Step 4:** Wire Dart app to Braze (main.dart + braze_service.dart — done).
- [ ] **Step 5:** Run app and confirm events/attributes in Braze.

**Your next action:** Send the **iOS API Key** and **SDK Endpoint** from your Braze sandbox (you can redact part of the key if you like). Steps 2–4 are already done in the repo; you only need to paste your key and endpoint into `ios/Runner/AppDelegate.swift`, then run the app and verify in Braze (Step 5).

**If `pod install` fails** (e.g. encoding error): run `export LANG=en_US.UTF-8` in the terminal, then `cd ios && pod install`. Or run `flutter run --profile` from the project root—Flutter often runs pod install for you.
