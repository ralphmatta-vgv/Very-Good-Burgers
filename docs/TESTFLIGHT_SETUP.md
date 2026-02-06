# TestFlight Setup — Get Updates on Your Phone Without Plugging In

Follow these steps in order. Your app uses **Bundle ID:** `com.verygoodburgers.veryGoodBurgers` and **Name:** Very Good Burgers.

---

## Part A: One-time setup (Apple Developer & App Store Connect)

### Step 1: Apple Developer Program

- You need a **paid Apple Developer** account ($99/year).
- If you don’t have one: [developer.apple.com/programs](https://developer.apple.com/programs/) → **Enroll**.
- Sign in with the same Apple ID you use in Xcode for code signing.

### Step 2: Create the app in App Store Connect

1. Open **[App Store Connect](https://appstoreconnect.apple.com)** in your browser. Sign in with your Apple Developer Apple ID.
2. Click **My Apps**.
3. Click the **+** (plus) button → **New App**.
4. Fill in:
   - **Platforms:** check **iOS**.
   - **Name:** `Very Good Burgers`
   - **Primary Language:** English (or your choice).
   - **Bundle ID:** open the dropdown and select **`com.verygoodburgers.veryGoodBurgers`**.
     - If it’s not in the list, you must create it first: go to [developer.apple.com/account](https://developer.apple.com/account) → **Certificates, Identifiers & Profiles** → **Identifiers** → **+** → **App IDs** → **App** → Description: `Very Good Burgers`, Bundle ID: **Explicit** → `com.verygoodburgers.veryGoodBurgers` → Register. Then go back to App Store Connect and create the app again; the Bundle ID will appear.
   - **SKU:** e.g. `very-good-burgers-1` (any unique string).
   - **User Access:** Full Access (or your choice).
5. Click **Create**. You’ll land on the app’s page.

---

## Part B: Build and upload the first version

### Step 3: Open the project in Xcode

1. On your Mac, open Terminal.
2. Run:
   ```bash
   cd /Users/ralph/very_good_burgers
   open ios/Runner.xcworkspace
   ```
3. **Important:** Use `Runner.xcworkspace`, not `Runner.xcodeproj`. Xcode will open.

### Step 4: Set the signing team in Xcode

1. In the **left sidebar**, click the blue **Runner** project (top item).
2. Under **TARGETS**, select **Runner**.
3. Open the **Signing & Capabilities** tab.
4. Under **Signing**, check **Automatically manage signing**.
5. **Team:** choose your Apple Developer team (e.g. your name or company). If you see “Add an Account…”, add your Apple ID and select the team.
6. Confirm **Bundle Identifier** is `com.verygoodburgers.veryGoodBurgers`. Don’t change it unless you also changed it in App Store Connect.

### Step 5: Create an Archive (IPA)

1. In the top-left of Xcode, set the run destination to **Any iOS Device (arm64)** — not a simulator.
   - Click the device dropdown (it might say “Runner > iPhone 16” or similar) → choose **Any iOS Device (arm64)**.
2. In the menu bar: **Product** → **Archive**.
3. Wait for the build to finish (can take a few minutes). If it fails, read the error; usually it’s signing (re-check Step 4) or a missing capability.
4. When done, the **Organizer** window opens and shows your new archive.

### Step 6: Upload to App Store Connect

1. In the **Organizer** window, select the archive you just created (latest one).
2. Click **Distribute App**.
3. Choose **App Store Connect** → **Next**.
4. Choose **Upload** → **Next**.
5. Leave options as default (e.g. “Upload your app’s symbols”, “Manage Version and Build Number” if you want) → **Next**.
6. Review the signing info → **Upload**.
7. Wait for the upload to finish. When it says “Upload Successful”, click **Done**.

### Step 7: Wait for processing

1. Go to **[App Store Connect](https://appstoreconnect.apple.com)** → **My Apps** → **Very Good Burgers**.
2. Open the **TestFlight** tab.
3. Under **iOS**, you should see a build with a yellow “Processing” state. Wait 5–15 minutes (sometimes up to an hour). When it’s ready, the status becomes a green checkmark and the build number appears (e.g. 1.0.0 (1)).

---

## Part C: Enable TestFlight and add yourself

### Step 8: Add internal testers (easiest — you)

1. In App Store Connect, still in **TestFlight** for Very Good Burgers.
2. In the left sidebar under **TestFlight**, click **Internal Testing**.
3. Click **+** next to **App Store Connect Users** (or create a group if prompted).
4. **Internal testers** are people in your App Store Connect team. Add yourself:
   - Go to **Users and Access** (top right, your account menu) → **People** → invite yourself with the same Apple ID you use on your iPhone, role **Admin** or **Developer**, then accept the invite in email if needed.
   - Or if you’re already the only user, you’re already an internal tester.
5. Back in **TestFlight** → **Internal Testing** → select the group → under **Build**, choose the processed build (e.g. 1.0.0 (1)).
6. Internal testers get the build automatically; no email invite needed.

### Step 9: Install TestFlight on your iPhone

1. On your **iPhone**, open the **App Store**.
2. Search for **TestFlight**.
3. Install the free **TestFlight** app by Apple.

### Step 10: Install Very Good Burgers from TestFlight

1. On your **iPhone**, open the **TestFlight** app.
2. Sign in with the **same Apple ID** you use in App Store Connect (the one that’s an internal tester).
3. You should see **Very Good Burgers** in the list. Tap **Install** (or **Update** if you already had it).
4. After install, open the app from the home screen. You may need to **Trust** the developer once: **Settings** → **General** → **VPN & Device Management** → your developer account → **Trust**.

---

## Part D: Getting updates without plugging in (every time you want to push a new build)

### Step 11: Build and upload a new version

1. Make your code changes in Cursor (or Xcode) and save.
2. In Xcode (with `ios/Runner.xcworkspace` open):
   - Set destination to **Any iOS Device (arm64)**.
   - **Product** → **Archive**.
   - In Organizer: select the new archive → **Distribute App** → **App Store Connect** → **Upload** → complete the flow.
3. In App Store Connect → **TestFlight**, wait until the new build shows a green checkmark (Processing done).

### Step 12: Update on your phone (no cable)

1. On your **iPhone**, open the **TestFlight** app.
2. Under **Very Good Burgers**, you’ll see **Update** (or a version number). Tap **Update**.
3. When it’s done, open Very Good Burgers from the home screen. You’re on the latest build.

You never need to plug the phone in for this. You only need the Mac to build and upload; the phone gets the update over the air via TestFlight.

---

## Troubleshooting

| Problem | What to do |
|--------|------------|
| “No accounts with App Store Connect access” | In Xcode: **Xcode** → **Settings** → **Accounts** → **+** → add your Apple ID. Use the one that’s in the Apple Developer Program. |
| Bundle ID not in App Store Connect dropdown | Create the App ID in [developer.apple.com/account](https://developer.apple.com/account) → Identifiers → **+** → App IDs → use `com.verygoodburgers.veryGoodBurgers`. |
| Archive is disabled (grayed out) | Set run destination to **Any iOS Device (arm64)**, not a simulator. |
| Upload fails with signing error | In Xcode → Runner target → **Signing & Capabilities** → ensure **Team** is set and **Automatically manage signing** is checked. |
| App doesn’t appear in TestFlight on phone | Confirm you’re signed into TestFlight with the same Apple ID that’s an internal tester. Wait a few minutes after the build finishes processing. |
| “Untrusted Developer” on phone | **Settings** → **General** → **VPN & Device Management** → tap your developer account → **Trust**. |

---

## Quick reference

- **App Store Connect:** [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
- **Bundle ID:** `com.verygoodburgers.veryGoodBurgers`
- **Open project in Xcode:** `open /Users/ralph/very_good_burgers/ios/Runner.xcworkspace`
- **Update flow:** Change code → Archive in Xcode → Distribute → Upload → wait for Processing → open TestFlight on phone → Update.
