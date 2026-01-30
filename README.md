# Very Good Burgers (VGB)

A **Flutter iOS app** for a quick-service restaurant (QSR): mobile ordering, loyalty program (“Bites”), and Braze SDK integration points.

---

## What’s in the app

- **Home** — Welcome, promo (Double Smash Deal), quick actions (Order, Rewards, Locations, History), loyalty preview, popular items.
- **Order** — Store & pickup time, menu by category (Burgers, Sides, Drinks, Desserts, Combos), item details and add-to-cart.
- **Rewards** — Bites progress (0–10), banked rewards, redeem for free items; “How it works” and recent activity.
- **Profile** — Name, email, phone, birthday, notifications; payment methods (set Primary); addresses; Terms, Privacy, Help; profile photo (pick from phone, circular editor).

**Loyalty (Bites):** Every $10+ order earns 1 Bite. At 10 Bites you get a free reward; counter resets to 0 and you can keep earning. Free/redeemed orders don’t earn Bites. Rewards never expire.

---

## Who this is for

- **You (non-coder):** Use this README to understand what the project is and share the repo with others.
- **Developers:** Use the sections below to run the app, understand structure, and extend it (e.g. Braze).

---

## How to run the app

**You need:** a Mac with [Flutter](https://docs.flutter.dev/get-started/install/macos) and Xcode installed.

1. **Clone the repo** (or download and unzip):
   ```bash
   git clone https://github.com/ralphmatta-vgv/Very-Good-Burgers.git
   cd Very-Good-Burgers
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run on iOS Simulator:**
   ```bash
   flutter run
   ```
   (Pick the iPhone simulator when prompted.)

4. **Run on your iPhone:**  
   Connect the phone, enable Developer Mode in **Settings → Privacy & Security**, then run `flutter run` and select your device. You may need to trust the developer certificate in **Settings → General → Device Management** the first time.

---

## Project structure (simplified)

| Folder / file   | Purpose |
|-----------------|--------|
| `lib/`          | App code (screens, widgets, logic). |
| `lib/screens/`  | Main screens: Home, Order, Rewards (Loyalty), Profile, Order History, Help, Terms, Privacy. |
| `lib/widgets/`   | Reusable UI (cart, modals, punch card, profile photo editor). |
| `lib/providers/`| State (user, cart, app/loyalty). |
| `lib/models/`   | Data shapes (user, order, menu item, etc.). |
| `lib/services/`  | Braze service (logs events; real SDK is TODO). |
| `lib/data/`     | Menu and store data. |
| `assets/`       | Images, app icon. |
| `ios/`          | iOS project and config (Xcode). |

---

## Tech and integrations

- **Flutter** (Dart), **Provider** for state, **shared_preferences** for local persistence.
- **Braze:** `lib/services/braze_service.dart` has placeholders for events (e.g. `add_to_cart`, `order_completed`, loyalty). Replace the `print`/TODO with the real Braze SDK when ready.
- **iOS only** in this setup (no Android configuration in the repo).

---

## Version

1.0.0 — See `pubspec.yaml` for dependency versions.

---

## License

Private / not published to pub.dev. See repo or project for license details.
