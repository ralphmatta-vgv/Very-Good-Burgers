# Relaunch the app and export your real order history

Follow these steps to run the app again and export your **actual** order/behavior data so we can import it into Braze.

---

## Step 1: Connect your iPhone

- Plug your iPhone into your Mac with a USB cable.
- Unlock the phone. If it asks **“Trust This Computer?”**, tap **Trust** and enter your passcode.

---

## Step 2: Open the project and run the app

**Option A – Terminal (Flutter)**

1. Open **Terminal**.
2. Run (profile mode recommended — better performance, no debug overhead):
   ```bash
   cd /Users/ralph/very_good_burgers
   flutter run --profile
   ```
3. When Flutter lists devices, choose your **iPhone** (e.g. “Ralph’s iPhone”).
4. Wait for the app to build and install. The app will open on your phone.

**Option B – Xcode**

1. Open the project in Xcode:
   ```bash
   open /Users/ralph/very_good_burgers/ios/Runner.xcworkspace
   ```
2. At the top of Xcode, click the device menu and select your **iPhone** (not “Any iOS Device” and not a simulator).
3. Press the **Run** button (▶) or press **Cmd + R**.
4. Wait for the build to finish. The app will install and open on your phone.

**Note:** If you had the app on this phone before (e.g. from TestFlight), installing this way **replaces** that build. Your app data (order history, user) is usually **kept** when you replace with a build from the same project, so your history may still be there.

---

## Step 3: Export from the app

1. In the app, go to **Order History** (e.g. open the cart or menu and find “Order History”, or use the tab that shows past orders).
2. In the **top-right** of the screen, tap the **export icon** (upload/file icon).
3. A message will appear at the bottom saying something like: **“Exported to …/Documents/braze_export.json”**. That’s the path on the **phone**; you’ll get the file in the next step.

---

## Step 4: Copy the export file to your Mac

**Using Xcode (easiest)**

1. In Xcode: **Window → Devices and Simulators** (or **Xcode → Window → Devices and Simulators**).
2. Select your **iPhone** in the left sidebar.
3. Under “Installed Apps”, find **Very Good Burgers** (or your app name).
4. Select it and click the **gear icon** below the list → **Download Container…**.
5. Choose a folder on your Mac and save (e.g. Desktop). This downloads the app’s container (a `.xcappdata` file).
6. **Right‑click** the downloaded file → **Show Package Contents**.
7. Open **AppData → Documents**. You should see **braze_export.json**.
8. Copy **braze_export.json** to a folder you’ll use for the import (e.g. your project folder or Desktop).

**Using Finder (if the app saves to a visible folder)**

- If your app or iOS version exposes the app’s Documents in the Files app, open **Files → On My iPhone → Very Good Burgers → Documents** and copy **braze_export.json** (e.g. Air Drop to your Mac or share to an app that syncs to the Mac). If you don’t see it, use the Xcode method above.

---

## Step 5: Run the Braze historical import

1. Open **Terminal**.
2. Set your Braze REST key and endpoint (use your real REST API key and your cluster’s REST URL, e.g. `https://rest.fra-02.braze.eu`):
   ```bash
   export BRAZE_REST_API_KEY="your_rest_api_key_here"
   export BRAZE_REST_ENDPOINT="https://rest.fra-02.braze.eu"
   ```
3. Run the script with the path to the file you copied (replace with your actual path):
   ```bash
   cd /Users/ralph/very_good_burgers
   node scripts/braze_historical_import.js /path/to/braze_export.json
   ```
   Example if you put the file on your Desktop:
   ```bash
   node scripts/braze_historical_import.js ~/Desktop/braze_export.json
   ```
4. When it finishes, check Braze **User Search** for **user_1** (or your user) and confirm you see your **purchases** and **order_completed** events.

---

## If the app opens but Order History is empty

That usually means the data was cleared (e.g. app was uninstalled at some point, or a different install). In that case you can’t recover the old data; you can place a few test orders, export again, and run the import to get that new history into Braze.

---

## Quick checklist

- [ ] iPhone connected and trusted
- [ ] App built and run from Flutter or Xcode to the **same iPhone** you used before
- [ ] Opened **Order History** and tapped the **export** icon
- [ ] Downloaded the app container in Xcode and copied **braze_export.json** to the Mac
- [ ] Ran `node scripts/braze_historical_import.js .../braze_export.json` with REST key and endpoint set
- [ ] Checked Braze for your user and events
