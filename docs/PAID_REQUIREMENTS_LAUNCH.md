# Paid Requirements: Launch via TestFlight + Push

Everything you need to **pay for** (or have access to) to launch Very Good Burgers on **TestFlight** with **push notifications** working.

---

## 1. Apple Developer Program — **$99/year (USD)**

**What it covers**

- **TestFlight** – Build and upload the app, invite internal/external testers, get feedback before App Store.
- **App Store Connect** – Create the app record, manage versions, submit for review when you go to production.
- **Push (APNs)** – Create the APNs key (`.p8`) and use it with Braze. No extra Apple fee for push.

**Who needs it**

- One **paid membership** per app (or per company if you use an Organization account).
- **Individual:** You enroll; $99/year.
- **Organization:** Your company enrolls; employees are added as team members (no extra $99 per person). One $99/year for the org.

**Where**

- [developer.apple.com/programs](https://developer.apple.com/programs/) → Enroll.
- Use the same Apple ID in Xcode for signing and in App Store Connect.

**Without it**

- You cannot use TestFlight or distribute to testers.
- You cannot create an APNs key, so Braze cannot send push to your app.

---

## 2. Braze (push + messaging) — **Depends on your plan**

**What it covers**

- Push campaigns, in-app messages, Content Cards, analytics, etc.
- Your app is already integrated; you just need a Braze workspace and (for push) APNs credentials from #1.

**Who pays**

- Usually the **company** has a Braze contract (Growth, Enterprise, etc.). You use that workspace; no separate “per developer” fee.
- If you’re building a side project: Braze has free/small plans for limited usage; check [braze.com](https://www.braze.com) or contact sales.

**For push**

- No extra Braze fee for “enabling” push. You just need:
  - A Braze app (iOS) created in the dashboard, and  
  - APNs key (from #1) uploaded in Braze (see [BRAZE_PUSH.md](BRAZE_PUSH.md)).

---

## 3. Anything else?

| Item | Paid? | Notes |
|------|--------|--------|
| **TestFlight** | No extra | Included in Apple Developer Program ($99/year). |
| **Push (APNs)** | No extra | Same Apple account; you create a key and give it to Braze. |
| **Xcode** | Free | Download from Mac App Store. |
| **Braze SDK** | Free | Library in your app; cost is the Braze SaaS plan. |
| **Talon.one** (loyalty) | Depends | If you use it, check their pricing; not required for “TestFlight + push.” |
| **Domains / AASA (universal links)** | Optional | Only if you add universal links later; can use your own domain. |

---

## Checklist: “I want TestFlight + push”

1. **Apple**
   - [ ] Enroll in **Apple Developer Program** ($99/year) — [developer.apple.com/programs](https://developer.apple.com/programs/).
   - [ ] In Xcode: **Signing & Capabilities** → set your **Team** and add **Push Notifications** capability.
   - [ ] In [developer.apple.com](https://developer.apple.com): create an **APNs key**, download `.p8`, note **Key ID** and **Team ID**.

2. **Braze**
   - [ ] Have access to a Braze workspace (company plan or your own).
   - [ ] In Braze: add your **iOS app** and upload **APNs key** (.p8), **Key ID**, **Team ID**, **Bundle ID** (see [BRAZE_PUSH.md](BRAZE_PUSH.md)).

3. **TestFlight**
   - [ ] In **App Store Connect**: create the app (Bundle ID: `com.verygoodburgers.veryGoodBurgers`), then upload a build from Xcode (see [TESTFLIGHT_SETUP.md](TESTFLIGHT_SETUP.md)).
   - [ ] Add testers and install via TestFlight.

**Summary:** One recurring cost is **Apple Developer Program ($99/year)**. Braze is whatever your company (or you) already pays for; no extra fee for push beyond that.
