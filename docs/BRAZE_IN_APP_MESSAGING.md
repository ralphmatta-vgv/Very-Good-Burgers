# Braze In-App Messaging

The app is wired to **display Braze in-app messages** so you can run campaigns from the Braze dashboard without implementing push first.

---

## What’s implemented

- **Subscription:** The app subscribes to Braze’s in-app message stream at launch.
- **Display (all Braze formats):**
  - **Modal** → Centered dialog (title, body, image, buttons).
  - **Full / Full Screen** → Full-screen takeover (large header image, then content and buttons; close via X).
  - **Slideup** → Bottom sheet.
  - **HTML** → Shown as a modal (header, message, buttons; custom HTML body is not rendered).
  - **HTML Full** → Shown as full-screen (same as Full; custom HTML body is not rendered).
- **Analytics:** Impressions and button clicks are logged to Braze (impression when shown, button click when a CTA is tapped).

---

## How to use in Braze

1. In Braze go to **Engagement** → **In-App Messages** → **Create In-App Message**.
2. Choose a template: **Modal**, **Full** (full screen), **Slideup**, or **HTML**. The app shows each format appropriately (dialog, full-screen, bottom sheet, or modal/fallback for HTML).
3. Set **audience** (e.g. segment, or “Test User” for your external ID).
4. Set **trigger** (e.g. **Session start**, or a **Custom event** like `order_completed` if you want to show after checkout).
5. Design the message (header, body, image, button text, click action).
6. **(Optional)** In the message composer, add **Key-Value Pairs** (extras) so the in-app UI matches the colors you chose in Braze:
   - `primary_color` or `button_color` – hex for buttons and accents (e.g. `#00C48C` or `00C48C`).
   - `icon_background_color` – hex for the image placeholder background when the image is missing or loading.
   - `icon_color` – hex for the placeholder icon.
   If you don’t set these, the app uses its default brand blue.
7. Launch the campaign (or use **Test** to send to a test user).

Messages that match the user and trigger will be delivered to the app and shown automatically.

---

## Testing

1. Run the app: `flutter run --profile`
2. In Braze create a simple in-app message:
   - Trigger: **Session start** (or **App session start**)
   - Audience: add your test user by **external ID** (the UUID you see in Braze User Search) or a segment that includes that user
3. Fully close the app and reopen; the message should appear shortly after launch.

**If you don’t see it:** The app now registers the in-app message handler as soon as Braze starts, so session-start messages are captured even if they fire before the UI is ready. Confirm in Braze that (a) the campaign is live, (b) the audience includes your user’s external ID, and (c) the app has identified that user (open a tab, place an order, or wait a moment after launch).

You can also use **Test** in the Braze composer to send a one-off test to your device.
