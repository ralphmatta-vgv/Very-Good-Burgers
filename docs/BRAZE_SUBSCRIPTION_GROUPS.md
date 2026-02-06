# Braze Subscription Groups — Messaging Preferences & Push

Messaging preferences (Push, Email, SMS) are **tracked out of the box by Braze** via **subscription groups**. They don’t live in the data tracking plan as custom events, but the **app’s toggles must be mapped to Braze subscription groups** so Braze can respect them when sending messages. **Push is a key channel to test.**

---

## App UI → Braze mapping

| App toggle (Profile) | Braze concept | What we need to do |
|----------------------|---------------|--------------------|
| **Push Notifications** | Push subscription group | When user toggles ON → set user to **Subscribed** for your push subscription group. When OFF → **Unsubscribed**. |
| **Email Offers** | Email subscription group | When user toggles ON → **Subscribed** for email (e.g. “Marketing” or “Offers”). When OFF → **Unsubscribed**. |
| **SMS Offers** | SMS subscription group | When user toggles ON → **Subscribed** for SMS. When OFF → **Unsubscribed**. |

So: **we still send the custom event `notification_preference_changed`** (per your tracking plan) for analytics, and **in addition** we call Braze’s **subscription group API** so Braze knows whether the user is subscribed for each channel. That way:

- Braze will **not** send push to users who turned Push OFF in the app.
- You can **test push** by toggling ON, then triggering a Braze campaign/Canvas that targets “push subscribed” users.

---

## Implementation (when you add the Braze SDK)

1. **Create subscription groups in Braze** (if you haven’t already):
   - Braze dashboard → **Subscription Groups** → create one for **Push** (e.g. “Push - VGB”), one for **Email** (e.g. “Email - Offers”), one for **SMS** (e.g. “SMS - Offers”).
   - Note the **subscription group IDs** (or API names) — we’ll use them in the app.

2. **In the app**, when the user changes a toggle in Profile:
   - Update local state (already done).
   - Call Braze to set subscription state, e.g.:
     - **Push ON** → `Braze.setPushNotificationSubscriptionState(SubscriptionState.SUBSCRIBED)` or your SDK’s equivalent for the **push subscription group**.
     - **Push OFF** → `SubscriptionState.UNSUBSCRIBED`.
     - Same pattern for Email and SMS with their subscription group IDs.

3. **On first load** (or after `changeUser`), sync current app preference to Braze so Braze’s state matches the app (e.g. read `user.notificationsEnabled` and set push subscription state accordingly).

Exact method names depend on the **Braze Flutter/SDK** version (e.g. `setEmailSubscriptionState`, `setPushNotificationSubscriptionState`, or subscription group–specific APIs). When we wire the SDK, we’ll use the API that matches your Braze dashboard subscription groups.

---

## Summary

- **Data tracking plan:** We keep `notification_preference_changed` (Y) for behavioral tracking.
- **Messaging behavior:** We **map the three toggles to Braze subscription groups** so Braze respects Push/Email/SMS preferences and you can reliably test **push** (and other channels) in campaigns/Canvas.
